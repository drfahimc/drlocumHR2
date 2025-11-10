# Backend Integration Analysis

## Backend Collections (from seed.py)

### ✅ Existing Collections (All Required)
1. **users** - HR and Doctor users
2. **doctors** - Doctor profiles  
3. **documents** - Doctor documents (not used in frontend yet)
4. **hospitals** - Hospital information
5. **jobs** - Job postings
6. **applications** - Job applications
7. **shifts** - Shift records
8. **payments** - Payment records
9. **notifications** - User notifications
10. **feedback** - Feedback/ratings (note: collection name is "feedback" not "feedbacks")
11. **admin_messages** - Admin messages (Reports & Analytics)
12. **hr_doctor_pool** - HR's doctor pool

## Frontend Models vs Backend Structure

### ✅ Models That Need Updates

#### 1. JobModel
**Backend Fields:**
- id, hospitalId, hospitalName, hospitalLogo, hospitalImage
- role, specialty, date, time, shift, duration
- pay, salary, distance, rating
- status (Open, Applied, Approved, Taken, Completed)
- applicants, applicantsCount
- location, description, requirements, qualifications
- approvedDoctorId, urgent, qrRequired
- dutyType (single/multiple)
- startDate, startTime, endDate, endTime
- selectedDays, paymentPerHour, totalHours, totalPay
- publishTo, specificDoctors
- createdAt, updatedAt, createdBy

**Frontend Currently Has:**
- id, specialty, duration, hospital, ward, dateRange, time, status, applicantCount
- doctorName, startDate, endDate

**Missing Fields:** Many fields need to be added

#### 2. HospitalModel
**Backend Fields:**
- id, managedBy, name, description, image, contactNumber
- location, address, latitude, longitude
- createdAt, updatedAt

**Frontend Currently Has:**
- id, name, description, phone, location, imageUrl, address, bedCount, specialties

**Missing Fields:** managedBy, latitude, longitude, createdAt, updatedAt
**Extra Fields:** bedCount, specialties (not in backend)

#### 3. DoctorPoolModel
**Backend Structure:**
- hr_doctor_pool collection: id, hrId, doctorId, addedAt
- doctors collection: id, userId, name, specialty, avatar, rating, verified, experience, phone, etc.

**Frontend Currently Has:**
- Combined model with id, doctorId, name, specialty, yearsOfExperience, avatarUrl, rating, phone, email

**Note:** Need to join hr_doctor_pool with doctors collection

#### 4. ApplicantModel
**Backend Structure:**
- applications collection: id, jobId, doctorId, appliedAt, status, coverNote
- Need to join with doctors collection for doctor details

**Frontend Currently Has:**
- id, name, qualifications, yearsOfExperience, avatarUrl, specialty

**Note:** Need to join applications with doctors

#### 5. NotificationModel
**Backend Fields:**
- id, userId, type, title, message, timestamp, read, actionUrl, relatedEntityId, relatedEntityType

**Frontend Currently Has:**
- id, type, title, description, date, isRead

**Missing Fields:** actionUrl, relatedEntityId, relatedEntityType

#### 6. MessageModel (Admin Messages)
**Backend Fields:**
- id, from (hr/admin), userId, message, timestamp, read, issueType

**Frontend Currently Has:**
- id, sender, message, timestamp

**Missing Fields:** from, userId, read, issueType

#### 7. FeedbackModel
**Backend Fields:**
- id, doctorId, doctorName, doctorAvatar, rating, comment, date, jobId, jobTitle, createdBy, createdAt

**Frontend Currently Has:**
- id, doctorName, specialty, rating, feedbackText, date

**Missing Fields:** doctorId, doctorAvatar, jobId, jobTitle, createdBy, createdAt

## Recommendations

### ✅ Keep All Collections
All collections in seed.py are needed and match frontend requirements.

### ✅ Add Missing Fields to Models
Update models to include all backend fields for proper integration.

### ✅ Create Firebase Services
Create service layer for:
- JobsService
- HospitalsService
- DoctorsService
- ApplicationsService
- NotificationsService
- MessagesService
- FeedbackService
- PaymentsService
- ShiftsService

### ✅ Update Models
Update all models to match backend structure exactly.

