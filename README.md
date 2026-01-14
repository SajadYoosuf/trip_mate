# Trip Mate 🌍✈️

Trip Mate is a premium, state-of-the-art Flutter mobile application designed to be the ultimate companion for modern travelers, specifically tailored for the Indian landscape. Combining AI-powered guidance, gamified discovery, and social trip-planning, it transforms the travel experience into an engaging journey.

---

## 🏗️ Architecture Overview

The project follows a **Layered Architecture** pattern, emphasizing separation of concerns, testability, and scalability.

- **UI Layer (`lib/screens`, `lib/widgets`)**: Built with a "Mobile-First" premium aesthetic. It utilizes custom widgets and complex animations (like the Parallax Splash).
- **State Management (`lib/providers`)**: Powered by `Provider`. Each feature has a dedicated provider managing state and reacting to data changes.
- **Service/Repository Layer (`lib/services`)**: Abstracted interfaces (e.g., `PlaceRepository`, `AuthRepository`) with concrete implementations. This allows for easy swapping of data sources (e.g., Firebase vs. Mock).
- **Domain Layer (`lib/models`)**: Lean Dart classes representing core entities like `User`, `Place`, `Trip`, and `TripRequest`.
- **Navigation (`lib/core/app_router.dart`)**: Uses `GoRouter` with `StatefulShellRoute` for a smooth, persistent Bottom Navigation experience.

---

## ✨ Key Features

### 🌋 1. Immersive Entry & Onboarding
- **Animated Splash Screen**: A high-performance parallax animation themed around the Indian Himalayas, featuring a sequential "summmit" story and flag reveal.
- **Smart Onboarding**: Contextual introductory slides for first-time users.

### 🤖 2. AI Travel Assistant (Gemini)
- **Bilingual Support**: Integrated with Google's Gemini AI to provide real-time travel advice.
- **Native Context**: Specifically tuned to understand and respond in both **English** and **Malayalam**, including Manglish support.
- **Tone**: Mimics a "local companion" rather than a robotic assistant.

### 🏆 3. Gamification & Leaderboard
- **XP System**: Users earn 10-20 points for "Marking as Visited" or checking in at locations.
- **Global & Nearby Rankings**: A premium leaderboard UI with podium views for top-ranked travelers.
- **Traveler Levels**: Dynamic levels (e.g., Gold Member) based on earned experience points.

### 🗺️ 4. Discovery & Maps
- **Location-Aware Feed**: Uses Google Places API to suggest the best nearby spots.
- **Global Map**: Interactive map view with markers for nearby attractions and saved places.
- **Place Details**: Comprehensive data including photos, descriptions, and one-tap navigation to Google Maps.

### 📂 5. Unified Profile & Hub
- **Nested User Hub**: The Profile page serves as a central dashboard.
- **Journey Tracker**: Integrated tabs to view **Saved** places, **Visited** history, and **Planned Trips**.
- **Collapsible UI**: Uses `NestedScrollView` to provide a "glassmorphism" header effect that collapses as you explore your data.

### 🔐 6. Secure Authentication
- **Firebase Auth**: Robust login/signup logic.
- **UI Polish**: Password visibility toggles, logout confirmation popups, and secure profile photo uploads using Firebase Storage.

---

## 🛠️ Technical Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **State Management** | Provider |
| **Routing** | GoRouter |
| **Database (Local)** | Hive (NoSQL) |
| **Cloud (Backend)** | Firebase (Auth, Firestore, Storage) |
| **AI Integration** | Google Generative AI (Gemini Flash) |
| **API** | Google Places API, Geolocator |
| **Animations** | Flutter Animation Controllers, Parallax |

---

## 🚀 Getting Started

1.  **Environment Setup**:
    - Ensure you have a `.env` file at the root with `GEMINI_API_KEY` and `GOOGLE_MAPS_API_KEY`.
2.  **Firebase**:
    - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
3.  **Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run**:
    ```bash
    flutter run
    ```

---

## 👨‍💻 Development Notes

- **Folder Structure**:
  - `lib/core`: App-wide themes, constants, and router.
  - `lib/providers`: Business logic and UI state.
  - `lib/services`: External API handlers and persistence logic.
  - `lib/screens`: Complete page layouts.
  - `lib/widgets`: Reusable UI components.

- **Theming**:
  - Supports a primary **Travel Blue** and **Gold** palette designed for sunlight readability and premium feel.

---

*Developed with ❤️ for travelers by the Trip Mate Team.*
