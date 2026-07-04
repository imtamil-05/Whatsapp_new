# 💬 WhatsApp Chat App Clone

A modern WhatsApp-inspired real-time chat application built using **Flutter**, **Firebase**, and **Supabase**. This project replicates many of WhatsApp's core features, including real-time messaging, image sharing, reply messages, message status, and message deletion.

> This project was built as part of my Flutter learning journey to gain hands-on experience in real-time applications, cloud databases, storage integration, and UI development.

---

# ✨ Features

## 🔐 Authentication

- Phone Number Login
- Firebase Authentication
- Secure user login
- Automatic session management

---

## 💬 One-to-One Chat

- Real-time messaging
- Firestore Stream updates
- Automatic chat room creation
- Messages ordered by timestamp
- Latest message preview

---

## 📷 Image Messaging

- Pick image from Gallery
- Capture image from Camera
- Preview before sending
- Add caption to image
- Images stored in Supabase Storage

---

## ↩️ Reply Messages

- Swipe right to reply
- Reply preview above message input
- Reply shown inside chat bubble
- WhatsApp-style reply UI

---

## ✅ Message Status

- ✔ Sent
- ✔✔ Delivered
- ✔✔ Read

---

## 🗑 Message Deletion

### Delete For Me

- Removes message only for the current user

### Delete For Everyone

- Removes message for both users
- Displays "This message was deleted"

---

## 📅 Message Information

- Timestamp
- Sender
- Receiver
- Read Status
- Reply Information

---

## 🎨 WhatsApp UI

- WhatsApp-inspired chat bubbles
- Responsive layout
- Image bubbles
- Chat wallpaper
- Rounded message containers

---

## ☁ Cloud Storage

Images are uploaded to **Supabase Storage**.

Messages are stored in **Firebase Firestore**.

Authentication is handled using **Firebase Authentication**.

---

# 🛠 Tech Stack

## Frontend

- Flutter
- Dart

## Backend

- Firebase Authentication
- Firebase Firestore
- Supabase Storage

---

# 📦 Packages Used

```yaml
firebase_auth:
cloud_firestore:
supabase_flutter:
image_picker:
intl:
flutter:
```

---

# 📂 Folder Structure

```text
lib
│
├── Models
│   ├── Message_Models.dart
│   └── User_model.dart
│
├── Screens
│   ├── Chats
│   │   ├── chat_page.dart
│   │   └── widget
│   │       └── message_bubble.dart
│   ├── Home
│   ├── Calls
│   └── Status
│
├── Services
│   ├── Firebase
│   └── Supabase
│
├── Utils
│   └── last_seen_formatter.dart
│
├── Widgets
│   └── Image_preview_screen.dart
│
└── main.dart
```

---

# 🔥 Firestore Database Structure

```text
chats
│
└── chatRoomId
      │
      ├── users
      ├── lastMessage
      ├── lastMessageTime
      │
      └── messages
             │
             └── messageId
                    ├── senderId
                    ├── receiverId
                    ├── text
                    ├── imageUrl
                    ├── timestamp
                    ├── status
                    ├── replyTo
                    ├── replyToId
                    ├── deletedFor
                    └── isDeletedForEveryone
```

---

# ☁ Supabase Storage Structure

```text
chat-images
│
└── chats
      │
      └── userId
             ├── image1.jpg
             ├── image2.jpg
             └── ...
```

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/yourusername/whatsapp-chat-app.git
```

## Open Project

```bash
cd whatsapp-chat-app
```

## Install Packages

```bash
flutter pub get
```

## Configure Firebase

- Create a Firebase project
- Enable Phone Authentication
- Enable Firestore
- Add `google-services.json` (Android)
- Add `GoogleService-Info.plist` (iOS)

## Configure Supabase

Create a Storage Bucket named:

```text
chat-images
```

Configure:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

## Run the Project

```bash
flutter run
```

---

# 📌 Firestore Message Model

```json
{
  "senderId": "user1",
  "receiverId": "user2",
  "text": "Hello",
  "imageUrl": "",
  "timestamp": "",
  "status": "sent",
  "type": "text",
  "replyTo": "Hi",
  "replyToId": "messageId",
  "deletedFor": [],
  "isDeletedForEveryone": false
}
```

---

# 💡 Challenges Faced

- Implemented real-time messaging using Firestore Streams.
- Created unique chat room IDs for every conversation.
- Integrated Supabase Storage for image uploads.
- Built an image preview screen with captions.
- Implemented WhatsApp-style swipe-to-reply.
- Designed responsive reply message UI.
- Added message status indicators (Sent, Delivered, Read).
- Implemented Delete for Me and Delete for Everyone.
- Built responsive chat bubbles for text and images.
- Integrated Firebase Authentication, Firestore, and Supabase into one application.

---

# 📚 What I Learned

- Flutter Widget Tree
- Stateful & Stateless Widgets
- Firebase Authentication
- Cloud Firestore
- Firestore Streams
- CRUD Operations
- Supabase Storage
- Image Upload
- Responsive UI
- State Management
- Navigation
- File Handling
- Asynchronous Programming
- Clean Architecture

---

# 🚀 Future Enhancements

- Voice Messages
- Audio Calling
- Video Calling
- Group Chats
- Emoji Picker
- Stickers
- GIF Support
- Online Status
- Typing Indicator
- Push Notifications
- Dark Theme
- Search Messages
- Message Reactions
- Pinned Chats
- Document Sharing
- End-to-End Encryption

---

# 👩‍💻 About Me

**Tamilmozhi**

Flutter Developer passionate about building modern mobile applications and continuously improving through real-world projects.

---

# 📫 Connect With Me

- **Repository:** https://github.com/imtamil-05/Whatsapp_new
- **GitHub Profile:** https://github.com/imtamil-05
- **LinkedIn:** https://www.linkedin.com/in/tamil-mozhi-651538293


---

# ⭐ Support

If you found this project helpful, please consider giving it a ⭐ on GitHub.

---

# 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.