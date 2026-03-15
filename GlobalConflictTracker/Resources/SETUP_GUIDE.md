# Global Conflict & Intelligence Tracker — Xcode Setup Guide

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

## 4. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Add an iOS app with your bundle identifier
4. Download `GoogleService-Info.plist`
5. Drag it into the Xcode project root (ensure "Copy items if needed" is checked)

## 5. Configure Push Notifications

1. In Xcode → Target → Signing & Capabilities
2. Add **Push Notifications** capability
3. Add **Background Modes** capability → check **Remote notifications**
4. In Firebase Console → Project Settings → Cloud Messaging
5. Upload your APNs key or certificate

## 6. Build Settings

- Deployment Target: **iOS 17.0**
- Supported Devices: **iPhone + iPad**
- Device Orientation: **Portrait** (primary), Landscape (iPad optional)

## 7. Run

1. Select an iPhone 15 Pro simulator (iOS 17+)
2. Build & Run (Cmd + R)
3. The app should launch with the Onboarding flow on first run
