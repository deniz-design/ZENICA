# PosePerfect 🧘✨

> **AI-Powered Real-Time Yoga Posture Detection, Correction, and Holistic Wellness Companion**

PosePerfect (also featuring the **Zenica** wellness suite) is a modern mobile application built with **Flutter** that transforms your smartphone into an intelligent personal yoga instructor. By leveraging live on-device computer vision and a custom deep learning inference engine, PosePerfect tracks your posture in real time, scores your form, identifies specific joint deviations, and provides immediate biomechanical feedback—all without sending sensitive video streams to the cloud.

---

## 📖 About This Project

Practicing yoga independently often lacks the critical feedback loop provided by an in-person instructor. Improper alignment can reduce the effectiveness of asanas and even lead to strain or injury. 

**PosePerfect** solves this problem by integrating advanced computer vision and biomechanical analysis directly on your mobile device. Beyond real-time computer vision pose analysis, the app delivers a holistic wellness ecosystem: an extensive curated yoga studio, mindful soundscapes, daily lifestyle tips, healthy nutrition recipes, a dual-unit BMI calculator, personalized progress analytics, and smart daily practice reminders.

### 🌟 Key Value Highlights

- **🔒 100% On-Device Privacy & Zero Latency**: Video frames are processed locally in real-time using Google ML Kit and a custom on-device neural inference engine. No video or camera frames leave your device.
- **🎯 3-Head Biomechanical Analysis**: Goes beyond simple classification by simultaneously predicting the pose, calculating an overall correctness percentage, and isolating joint-by-joint angle deviations.
- **⚡ Hybrid Decision Engine**: Merges learned neural network predictions with deterministic biomechanical angle rules for maximum accuracy and stability.
- **🔥 Intelligent Calorie Tracking**: Calculates real-time calorie expenditure based on scientific MET (Metabolic Equivalent of Task) values for each pose and the user's personal weight profile.
- **🌿 All-in-One Wellness Hub**: Integrates guided routines, meditation audio soundscapes, nutritional guidance, and habit tracking.

---

## 🚀 Core Features

### 1. 🤖 Live AI Pose Detection & Corrective Feedback
- **Real-Time Landmark Tracking**: Streams live camera frames (front or rear camera) and tracks 33 full-body anatomical keypoints using **Google ML Kit Pose Detection**.
- **Dynamic Skeleton Overlay**: Renders color-coded skeletal joints and bones directly over the camera feed.
- **Custom 3-Head MLP Neural Engine**:
  - **Head 1 (Pose Recognition)**: Classifies user posture across **23 distinct yoga asanas** and transitional states.
  - **Head 2 (Form Accuracy)**: Computes a confidence/correctness percentage (0–100%) against ideal biomechanical standards.
  - **Head 3 (Joint Deviation Engine)**: Analyzes 15 anatomical angles (shoulders, elbows, hips, knees, trunk, and neck) and pinpoints precise body parts that need correction (e.g., *"Straighten left knee"*, *"Raise right arm"*).
- **Hold Timer & Rep Progression**: Detects when a target pose is properly held, triggers a live hold-duration stopwatch, and logs successful completions.
- **Active MET Calorie Counter**: Dynamically computes calories burned per pose session using metabolic formulas adjusted for the practitioner's body weight.

### 2. 📚 Comprehensive Yoga Studio
Structured library of poses categorized by skill level, each complete with reference images, detailed instructions, benefits, and instant access to camera-assisted practice:
- **Beginner**: Mountain Pose, Child's Pose, Tree Pose, Seated Easy Pose, Seated Staff Pose, Standing Pose, Corpse Pose (Savasana).
- **Intermediate**: Downward-Facing Dog, Cobra Pose, Warrior I, Warrior II, Plank Pose, Lunge Pose, Standing Forward Fold.
- **Advanced**: Upward Salute, Chaturanga Dandasana, Upward-Facing Dog, Halfway Lift, Triangle Pose, Seated Forward Fold, Table Top Pose.

### 3. 🎵 Mindful Soundscapes
- Built-in ambient sound player for meditation, breathwork (Pranayama), and relaxation.
- High-fidelity looping audio tracks including **Ocean Waves**, **Forest Ambience**, and **Campfire**, powered by `audioplayers`.

### 4. 🥗 Nutrition & Daily Tips
- **Quick Healthy Recipes**: Wholesome culinary inspirations (e.g., Avocado Toast, Nutritious Smoothies, Energy Bites) with ingredient breakdowns and preparation guides.
- **Daily Wellness Tips**: Expert advice covering mindfulness, hydration, flexibility routines, and posture habits.

### 5. ⚖️ Interactive BMI Calculator
- Supports both **Metric** (cm / kg) and **Imperial** (inches / lbs) measurement systems.
- Interactive height slider, custom weight input, and instant categorization (Underweight, Normal, Overweight, Obese) with health recommendations.
- Synchronizes canonical metrics directly with the user's central profile.

### 6. 👤 User Profiles & Firebase Cloud Sync
- **Authentication**: Secure registration, login, and session persistence via **Firebase Authentication**.
- **Cloud Firestore Persistence**: Stores personal metrics (height, weight, age, yoga experience level, goals) and tracks statistics (total sessions, poses completed, average form accuracy, weekly/monthly milestones).
- **Smart Notification Reminders**: Re-engages practitioners with configurable daily practice reminders via `flutter_local_notifications` and `timezone`.

---

## 🧠 Machine Learning & Vision Architecture

```
[ Camera Stream (CameraImage) ]
               │
               ▼
[ Google ML Kit Pose Detector (Stream Mode) ]
               │ (33 3D Body Keypoints)
               ▼
[ 2D Landmark Normalization & Geometric Angle Extraction ]
               │ (15 Biomechanical Joint Angles)
               ▼
┌─────────────────────────────────────────────────────────────┐
│                    Custom ML Pipeline                       │
│                                                             │
│   ┌──────────────────────────┐   ┌──────────────────────┐   │
│   │   Biomechanical Rules    │   │   3-Head MLP Engine  │   │
│   │    Classifier Engine     │   │ (pose_3head.bin/json)│   │
│   └────────────┬─────────────┘   └──────────┬───────────┘   │
│                │                            │               │
│                └─────────────┬──────────────┘               │
│                              ▼                              │
│                 Hybrid Weighted Pose Vote                   │
│                              │                              │
│        ┌─────────────────────┼─────────────────────┐        │
│        ▼                     ▼                     ▼        │
│  Pose Label           Correctness %        Joint Deviation  │
│  (23 Classes)         (Form Score)           Corrections    │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
[ Real-Time UI Feedback, Skeleton Painter, Hold Timer & MET Burn ]
```

### 15 Computed Biomechanical Joint Angles
- **Arms**: Left/Right Elbow (`elbow_l`, `elbow_r`), Left/Right Shoulder (`shoulder_l`, `shoulder_r`)
- **Legs**: Left/Right Knee (`knee_l`, `knee_r`), Left/Right Hip (`hip_l`, `hip_r`)
- **Core & Trunk**: Left/Right Trunk (`trunk_l`, `trunk_r`), Neck angle (`neck`)
- **Extremities**: Left/Right Wrist, Left/Right Ankle

---

## 📁 Project Structure

```
Pose_Perfect/
├── assets/
│   ├── advanced/                  # High-resolution pose imagery
│   ├── beginner/                  # Beginner pose imagery
│   ├── intermediate/              # Intermediate pose imagery
│   ├── model/
│   │   ├── pose_3head.bin         # Float32 flat model weights
│   │   ├── pose_3head.json        # Layer architecture & tensor metadata
│   │   └── pose_labels.txt        # 23 pose class labels
│   └── soundscape/                # Ambient audio files (ocean, campfire, forest)
├── lib/
│   ├── main.dart                  # App entrypoint, Firebase & notification init
│   ├── firebase_options.dart      # Platform Firebase configuration
│   ├── bmicalcpage/               # BMI calculation & health category displays
│   ├── exercisepage/              # Studio pose catalogue (Beginner, Intermediate, Advanced)
│   ├── homepage/                  # Home dashboard, soundscapes, recipes & daily tips
│   ├── loginpage/                 # Auth gate, login, registration & onboarding splash
│   ├── ml/                        # ML inference core
│   │   ├── geometry.dart          # 2D/3D angle & landmark geometry calculations
│   │   ├── model_engine.dart      # Native pure-Dart tensor runner for 3-head MLP
│   │   ├── pose_analyzer.dart     # Camera frame preprocessor & pipeline coordinator
│   │   └── rules_classifier.dart # Deterministic biomechanical rules engine
│   ├── models/                    # Data models (UserProfile, etc.)
│   ├── onboarding/                # Initial setup & profile configuration flow
│   ├── pose_detection/            # Live camera screen, skeleton painter & metrics overlay
│   ├── profilepage/               # User account, stats, goal settings & reminder toggles
│   └── services/                  # Business logic (ProfileRepository, ReminderService, PoseMET)
└── pubspec.yaml                   # Dependencies and asset declarations
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology / Package | Purpose |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (Dart 3.5+) | Cross-platform mobile client |
| **Computer Vision** | [google_mlkit_pose_detection](https://pub.dev/packages/google_mlkit_pose_detection) | 33-point body keypoint tracking |
| **Custom Neural Engine** | Pure Dart Flat32 Tensor Engine | High-speed on-device MLP forward pass |
| **Camera Feed** | [camera](https://pub.dev/packages/camera) & [camera_windows](https://pub.dev/packages/camera_windows) | Live hardware camera frame streaming |
| **Backend & Cloud** | [firebase_core](https://pub.dev/packages/firebase_core), [firebase_auth](https://pub.dev/packages/firebase_auth), [cloud_firestore](https://pub.dev/packages/cloud_firestore) | User authentication and profile synchronization |
| **Local Notifications**| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), [timezone](https://pub.dev/packages/timezone) | Timed daily yoga reminders |
| **Audio Playback** | [audioplayers](https://pub.dev/packages/audioplayers) | Ambient meditation soundscapes |
| **UI Components** | [google_nav_bar](https://pub.dev/packages/google_nav_bar), [carousel_slider](https://pub.dev/packages/carousel_slider), [google_fonts](https://pub.dev/packages/google_fonts) | Modern glassmorphism & navigation styling |

---

## 📋 Recognized Pose Classes (23 Asanas)

The hybrid neural classifier is trained to detect and evaluate:

1. `chair_pose` (Utkatasana)
2. `chaturanga` (Chaturanga Dandasana)
3. `child_pose` (Balasana)
4. `cobra_pose` (Bhujangasana)
5. `corpse` (Savasana)
6. `downward_dog` (Adho Mukha Svanasana)
7. `halfway_lift` (Ardha Uttanasana)
8. `lunge_pose` (Anjaneyasana)
9. `mountain_pose` (Tadasana)
10. `plank` (Phalakasana)
11. `seated_easy_pose` (Sukhasana)
12. `seated_forward` (Paschimottanasana)
13. `seated_staff` (Dandasana)
14. `standing_forward_fold` (Uttanasana)
15. `standing_pose`
16. `table_top` (Bharmanasana)
17. `tree_pose` (Vrksasana)
18. `triangle` (Trikonasana)
19. `upward_dog` (Urdhva Mukha Svanasana)
20. `upward_salute` (Urdhva Hastasana)
21. `warrior_1` (Virabhadrasana I)
22. `warrior_2` (Virabhadrasana II)
23. `transition/unknown` (Intermediate movement state)

---

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.5.4` or later)
- Android Studio / Xcode with platform SDKs installed
- Physical device with camera support (recommended for live pose detection testing) or an emulator with virtual webcam enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/PosePerfect.git
   cd PosePerfect/Pose_Perfect
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Ensure your Firebase project is configured.
   - Run `flutterfire configure` or verify that `lib/firebase_options.dart` points to your active Firebase project.

4. **Run the application:**
   ```bash
   # Run on connected device or emulator
   flutter run
   ```

---

## 👥 Authors & Acknowledgments

- **PosePerfect Team**: Dedicated to creating intelligent, accessible, and privacy-first fitness technology.
- **Google ML Kit**: Powering reliable on-device pose landmark detection.

