# Firestore Setup Guide

## 🔐 Security Rules Setup

### Step 1: Deploy Security Rules

1. **Using Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Navigate to **Firestore Database** → **Rules**
   - Copy the contents of `firestore.rules` file
   - Paste into the rules editor
   - Click **Publish**

2. **Using Firebase CLI:**
   ```bash
   firebase deploy --only firestore:rules
   ```

### Step 2: Development Mode (Temporary - For Testing Only)

If you need to test without authentication first, you can temporarily use these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **WARNING:** This allows anyone to read/write your database. **ONLY use this for development/testing!**

---

## 📊 Required Firestore Indexes

Firestore requires composite indexes for queries that filter on multiple fields or combine filters with ordering.

### How to Create Indexes

1. **Automatic (Recommended):**
   - When you run a query that needs an index, Firestore will show an error with a link
   - Click the link to create the index automatically
   - Wait for the index to build (usually 1-5 minutes)

2. **Manual via Firebase Console:**
   - Go to **Firestore Database** → **Indexes**
   - Click **Create Index**
   - Fill in the collection and fields as specified below

3. **Using Firebase CLI:**
   - Create a `firestore.indexes.json` file (see below)
   - Run: `firebase deploy --only firestore:indexes`

---

## 📋 Required Indexes List

### 1. Jobs Collection

#### Index 1: Filter by status, order by createdAt
- **Collection:** `jobs`
- **Fields:**
  - `status` (Ascending)
  - `createdAt` (Descending)
- **Query:** `where('status').orderBy('createdAt')`

#### Index 2: Filter by createdBy, order by createdAt
- **Collection:** `jobs`
- **Fields:**
  - `createdBy` (Ascending)
  - `createdAt` (Descending)
- **Query:** `where('createdBy').orderBy('createdAt')`

#### Index 3: Filter by status AND createdBy, order by createdAt
- **Collection:** `jobs`
- **Fields:**
  - `status` (Ascending)
  - `createdBy` (Ascending)
  - `createdAt` (Descending)
- **Query:** `where('status').where('createdBy').orderBy('createdAt')`

---

### 2. Hospitals Collection

#### Index 1: Filter by managedBy, order by createdAt
- **Collection:** `hospitals`
- **Fields:**
  - `managedBy` (Ascending)
  - `createdAt` (Descending)
- **Query:** `where('managedBy').orderBy('createdAt')`

---

### 3. Shifts Collection

#### Index 1: Filter by doctorId, order by date
- **Collection:** `shifts`
- **Fields:**
  - `doctorId` (Ascending)
  - `date` (Ascending)
- **Query:** `where('doctorId').orderBy('date')`

#### Index 2: Filter by doctorId AND status, order by date
- **Collection:** `shifts`
- **Fields:**
  - `doctorId` (Ascending)
  - `status` (Ascending)
  - `date` (Ascending)
- **Query:** `where('doctorId').where('status').orderBy('date')`

---

### 4. Notifications Collection

#### Index 1: Filter by userId, order by timestamp
- **Collection:** `notifications`
- **Fields:**
  - `userId` (Ascending)
  - `timestamp` (Descending)
- **Query:** `where('userId').orderBy('timestamp')`

#### Index 2: Filter by userId AND read, order by timestamp
- **Collection:** `notifications`
- **Fields:**
  - `userId` (Ascending)
  - `read` (Ascending)
  - `timestamp` (Descending)
- **Query:** `where('userId').where('read').orderBy('timestamp')`

---

### 5. Admin Messages Collection

#### Index 1: Filter by userId, order by timestamp
- **Collection:** `admin_messages`
- **Fields:**
  - `userId` (Ascending)
  - `timestamp` (Ascending) - Note: ascending for stream, descending for get
- **Query:** `where('userId').orderBy('timestamp')`

---

### 6. Payments Collection

#### Index 1: Filter by doctorId, order by createdAt
- **Collection:** `payments`
- **Fields:**
  - `doctorId` (Ascending)
  - `createdAt` (Descending)
- **Query:** `where('doctorId').orderBy('createdAt')`

#### Index 2: Filter by doctorId AND status, order by createdAt
- **Collection:** `payments`
- **Fields:**
  - `doctorId` (Ascending)
  - `status` (Ascending)
  - `createdAt` (Descending)
- **Query:** `where('doctorId').where('status').orderBy('createdAt')`

---

### 7. Feedback Collection

#### Index 1: Order by date
- **Collection:** `feedback`
- **Fields:**
  - `date` (Descending)
- **Query:** `orderBy('date')`

---

### 8. HR Doctor Pool Collection

#### Index 1: Filter by hrId
- **Collection:** `hr_doctor_pool`
- **Fields:**
  - `hrId` (Ascending)
- **Query:** `where('hrId')`

---

## 🔧 Firebase CLI Indexes File

Create `firestore.indexes.json` in your project root:

```json
{
  "indexes": [
    {
      "collectionGroup": "jobs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "jobs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdBy", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "jobs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdBy", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "hospitals",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "managedBy", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "shifts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "shifts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "read", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "admin_messages",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "payments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "payments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "feedback",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "hr_doctor_pool",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "hrId", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

## 🔑 Firebase Authentication Setup

### Enable Authentication Methods

1. Go to **Firebase Console** → **Authentication** → **Sign-in method**
2. Enable the following providers:
   - **Email/Password** (for HR and Doctor login)
   - Optionally: **Google**, **Phone**, etc.

### Create Test Users

1. Go to **Authentication** → **Users**
2. Click **Add user**
3. Create test users with email/password
4. Note: You'll need to create corresponding documents in the `users` collection with `userType: 'hr'` or `userType: 'doctor'`

---

## 🚨 Troubleshooting

### "Missing or insufficient permissions"
- Check that security rules are deployed
- Verify user is authenticated: `FirebaseAuth.instance.currentUser != null`
- Check that the user has the correct `userType` in the `users` collection

### "The query requires an index"
- Click the link in the error message to create the index automatically
- Or manually create it using the indexes list above
- Wait for the index to build (check status in Firebase Console)

### "CONFIGURATION_NOT_FOUND" (Auth Error)
- This is usually a web configuration issue
- Verify `firebase_options.dart` has correct web API key
- Check Firebase Console → Project Settings → General → Your apps → Web app
- Ensure the API key matches

---

## ✅ Quick Start Checklist

- [ ] Deploy Firestore security rules
- [ ] Create all required indexes (or let Firestore create them automatically)
- [ ] Enable Email/Password authentication
- [ ] Create test users in Authentication
- [ ] Create corresponding user documents in Firestore `users` collection
- [ ] Test the app - it should now connect to Firebase!

