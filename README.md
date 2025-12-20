# 🤝 Kasalo: Shared Kindness
### A Digital Community Pantry Application

> *"Magbigay ayon sa kakayahan, Kumuha batay sa pangangailangan"*
> *(Give according to ability, take according to need)*

---

## 📖 About the Project
[cite_start]**Kasalo** is a mobile application designed to digitize the concept of a "Community Pantry"[cite: 64]. It connects individuals who have surplus resources with those in need, ensuring that valuable items like food and clothing are utilized rather than discarded.

[cite_start]This project was developed as a requirement for **CS312 - Mobile Computing** at **Batangas State University - The National Engineering University**[cite: 49, 58].

### 🎯 SDG Alignment
This project is built in alignment with **United Nations Sustainable Development Goal 12**:
> [cite_start]**SDG 12: Responsible Consumption and Production** [cite: 66]
> *Ensuring sustainable consumption and production patterns by facilitating resource redistribution.*

---

## ✨ Key Features
* [cite_start]**🔐 Secure Authentication:** User sign-up and login powered by **Firebase Authentication** (Email/Password)[cite: 77].
* [cite_start]**📍 Geo-Location:** Automatic address detection to show donations near the user[cite: 363, 542].
* [cite_start]**📦 Donation Management:** Users can browse categories (e.g., Clothes, Food) and post their own donations[cite: 543, 579].
* [cite_start]**💬 In-App Messaging:** Integrated chat feature for donors and beneficiaries to coordinate pickups[cite: 580].
* [cite_start]**👤 User Profiles:** Manage personal information and view donation history[cite: 537, 587].

---

## 📱 User Interface
| Login Screen | Registration | Home Dashboard |
|:---:|:---:|:---:|
| <img src="assets/screenshots/login.png" width="200"> | <img src="assets/screenshots/register.png" width="200"> | <img src="assets/screenshots/home.png" width="200"> |
*(Place your screenshots in an `assets/screenshots` folder)*

---

## 🛠️ Tech Stack
* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend:** [Firebase](https://firebase.google.com/)
* **Authentication:** Firebase Auth
* [cite_start]**Database:** Cloud Firestore (NoSQL) [cite: 468]
* [cite_start]**Design:** Google Fonts (Poppins) [cite: 103]

---

## 📂 Project Structure
[cite_start]Based on the project documentation :

```text
kasalo/
├── android/
├── assets/
│   └── icons/              # App logos (kasalo_logo.png, etc.)
├── ios/
├── lib/
│   ├── screens/            # UI Screens
│   │   ├── about_screen.dart
│   │   ├── add_donation_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── donation_detail_screen.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_layout.dart
│   │   ├── messages_screen.dart
│   │   ├── my_donations_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── registration_screen.dart
│   │   ├── settings_screen.dart
│   │   └── welcome_screen.dart
│   ├── services/           # Backend Logic
│   │   ├── auth_service.dart
│   │   └── database_service.dart
│   └── main.dart           # Entry point
└── pubspec.yaml
