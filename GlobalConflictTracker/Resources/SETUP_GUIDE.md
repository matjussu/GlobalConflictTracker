# Global Conflict & Intelligence Tracker — Setup Guide

## 1. Create Xcode Project

1. Open Xcode 15+
2. File → New → Project → iOS → App
3. Product Name: **GlobalConflictTracker**
4. Organization Identifier: your reverse domain (e.g. `com.yourname`)
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Storage: **None** (we handle persistence manually)
8. Uncheck "Include Tests" for now
9. Save to your preferred location

## 2. Import Source Files

1. Delete the auto-generated `ContentView.swift` and `GlobalConflictTrackerApp.swift`
2. Drag the entire `GlobalConflictTracker/` folder into Xcode's Project Navigator
3. When prompted, check **"Copy items if needed"** and **"Create groups"**
4. Ensure all `.swift` files have the correct target membership

## 3. Add Firebase SDK via SPM

1. File → Add Package Dependencies
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Set version rule to **Up to Next Major** (11.0.0+)
4. Select these packages:
   - **FirebaseAuth**
   - **FirebaseFirestore**
   - **FirebaseMessaging**
   - **FirebaseStorage**
5. Add all selected to the **GlobalConflictTracker** target

## 4. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** → name it "GlobalConflictTracker"
3. Disable Google Analytics (optional for MVP)
4. Wait for project creation

## 5. Add iOS App to Firebase

1. In Firebase Console, click the **iOS icon** to add an app
2. Enter your **Bundle ID** (same as Xcode, e.g. `com.yourname.GlobalConflictTracker`)
3. App nickname: "GlobalConflictTracker"
4. Skip App Store ID for now
5. Download **GoogleService-Info.plist**
6. Drag it into the Xcode project root (ensure "Copy items if needed" is checked)

## 6. Enable Firestore

1. In Firebase Console → **Build → Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (allows all reads/writes for 30 days)
4. Select your nearest region (e.g. `europe-west1` for EU)
5. Click **Enable**

### Set Security Rules (Development)

In Firestore → Rules, paste the contents of `scripts/firestore.rules`:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /events/{eventId} {
      allow read: if true;
      allow write: if true;
    }
    match /factions/{factionId} {
      allow read: if true;
      allow write: if true;
    }
    match /intelReports/{reportId} {
      allow read: if true;
      allow write: if true;
    }
    match /regions/{regionId} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

## 7. Enable Cloud Messaging (Push Notifications)

1. In Xcode → Target → **Signing & Capabilities**
2. Add **Push Notifications** capability
3. Add **Background Modes** capability → check **Remote notifications**
4. In Firebase Console → **Project Settings → Cloud Messaging**
5. Upload your APNs Authentication Key:
   - Go to [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
   - Create a new key with **Apple Push Notifications service (APNs)**
   - Download the `.p8` file
   - Upload it to Firebase Cloud Messaging settings

## 8. Build Settings

- Deployment Target: **iOS 17.0**
- Supported Devices: **iPhone + iPad**
- Device Orientation: **Portrait** (primary), Landscape (iPad optional)

## 9. First Run (Mock Mode)

1. Select an iPhone 15 Pro simulator (iOS 17+)
2. Build & Run (Cmd + R)
3. The app launches in **Mock mode** by default (local sample data)
4. Complete the Onboarding flow
5. Browse the app — all data comes from `SampleData.swift`

## 10. Seed Firebase & Switch to Live Data

### Option A: Seed from the App

1. Go to the **SYSTEM** tab in the app
2. In **Dev Tools** section, tap **"Seed Firebase with Sample Data"**
3. Toggle **"Use Mock Data"** OFF to switch to Firebase
4. The app now reads from Firestore in real-time

### Option B: Seed from Terminal (Python Script)

1. Download your service account key:
   - Firebase Console → Project Settings → **Service Accounts**
   - Click **Generate new private key** → download JSON
   - Save it as `scripts/serviceAccountKey.json` (DO NOT commit this file)

2. Run the seed script:
```bash
cd scripts
pip install -r requirements.txt
python seed_firestore.py --key serviceAccountKey.json
```

3. In the app, toggle "Use Mock Data" OFF — the data appears in real-time

## 11. Verify Everything Works

- [ ] App builds without errors
- [ ] Onboarding flow works (3 steps)
- [ ] Mock mode: all 4 tabs show data
- [ ] Firebase seeded (via app or script)
- [ ] Firebase mode: toggle Mock OFF, data loads from Firestore
- [ ] Real-time: add a document in Firebase Console, it appears in the app
- [ ] Toggle between Mock/Firebase: data switches instantly
