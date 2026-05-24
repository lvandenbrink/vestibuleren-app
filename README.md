# Vestibuleren App

A Flutter app that helps patients follow their vestibular rehabilitation programme at home. Users select exercises prescribed by their therapist, perform them with metronome guidance and configurable sets/reps/rest, and log feedback (rating, pain level, effect and notes) after each session. Progress is visualised in charts on the Statistics tab.

Licensed under **CC BY-NC 4.0** — attribution required, no commercial use. See [LICENSE](LICENSE).

A hosted web version is available at **<https://lvandenbrink.github.io/vestibuleren-app/>** — no installation required.

---

## Requirements

| Tool | Minimum version |
|------|----------------|
| Flutter | 3.19 |
| Dart | 3.3 |
| Android SDK | API 21 (Android 5.0) |
| Java | 17 |

---

## Start development

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd vestibular-app
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Open in your IDE**  
   VS Code and Android Studio both detect the project automatically.  
   The entry point is `lib/main.dart`.

4. **Add exercise GIFs** *(optional)*  
   Drop animated GIF files into `assets/exercises/` using the exercise IDs as filenames (e.g. `vor_horizontaal.gif`), then declare the folder in `pubspec.yaml`:

   ```yaml
   flutter:
     assets:
       - assets/exercises/
   ```

---
## Run the app

Run the app in chrome for quick iteration without needing an emulator or device:
```bash
flutter run --d chrome
```
Or test in the emulator or on a physical device (see below).

### Start an Android emulator

1. **Create an AVD** (if you haven't already)

   In Android Studio: **Device Manager → Create Device**, pick a phone (e.g. Pixel 8), select a system image (API 33+) and finish.

   Or via the command line:

   ```bash
   avdmanager create avd \
     --name "Pixel8_API33" \
     --package "system-images;android-33;google_apis;x86_64" \
     --device "pixel_8"
   ```

2. **Start the emulator**

   From Android Studio: click the **▶** button next to the AVD in Device Manager.

   Or from the terminal:

   ```bash
   emulator -avd Pixel8_API33
   ```

   > `emulator` is located in `$ANDROID_HOME/emulator/`. Add it to your `PATH` if the command is not found.

3. **Verify it is visible to Flutter**

   ```bash
   flutter devices
   ```

   The emulator should appear in the list before you run the app.

---

### Run the app to a device or emulator
Connect an Android device or start an emulator, then:

```bash
flutter run
```

To target a specific device:

```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

For a release build locally:

```bash
flutter run --release
```

---

### Install the app (sideload)

Build a debug APK and install it directly on a device:

```bash
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

For a release APK (unsigned, for testing only):

```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Deploy to the web

The web build is deployed automatically to GitHub Pages on every push to `main` via `.github/workflows/deploy-web.yml`.

To build and preview locally:

```bash
flutter build web --release --base-href="/vestibuleren-app/"
```

Then serve the output from `build/web/` with any static file server.

---

## Deploy to the Google Play Store

### 1. Create a signing keystore

```bash
keytool -genkey -v \
  -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

> Keep `upload-keystore.jks` out of version control — add it to `.gitignore`.

### 2. Configure signing in the Android project

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Edit `android/app/build.gradle.kts` to load `key.properties` and add a `release` signing config. Flutter's own documentation has the exact snippet:  
<https://docs.flutter.dev/deployment/android#configure-signing-in-gradle>

### 3. Build the release bundle

Google Play requires an **App Bundle** (`.aab`), not an APK:

```bash
flutter build appbundle --release
```

The output is at:

```
build/app/outputs/bundle/release/app-release.aab
```

### 4. Upload to Google Play

1. Go to [Google Play Console](https://play.google.com/console) and create an app.
2. Complete the store listing (title, description, screenshots, icon).  
   The icon must be **512 × 512 px PNG, full bleed, no transparency** — see `assets/icon.png`.
3. Open **Release → Production → Create new release**.
4. Upload `app-release.aab`.
5. Fill in the release notes and roll out.

### Version bumps

Update `version` in `pubspec.yaml` before each release:

```yaml
version: 1.0.1+2   # format: <human-version>+<build-number>
```

The build number must be strictly higher than the previous release.
