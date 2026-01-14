# Project Documentation: Trip Mate 🌍✨

---

## 1. INTRODUCTION

### 1.1 About the Project
**Trip Mate** is a state-of-the-art mobile application designed to revolutionize the travel experience. Built for modern explorers, the app serves as an AI-powered travel companion that simplifies trip planning, fosters social collaboration, and gamifies discovery. Unlike generic travel apps, Trip Mate integrates deep AI bilingual support (English & Malayalam) and real-time group tracking to make journeys safer and more engaging.

### 1.2 Methodology
The project follows the **Agile Development Methodology**. This incremental approach allowed for continuous integration of complex features like real-time location tracking and Gemini AI integration. Weekly sprints focused on UI polish, followed by backend integration and testing, ensuring a bug-free, premium experience.

### 1.3 Timeline
1.  **Requirement Gathering & Planning**: 1 Week
2.  **UI/UX Design & Prototyping**: 2 Weeks
3.  **Frontend Development (Flutter)**: 3 Weeks
4.  **Backend Integration (Firebase & AI)**: 2 Weeks
5.  **Testing & Optimization**: 1 Week
6.  **Deployment & Documentation**: Current Phase

### 1.4 Model Used
The app utilizes **Google’s Gemini 1.5 Flash AI model** for its core chat intelligence. This model allows for fast, context-aware responses and supports the bilingual Manglish/Malayalam capabilities essential for the target demographic.

---

## 2. SYSTEM SPECIFICATION

### 2.1 System Configuration
-   **Processor**: Minimum Quad-core 1.8 GHz (Android/iOS)
-   **RAM**: 4GB Minimum
-   **Operating System**: Android 8.0+ / iOS 13.0+
-   **Connectivity**: High-speed Internet (required for AI & Cloud Sync)
-   **Sensors**: GPS/GNSS for location-aware features.

### 2.2 Requirement Specifications
-   **Functional Requirements**:
    -   Secure User Authentication (Firebase).
    -   AI Chat Assistant (Gemini).
    -   Nearby Place Discovery (Google Places API).
    -   Real-time Collaborative Trip Planning.
    -   Gamified Leaderboard (XP System).
-   **Non-Functional Requirements**:
    -   **Performance**: UI response time < 100ms.
    -   **Scalability**: Support for thousands of concurrent users via Firestore.
    -   **Aesthetics**: Glassmorphism and Parallax-based design system.

---

## 3. SYSTEM ANALYSIS

### 3.1 Feasibility Study
-   **Technical**: Feasible through Flutter’s cross-platform capabilities and Firebase’s serverless infrastructure.
-   **Economic**: Cost-effective due to open-source components and serverless "pay-as-you-go" backend.
-   **Operational**: Easy to deploy and maintain with minimal infrastructure overhead.

### 3.2 Existing System
Currently, travelers rely on fragmented tools: Google Maps for navigation, WhatsApp for group coordination, and browser searches for discovery. This results in "app fatigue" and lacks personalized travel advice.

### 3.3 Proposed System
Trip Mate proposes a **Unified Travel Ecosystem**. It combines discovery, group chat, live member tracking, and AI guidance into a single, high-performance portal, reducing the friction of travel planning.

### 3.4 Purpose of the System
To provide an end-to-end travel solution that intelligently assists users in finding locations, planning itineraries with friends, and tracking journey progress through gamification.

---

## 4. SYSTEM DESIGN

### 4.1 Architecture Design
The app uses a **Layered Clean Architecture**:
1.  **Presentation Layer**: Flutter Widgets & State Management (Provider).
2.  **Domain Layer**: Pure Dart Models (User, Trip, Place).
3.  **Data Layer**: Repositories & Services (Firebase, Google APIs).

### 4.2 Entity Relationship Diagram (ERD)
-   **User**: email, name, points, photoUrl.
-   **Trip**: id, name, memberIds, placeIds.
-   **TripRequest**: id, senderId, receiverId, status.
-   **ChatMessage**: senderId, message, timestamp.
-   **Relationship**: One User can belong to Multiple Trips (M:M); One Trip contains Multiple Places (1:M).

### 4.3 Data Flow Diagram (DFD)
1.  **User Input** (Chat/Search) -> **Provider** -> **Repository**.
2.  **Repository** -> **External API** (Gemini/Places) or **Firebase**.
3.  **Response** -> **UI State Update** -> **Reactive Widget Rebuild**.

### 4.4 Input Design
-   Text inputs with validation (Login/Signup).
-   Voice/Text chat interface.
-   BottomSheet-based trip creation and search.

### 4.5 Output Design
-   Dynamic GridViews (Discovery Feed).
-   Interactive OpenStreetMap markers.
-   XP Milestone celebrate overlays and snackbars.

---

## 5. DATABASE DETAILS

### 5.1 Database Details
The app uses **Cloud Firestore** for primary cloud storage and **Hive** for ultra-fast local caching of user sessions and preferences.

### 5.2 Normalization
While NoSQL is "schemaless," the data is structured to minimize read costs. `Trip` documents store `memberIds`, and `trip_messages` are stored in nested collections to ensure fast retrieval.

### 5.3 Database Tables (Collections)
-   `users`: Stores profile data and points.
-   `trips`: Stores metadata about trips.
-   `trip_messages`: Sub-collection within trips for real-time chat.
-   `trip_requests`: Manages invitations between users.

---

## 6. OVERVIEW OF THE SOFTWARE

### 6.1 Technology
-   **Language**: Dart (Type-safe).
-   **Core**: Flutter Framework.

### 6.2 Front End Software
-   **Material Design 3**: Modern UI components.
-   **Provider**: For reactive state management.
-   **GoRouter**: For deep-link capable navigation.

### 6.3 Back End Software
-   **Firebase Auth**: For secure identity management.
-   **Firebase Storage**: For high-quality image hosting.

### 6.4 Database
-   **Firestore**: Real-time NoSQL database.

---

## 7. SYSTEM IMPLEMENTATION

### 7.1 System Implementation
The system is implemented as a single-source-of-truth Flutter codebase. Environment variables (`.env`) manage API keys for Gemini and Maps securely.

### 7.2 Implementation Procedures
1.  Firebase Project Setup.
2.  API key provisioning (Google Cloud Console).
3.  Flutter environment configuration.
4.  Deployment of Firestore Rules for security.

---

## 8. SYSTEM TESTING

### 8.1 Implementation
Automated testing was conducted for all Repository logic to ensure consistent data fetching from Firebase and AI endpoints.

### 8.2 Testing
-   **Unit Testing**: Verified User and Trip model parsing.
-   **Integration Testing**: Verified the bridge between Gemini AI and the Flutter UI.
-   **User Acceptance Testing (UAT)**: Manual walkthroughs to ensure the "Invite Friend" process and "Live Location" sharing works on physical devices.

---

## 9. FUTURE ENHANCEMENT AND CONCLUSION

### 9.1 Future Enhancement
-   **AR Navigation**: Real-time AR arrows for walking tours.
-   **Social Stories**: Allow users to post short videos of their visited places.
-   **Offline Maps**: Support for downloading map tiles for remote areas.

### 9.2 Conclusion
Trip Mate successfully bridge the gap between AI and travel. By providing a premium, bilingual, and gamified interface, it makes travel planning an enjoyable social activity rather than a chore.

---

## 10. BIBLIOGRAPHY

### 10.1 Online Reference
-   Flutter Documentation: [docs.flutter.dev](https://docs.flutter.dev)
-   Firebase Documentation: [firebase.google.com/docs](https://firebase.google.com/docs)
-   Google AI Studio (Gemini): [ai.google.dev](https://ai.google.dev)
-   GoRouter Package: [pub.dev/packages/go_router](https://pub.dev/packages/go_router)

---

## 11. SCREEN SHOTS
*(The following screens are available in the assets/screenshots folder)*
1.  **Animated Splash**: The parallax mountain entry.
2.  **Home Feed**: Discovery and place cards.
3.  **Place Details**: Premium image and check-in buttons.
4.  **AI Chat Assistant**: English/Malayalam conversation view.
5.  **Global Map**: Place markers and live location dots.
6.  **Leaderboard**: XP rankings and podium UI.
7.  **Profile Hub**: Tabbed view of Saved/Visited/Trips.
