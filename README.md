# 🤝 Kasalo: Shared Kindness
### A Digital Community Pantry Application

> *"Magbigay ayon sa kakayahan, Kumuha batay sa pangangailangan"*
> *(Give according to ability, take according to need)*

---

## 📖 About the Project
**Kasalo** is a mobile application designed to digitize the concept of a "Community Pantry". It connects individuals who have surplus resources with those in need, ensuring that valuable items like food and clothing are utilized rather than discarded.

This project was developed as a requirement for **CS312 - Mobile Computing** at **Batangas State University - The National Engineering University**.

### 🎯 SDG Alignment
This project is built in alignment with **United Nations Sustainable Development Goal 12**:
> **SDG 12: Responsible Consumption and Production**
> *Ensuring sustainable consumption and production patterns by facilitating resource redistribution.*

---

## ✨ Key Features
* **🔐 Secure Authentication:** User sign-up and login powered by **Firebase Authentication** (Email/Password).
* **📍 Geo-Location:** Automatic address detection to show donations near the user.
* **📦 Donation Management:** Users can browse categories (e.g., Clothes, Food) and post their own donations.
* **💬 In-App Messaging:** Integrated chat feature for donors and beneficiaries to coordinate pickups.
* **👤 User Profiles:** Manage personal information and view donation history.

---

## 🛠️ Tech Stack
* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend:** [Firebase](https://firebase.google.com/)
* **Authentication:** Firebase Auth
* **Database:** Cloud Firestore (NoSQL) 
* **Design:** Google Fonts (Poppins)

---

## 📂 Project Structure
Based on the project documentation :

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
