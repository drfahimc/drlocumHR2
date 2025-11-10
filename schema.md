# Database Schema Documentation

## User Types

The application supports two main user types:
- **HR (Human Resources)**: Manages jobs, hospitals, doctors, and payments
- **Doctor**: Applies for jobs, manages shifts, and tracks applications

---

## Database Tables

### 1. Users

Base user authentication and profile information.

```typescript
interface User {
  id: string;
  email: string;
  mobile: string;
  password: string; // hashed
  userType: 'hr' | 'doctor';
  createdAt: string;
  updatedAt: string;
  isActive: boolean;
  isVerified: boolean; // for doctor registration
}
```

### 2. Doctors

Extended doctor profile information.

```typescript
interface Doctor {
  id: string;
  userId: string; // FK to Users
  name: string;
  specialty: string;
  avatar?: string;
  rating: number; // average rating
  verified: boolean;
  experience: number; // years
  appliedJobs?: string[]; // array of job IDs
  approvedJobs?: string[]; // array of job IDs
  completedShifts?: number;
  documents?: Document[];
  phone?: string;
  registrationNumber?: string;
  location?: string;
  about?: string;
  qualifications?: string[]; // e.g., ['MBBS', 'MD']
  skills?: string[];
  hospitals?: string[]; // array of hospital IDs where they've worked
}
```

**Doctor Registration Fields:**
- Step 1: fullName, mobile, email, degree, specialization
- Step 2: medicalCollege, currentLocation, registrationNumber, councilName, yearsOfExperience
- Step 3: profilePicture, governmentId, medicalRegistration, medicalDegree, experienceCertificates

### 3. Documents

Medical licenses, certificates, ID proofs, and education documents.

```typescript
interface Document {
  id: string;
  doctorId: string; // FK to Doctors
  name: string;
  type: 'License' | 'Certificate' | 'ID Proof' | 'Education';
  url: string; // file storage URL
  uploadedAt: string;
  verified: boolean; // admin verification status
}
```

### 4. Hospitals

Hospital information managed by HR.

```typescript
interface Hospital {
  id: string;
  name: string;
  description: string;
  image: string; // hospital image URL
  contactNumber: string;
  location: string;
  address: string;
  latitude: number;
  longitude: number;
  managedBy: string; // HR user ID
  createdAt: string;
  updatedAt: string;
}
```

### 5. Jobs

Job postings created by HR.

```typescript
interface Job {
  id: string;
  hospitalId: string; // FK to Hospitals
  hospitalName: string; // denormalized for quick access
  hospitalLogo?: string;
  hospitalImage?: string;
  role: string; // e.g., 'Duty Doctor', 'RMO', 'JR', 'SR', 'Emergency Medicine Doctor', 'ICU Doctor'
  specialty?: string;
  date: string; // start date
  time?: string; // e.g., '9am to 5pm'
  shift?: 'Morning' | 'Evening' | 'Night';
  duration?: string; // e.g., '8h'
  pay?: number; // payment per hour
  salary?: number; // total payment
  distance?: number; // from doctor's location (km)
  rating?: number; // hospital rating
  status: 'Open' | 'Applied' | 'Approved' | 'Taken' | 'Completed' | 'Cancelled';
  applicants?: number; // number of applicants
  applicantsCount?: number;
  location: string;
  description?: string;
  requirements?: string[];
  qualifications?: string[]; // required qualifications
  approvedDoctorId?: string; // FK to Doctors (nullable)
  urgent?: boolean;
  qrRequired?: boolean; // QR code attendance required
  dutyType: 'single' | 'multiple'; // single shift or multiple days
  startDate: string;
  startTime: string;
  endDate: string;
  endTime: string;
  selectedDays?: string[]; // for multiple day shifts
  paymentPerHour: number;
  totalHours: number;
  totalPay: number;
  publishTo: 'all' | 'pool' | 'specific'; // visibility
  specificDoctors?: string[]; // array of doctor IDs if publishTo is 'specific'
  createdAt: string;
  updatedAt: string;
  createdBy: string; // HR user ID
}
```

**Job Form Data (for creating/editing):**
- hospitalId
- dutyType (single/multiple)
- startDate, startTime, endDate, endTime
- selectedDays (for multiple day shifts)
- paymentPerHour
- totalHours (calculated)
- totalPay (calculated)
- qrAttendance (boolean)
- role
- qualifications (array)
- publishTo ('all' | 'pool' | 'specific')
- specificDoctors (array of IDs)
- additionalInfo

### 6. Applications

Doctor applications for jobs.

```typescript
interface Application {
  id: string;
  jobId: string; // FK to Jobs
  doctorId: string; // FK to Doctors
  appliedAt: string; // ISO timestamp
  status: 'Pending' | 'Approved' | 'Rejected';
  coverNote?: string; // optional message from doctor
}
```

### 7. Shifts

Shift instances for completed jobs.

```typescript
interface Shift {
  id: string;
  jobId: string; // FK to Jobs
  doctorId: string; // FK to Doctors
  date: string;
  startTime?: string;
  endTime?: string;
  actualStartTime?: string; // when doctor checked in
  actualEndTime?: string; // when doctor checked out
  status: 'Scheduled' | 'Started' | 'Exit Pending' | 'Completed';
  checkIn?: string; // check-in timestamp
  checkOut?: string; // check-out timestamp
  proofOfCompletion?: {
    photo?: string; // photo URL
    timesheet?: string; // timesheet URL
    note?: string;
  };
  createdAt: string;
  updatedAt: string;
}
```

**Shift Day (for multi-day shifts):**
```typescript
interface ShiftDay {
  date: string;
  startTime: string;
  endTime: string;
  hours: number;
  pay: number;
  status: 'Not Started' | 'In Progress' | 'Completed' | 'Cancelled';
  checkIn?: string;
  checkOut?: string;
}
```

### 8. Payments

Payment records for completed shifts.

```typescript
interface Payment {
  id: string;
  shiftId: string; // FK to Shifts
  jobId: string; // FK to Jobs
  doctorId: string; // FK to Doctors
  amount: number;
  status: 'Pending' | 'Processing' | 'Paid';
  dueDate: string;
  paidDate?: string;
  createdAt: string;
  updatedAt: string;
}
```

### 9. Notifications

User notifications for various events.

```typescript
interface Notification {
  id: string;
  userId: string; // FK to Users
  type: 'application' | 'approval' | 'shift' | 'payment' | 'message';
  title: string;
  message: string;
  timestamp: string; // ISO timestamp
  read: boolean;
  actionUrl?: string; // optional deep link
  relatedEntityId?: string; // ID of related job, application, etc.
  relatedEntityType?: string; // 'job', 'application', 'shift', 'payment'
}
```

### 10. Feedback

Ratings and feedback from HR to doctors.

```typescript
interface Feedback {
  id: string;
  doctorId: string; // FK to Doctors
  doctorName: string; // denormalized
  doctorAvatar: string; // denormalized
  rating: number; // 1-5
  comment: string;
  date: string;
  jobId: string; // FK to Jobs
  jobTitle: string; // denormalized
  createdBy: string; // HR user ID
  createdAt: string;
}
```

### 11. AdminMessages

Messages between HR and admin/support.

```typescript
interface AdminMessage {
  id: string;
  from: 'hr' | 'admin';
  userId?: string; // FK to Users (if from HR)
  message: string;
  timestamp: string; // ISO timestamp
  read: boolean;
  issueType?: string; // for issue reports
}
```

### 12. HRDoctorPool

Junction table for HR's curated doctor pool.

```typescript
interface HRDoctorPool {
  id: string;
  hrId: string; // FK to Users (HR)
  doctorId: string; // FK to Doctors
  addedAt: string;
}
```

---

## Views by User Type

### HR Views

1. **Dashboard** (`home`)
   - Summary widgets (active jobs, pending approvals, payments)
   - Recent jobs list
   - Quick actions

2. **Active Jobs** (`active-jobs`)
   - All jobs with status 'Open' and approvedDoctorId

3. **My Jobs** (`my-jobs`)
   - Tabs: To Approve, Approved, Cancelled, Completed
   - Filter by status

4. **Job Details** (`job-detail-variant`, `job-card`)
   - Variants: to-approve, approved, cancelled, completed
   - Shows applicants, approved doctor, shifts timeline, payment status

5. **Doctors** (`doctors`)
   - Browse all doctors in the system

6. **My Doctors Pool** (`my-doctors`)
   - HR's curated list of preferred doctors
   - Add/remove doctors

7. **Payments** (`payments`)
   - List all payments
   - Filter by status
   - Mark as paid

8. **Payments & Shifts** (`summary`)
   - Combined view of shifts and payments
   - Filter by date range

9. **Notifications** (`notifications`)
   - All notifications
   - Mark as read

10. **Reports & Analytics** (`reports`)
    - Send messages to admin
    - View logs
    - View terms

11. **Hospital Information** (`hospital`)
    - List all hospitals
    - Add/edit/delete hospitals

12. **Ratings & Feedback** (`ratings`)
    - View feedback given to doctors

13. **Settings** (`settings`)
    - App settings

14. **Post Job** (`post-job`)
    - Create new job posting

### Doctor Views

1. **Dashboard** (`doctor-dashboard`)
   - Available jobs list
   - Search and filters

2. **Job Details** (`doctor-job-details`)
   - View job details
   - Apply for job
   - Get directions

3. **Applications** (`doctor-applications`)
   - View all applications
   - Tabs: All, Pending, Approved, Completed

4. **Pending Applications** (`doctor-pending-applications`)
   - View pending applications
   - Cancel application
   - Report issue

5. **Approved Applications** (`doctor-approved-applications`)
   - View approved applications
   - Contact hospital
   - View shift details
   - Report issue

6. **Completed Application Detail** (`doctor-completed-application-detail`)
   - View completed application details
   - View feedback
   - Report issue

7. **Shifts** (`doctor-shifts`)
   - View all shifts
   - Start/end shifts
   - Check-in/check-out

8. **Report Issue** (`doctor-report-issue`)
   - Submit issue report

9. **Profile** (`doctor-profile`)
   - View and edit profile

---

## Relationships

- Users (1) → (1) Doctors
- Users (1) → (N) Hospitals (managedBy)
- Hospitals (1) → (N) Jobs
- Jobs (1) → (N) Applications
- Jobs (1) → (0..1) Doctors (approvedDoctorId)
- Doctors (1) → (N) Applications
- Jobs (1) → (N) Shifts
- Shifts (1) → (1) Payments
- Users (1) → (N) Notifications
- Jobs (1) → (N) Feedback
- HR (1) → (N) HRDoctorPool → (N) Doctors

---

## Status Enums

### Job Status
- `Open`: Job is available
- `Applied`: Doctor has applied (not used in current implementation)
- `Approved`: Doctor approved for job
- `Taken`: Job assigned
- `Completed`: Job completed
- `Cancelled`: Job cancelled

### Application Status
- `Pending`: Waiting for HR approval
- `Approved`: Approved by HR
- `Rejected`: Rejected by HR

### Shift Status
- `Scheduled`: Shift scheduled but not started
- `Started`: Shift in progress
- `Exit Pending`: Waiting for exit approval
- `Completed`: Shift completed

### Payment Status
- `Pending`: Payment pending
- `Processing`: Payment processing
- `Paid`: Payment completed

### Notification Type
- `application`: New application received
- `approval`: Application approved/rejected
- `shift`: Shift started/completed
- `payment`: Payment status update
- `message`: General message

---

## Indexes Recommended

- Users: `email`, `mobile`, `userType`
- Doctors: `userId`, `specialty`, `registrationNumber`
- Jobs: `hospitalId`, `status`, `createdBy`, `date`
- Applications: `jobId`, `doctorId`, `status`
- Shifts: `jobId`, `doctorId`, `date`, `status`
- Payments: `shiftId`, `doctorId`, `status`, `dueDate`
- Notifications: `userId`, `read`, `timestamp`

