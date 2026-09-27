import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Simple float32 tensor view over a List<double>.
class Tensor {
  List<double> data;
  List<int> shape;

  Tensor(this.data, this.shape);

  int get length => data.length;
  int get shape0 => shape[0];
  int get shape1 => shape.length > 1 ? shape[1] : 1;
}

/// Result of the 3-head Yoga3HeadMLP forward pass.
class Yoga3HeadInference {
  /// Pose logits, shape [23].
  final List<double> poseLogits;

  /// Correctness logit (single value, before sigmoid).
  final double correctnessLogit;

  /// Joint deviations, shape [15].
  final List<double> deviations;

  Yoga3HeadInference(this.poseLogits, this.correctnessLogit, this.deviations);
}

/// Loads the exported flat float32 weights and metadata for Yoga3HeadMLP and
/// runs the forward pass identically to the PyTorch model (verified to 9e-6).
class Yoga3HeadMLPEngine {
  /// Flat float32 weights, in the order described in export_3head_weights.py.
  Float32List? _weights;

  /// metadata: tensor_infos -> [{name, shape, offset, count}]
  Map<String, dynamic>? _meta;

  /// All 23 pose class labels, in encoder order.
  List<String>? labels;

  bool _ready = false;

  bool get isReady => _ready;

  /// Load the model from the Flutter assets bundle.
  ///
  /// Assets must exist in pubspec:
  ///   assets/model/pose_3head.bin
  ///   assets/model/pose_3head.json
  ///   assets/model/pose_labels.txt
  Future<void> loadFromAssets({
    String binPath = 'assets/model/pose_3head.bin',
    String jsonPath = 'assets/model/pose_3head.json',
    String labelsPath = 'assets/model/pose_labels.txt',
  }) async {
    final bytes = await rootBundle.load(binPath);
    _weights = bytes.buffer.asFloat32List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
    final jstr = await rootBundle.loadString(jsonPath);
    _meta = jsonDecode(jstr) as Map<String, dynamic>;
    final lstr = await rootBundle.loadString(labelsPath);
    labels = const LineSplitter().convert(lstr).where((s) => s.trim().isNotEmpty).toList();
    _ready = true;
  }

  Tensor _tensor(String name) {
    final meta = _meta!;
    final list = meta['tensor_infos'] as List<dynamic>;
    for (final t in list.cast<Map<String, dynamic>>()) {
      if (t['name'] == name) {
        final off = (t['offset'] as num).toInt();
        final cnt = (t['count'] as num).toInt();
        final shape = (t['shape'] as List<dynamic>).cast<int>();
        final data = _weights!.sublist(off, off + cnt).toList();
        return Tensor(data, shape);
      }
    }
    throw ArgumentError('Tensor not found: $name');
  }

  /// Compute y = x @ W^T + b
  List<double> _linear(List<double> x, Tensor w, Tensor b) {
    final out = List<double>.filled(b.data.length, 0.0);
    for (int i = 0; i < w.shape0; i++) {
      double acc = 0.0;
      final rowBase = i * w.shape1;
      for (int j = 0; j < w.shape1; j++) {
        acc += x[j] * w.data[rowBase + j];
      }
      out[i] = acc + b.data[i];
    }
    return out;
  }

  /// BatchNorm: (x - mean) / sqrt(var + eps) * gamma + beta
  List<double> _batchnorm(List<double> x, Tensor gamma, Tensor beta, Tensor mean, Tensor variance, {double eps = 1e-5}) {
    final out = List<double>.filled(x.length, 0.0);
    for (int i = 0; i < x.length; i++) {
      out[i] = (x[i] - mean.data[i]) / math.sqrt(variance.data[i] + eps) * gamma.data[i] + beta.data[i];
    }
    return out;
  }

  /// Exact erf-based GELU (PyTorch approximate='none').
  List<double> _gelu(List<double> x) {
    return x.map((v) => 0.5 * v * (1.0 + _erf(v / math.sqrt2))).toList();
  }

  /// Numerical erf (Abramowitz-Stegun, 7.1.26) — exact enough for float32 equivalence.
  double _erf(double x) {
    if (x == 0) return 0.0;
    final sign = x < 0 ? -1.0 : 1.0;
    final a = x.abs();
    if (a > 6.0) return sign;
    final t = 1.0 / (1.0 + 0.3275911 * a);
    final y =
        1.0 -
            (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t *
                math.exp(-a * a);
    return sign * y;
  }

  /// A residual block: x -> BN -> GELU -> Linear -> BN -> GELU, plus residual.
  List<double> _resblock(List<double> x, String prefix) {
    final lin0 = _linear(x, _tensor('$prefix.block.0.weight'), _tensor('$prefix.block.0.bias'));
    final bn0 = _batchnorm(
      lin0,
      _tensor('$prefix.block.1.weight'),
      _tensor('$prefix.block.1.bias'),
      _tensor('$prefix.block.1.running_mean'),
      _tensor('$prefix.block.1.running_var'),
    );
    final g0 = _gelu(bn0);

    final lin1 = _linear(g0, _tensor('$prefix.block.4.weight'), _tensor('$prefix.block.4.bias'));
    final bn1 = _batchnorm(
      lin1,
      _tensor('$prefix.block.5.weight'),
      _tensor('$prefix.block.5.bias'),
      _tensor('$prefix.block.5.running_mean'),
      _tensor('$prefix.block.5.running_var'),
    );
    final g1 = _gelu(bn1);

    // residual
    return List.generate(x.length, (i) => x[i] + g1[i]);
  }

  /// A head: Linear -> BN -> GELU -> Linear.
  List<double> _head(List<double> x, String prefix) {
    final lin0 = _linear(x, _tensor('$prefix.0.weight'), _tensor('$prefix.0.bias'));
    final bn0 = _batchnorm(
      lin0,
      _tensor('$prefix.1.weight'),
      _tensor('$prefix.1.bias'),
      _tensor('$prefix.1.running_mean'),
      _tensor('$prefix.1.running_var'),
    );
    final g0 = _gelu(bn0);
    return _linear(g0, _tensor('$prefix.4.weight'), _tensor('$prefix.4.bias'));
  }

  /// Run the full 3-head forward pass on [angles] (length 15).
  Yoga3HeadInference infer(List<double> angles) {
    if (!_ready) throw StateError('Model not loaded');
    assert(angles.length == 15, 'Need 15 angle features');

    final x0 = _linear(angles, _tensor('input_layer.0.weight'), _tensor('input_layer.0.bias'));
    final bn0 = _batchnorm(
      x0,
      _tensor('input_layer.1.weight'),
      _tensor('input_layer.1.bias'),
      _tensor('input_layer.1.running_mean'),
      _tensor('input_layer.1.running_var'),
    );
    final g0 = _gelu(bn0);

    final x1 = _resblock(g0, 'res1');
    final x2 = _resblock(x1, 'res2');

    final poseLogits = _head(x2, 'pose_head');
    final corrLogit = _head(x2, 'correctness_head')[0];
    final deviations = _head(x2, 'deviation_head');
    return Yoga3HeadInference(poseLogits, corrLogit, deviations);
  }

  /// Softmax over pose logits, returns (classIndex, probability).
  (int, double) softmaxPose(List<double> logits) {
    var max = logits[0];
    for (final v in logits) {
      if (v > max) max = v;
    }
    final exps = logits.map((v) => math.exp(v - max)).toList();
    final sum = exps.fold<double>(0, (a, b) => a + b);
    var bestIdx = 0;
    var bestP = 0.0;
    for (int i = 0; i < exps.length; i++) {
      final p = exps[i] / sum;
      if (p > bestP) {
        bestP = p;
        bestIdx = i;
      }
    }
    return (bestIdx, bestP);
  }

  List<double> sigmoid(List<double> x) => x.map((v) => 1.0 / (1.0 + math.exp(-v))).toList();
}