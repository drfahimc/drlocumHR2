"""
Database Seed Script
Generates sample data for all tables based on schema.md
"""

import uuid
from datetime import datetime, timedelta
from typing import List, Dict, Any
import hashlib


def hash_password(password: str) -> str:
    """Simple password hashing (use bcrypt in production)"""
    return hashlib.sha256(password.encode()).hexdigest()


def generate_id() -> str:
    """Generate a UUID string"""
    return str(uuid.uuid4())


def get_current_timestamp() -> str:
    """Get current ISO timestamp"""
    return datetime.utcnow().isoformat() + "Z"


def get_future_timestamp(days: int = 0, hours: int = 0) -> str:
    """Get future ISO timestamp"""
    dt = datetime.utcnow() + timedelta(days=days, hours=hours)
    return dt.isoformat() + "Z"


def get_past_timestamp(days: int = 0, hours: int = 0) -> str:
    """Get past ISO timestamp"""
    dt = datetime.utcnow() - timedelta(days=days, hours=hours)
    return dt.isoformat() + "Z"


# ============================================================================
# SEED DATA GENERATORS
# ============================================================================


def seed_users() -> List[Dict[str, Any]]:
    """Generate seed data for Users table"""
    users = []
    
    # HR Users
    hr_users = [
        {
            "id": generate_id(),
            "email": "hr1@hospital.com",
            "mobile": "+1234567890",
            "password": hash_password("password123"),
            "userType": "hr",
            "createdAt": get_past_timestamp(days=30),
            "updatedAt": get_past_timestamp(days=1),
            "isActive": True,
            "isVerified": True,
        },
        {
            "id": generate_id(),
            "email": "hr2@clinic.com",
            "mobile": "+1234567891",
            "password": hash_password("password123"),
            "userType": "hr",
            "createdAt": get_past_timestamp(days=25),
            "updatedAt": get_past_timestamp(days=2),
            "isActive": True,
            "isVerified": True,
        },
        {
            "id": generate_id(),
            "email": "hr3@medical.com",
            "mobile": "+1234567892",
            "password": hash_password("password123"),
            "userType": "hr",
            "createdAt": get_past_timestamp(days=20),
            "updatedAt": get_past_timestamp(days=3),
            "isActive": True,
            "isVerified": True,
        },
    ]
    
    # Doctor Users
    doctor_users = [
        {
            "id": generate_id(),
            "email": "doctor1@example.com",
            "mobile": "+1234567900",
            "password": hash_password("password123"),
            "userType": "doctor",
            "createdAt": get_past_timestamp(days=60),
            "updatedAt": get_past_timestamp(days=5),
            "isActive": True,
            "isVerified": True,
        },
        {
            "id": generate_id(),
            "email": "doctor2@example.com",
            "mobile": "+1234567901",
            "password": hash_password("password123"),
            "userType": "doctor",
            "createdAt": get_past_timestamp(days=55),
            "updatedAt": get_past_timestamp(days=6),
            "isActive": True,
            "isVerified": True,
        },
        {
            "id": generate_id(),
            "email": "doctor3@example.com",
            "mobile": "+1234567902",
            "password": hash_password("password123"),
            "userType": "doctor",
            "createdAt": get_past_timestamp(days=50),
            "updatedAt": get_past_timestamp(days=7),
            "isActive": True,
            "isVerified": True,
        },
        {
            "id": generate_id(),
            "email": "doctor4@example.com",
            "mobile": "+1234567903",
            "password": hash_password("password123"),
            "userType": "doctor",
            "createdAt": get_past_timestamp(days=45),
            "updatedAt": get_past_timestamp(days=8),
            "isActive": True,
            "isVerified": True,
        },
        {
            "id": generate_id(),
            "email": "doctor5@example.com",
            "mobile": "+1234567904",
            "password": hash_password("password123"),
            "userType": "doctor",
            "createdAt": get_past_timestamp(days=40),
            "updatedAt": get_past_timestamp(days=9),
            "isActive": True,
            "isVerified": False,  # Not yet verified
        },
    ]
    
    users.extend(hr_users)
    users.extend(doctor_users)
    return users


def seed_doctors(users: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Doctors table"""
    doctor_users = [u for u in users if u["userType"] == "doctor"]
    
    specialties = [
        "Emergency Medicine",
        "General Medicine",
        "Pediatrics",
        "Cardiology",
        "Orthopedics",
        "Neurology",
        "ICU",
        "Surgery",
    ]
    
    doctors = []
    for i, user in enumerate(doctor_users):
        doctor = {
            "id": generate_id(),
            "userId": user["id"],
            "name": f"Dr. {'John' if i % 2 == 0 else 'Sarah'} {'Smith' if i < 2 else 'Johnson' if i < 4 else 'Williams'}",
            "specialty": specialties[i % len(specialties)],
            "avatar": f"https://example.com/avatars/doctor{i+1}.jpg",
            "rating": round(4.0 + (i * 0.2), 1),
            "verified": user["isVerified"],
            "experience": 5 + (i * 2),
            "appliedJobs": [],
            "approvedJobs": [],
            "completedShifts": i * 3,
            "phone": user["mobile"],
            "registrationNumber": f"REG{i+1:04d}",
            "location": f"City {i+1}",
            "about": f"Experienced {specialties[i % len(specialties)]} specialist with {5 + (i * 2)} years of practice.",
            "qualifications": ["MBBS", "MD"] if i < 3 else ["MBBS"],
            "skills": [specialties[i % len(specialties)], "Patient Care", "Emergency Response"],
            "hospitals": [],
        }
        doctors.append(doctor)
    
    return doctors


def seed_documents(doctors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Documents table"""
    documents = []
    
    doc_types = ["License", "Certificate", "ID Proof", "Education"]
    
    for doctor in doctors:
        # Add 2-4 documents per doctor
        num_docs = 2 + (len(documents) % 3)
        for i in range(num_docs):
            doc = {
                "id": generate_id(),
                "doctorId": doctor["id"],
                "name": f"{doc_types[i % len(doc_types)]} - {doctor['name']}",
                "type": doc_types[i % len(doc_types)],
                "url": f"https://example.com/documents/{doctor['id']}/{i+1}.pdf",
                "uploadedAt": get_past_timestamp(days=30 - i),
                "verified": doctor["verified"] and i % 2 == 0,  # Alternate verified status
            }
            documents.append(doc)
    
    return documents


def seed_hospitals(users: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Hospitals table"""
    hr_users = [u for u in users if u["userType"] == "hr"]
    
    hospital_data = [
        {
            "name": "City General Hospital",
            "description": "A leading general hospital providing comprehensive healthcare services.",
            "image": "https://example.com/hospitals/hospital1.jpg",
            "contactNumber": "+1234567000",
            "location": "Downtown",
            "address": "123 Main Street, Downtown",
            "latitude": 40.7128,
            "longitude": -74.0060,
        },
        {
            "name": "Sunshine Medical Center",
            "description": "Modern medical facility specializing in emergency care.",
            "image": "https://example.com/hospitals/hospital2.jpg",
            "contactNumber": "+1234567001",
            "location": "Uptown",
            "address": "456 Oak Avenue, Uptown",
            "latitude": 40.7580,
            "longitude": -73.9855,
        },
        {
            "name": "Regional Healthcare Clinic",
            "description": "Community-focused clinic providing quality primary care.",
            "image": "https://example.com/hospitals/hospital3.jpg",
            "contactNumber": "+1234567002",
            "location": "Suburbs",
            "address": "789 Elm Road, Suburbs",
            "latitude": 40.6892,
            "longitude": -74.0445,
        },
    ]
    
    hospitals = []
    for i, hr_user in enumerate(hr_users[:len(hospital_data)]):
        hospital = {
            "id": generate_id(),
            "managedBy": hr_user["id"],
            "createdAt": get_past_timestamp(days=30 - i),
            "updatedAt": get_past_timestamp(days=10 - i),
            **hospital_data[i],
        }
        hospitals.append(hospital)
    
    return hospitals


def seed_jobs(hospitals: List[Dict[str, Any]], users: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Jobs table"""
    hr_users = [u for u in users if u["userType"] == "hr"]
    
    roles = ["Duty Doctor", "RMO", "JR", "SR", "Emergency Medicine Doctor", "ICU Doctor"]
    shifts = ["Morning", "Evening", "Night"]
    duty_types = ["single", "multiple"]
    publish_to_options = ["all", "pool", "specific"]
    
    jobs = []
    
    for i, hospital in enumerate(hospitals):
        hr_user = hr_users[i % len(hr_users)]
        
        # Create 3-5 jobs per hospital
        for j in range(3 + (i % 3)):
            duty_type = duty_types[j % len(duty_types)]
            start_date = datetime.utcnow() + timedelta(days=j + 1)
            end_date = start_date + timedelta(days=1 if duty_type == "single" else 3)
            
            job = {
                "id": generate_id(),
                "hospitalId": hospital["id"],
                "hospitalName": hospital["name"],
                "hospitalLogo": f"https://example.com/logos/hospital{i+1}.png",
                "hospitalImage": hospital["image"],
                "role": roles[j % len(roles)],
                "specialty": "Emergency Medicine" if j % 2 == 0 else "General Medicine",
                "date": start_date.isoformat() + "Z",
                "time": f"{9 + (j * 4)}am to {5 + (j * 4)}pm",
                "shift": shifts[j % len(shifts)],
                "duration": "8h",
                "pay": 50 + (j * 10),
                "salary": (50 + (j * 10)) * 8,
                "distance": round(5.0 + (j * 2.5), 1),
                "rating": round(4.0 + (j * 0.1), 1),
                "status": ["Open", "Applied", "Approved", "Taken", "Completed"][j % 5],
                "applicants": j + 1,
                "applicantsCount": j + 1,
                "location": hospital["location"],
                "description": f"Looking for {roles[j % len(roles)]} for {hospital['name']}.",
                "requirements": ["MBBS", "MD"] if j < 2 else ["MBBS"],
                "qualifications": ["MBBS", "MD"] if j < 2 else ["MBBS"],
                "approvedDoctorId": None,  # Will be set later if status is Approved/Taken
                "urgent": j % 3 == 0,
                "qrRequired": j % 2 == 0,
                "dutyType": duty_type,
                "startDate": start_date.isoformat() + "Z",
                "startTime": f"{9 + (j * 4)}:00",
                "endDate": end_date.isoformat() + "Z",
                "endTime": f"{17 + (j * 4)}:00",
                "selectedDays": ["Monday", "Wednesday", "Friday"] if duty_type == "multiple" else None,
                "paymentPerHour": 50 + (j * 10),
                "totalHours": 8 if duty_type == "single" else 24,
                "totalPay": (50 + (j * 10)) * (8 if duty_type == "single" else 24),
                "publishTo": publish_to_options[j % len(publish_to_options)],
                "specificDoctors": None if publish_to_options[j % len(publish_to_options)] != "specific" else [],
                "createdAt": get_past_timestamp(days=10 - j),
                "updatedAt": get_past_timestamp(days=5 - j),
                "createdBy": hr_user["id"],
            }
            jobs.append(job)
    
    return jobs


def seed_applications(jobs: List[Dict[str, Any]], doctors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Applications table"""
    applications = []
    
    statuses = ["Pending", "Approved", "Rejected"]
    
    # Create applications for Open and Applied status jobs
    open_jobs = [j for j in jobs if j["status"] in ["Open", "Applied"]]
    
    for i, job in enumerate(open_jobs[:10]):  # Limit to 10 applications
        doctor = doctors[i % len(doctors)]
        status = statuses[i % len(statuses)]
        
        application = {
            "id": generate_id(),
            "jobId": job["id"],
            "doctorId": doctor["id"],
            "appliedAt": get_past_timestamp(days=5 - (i % 5)),
            "status": status,
            "coverNote": f"Interested in {job['role']} position at {job['hospitalName']}." if i % 2 == 0 else None,
        }
        applications.append(application)
        
        # Update job status if application exists
        if status == "Approved":
            job["status"] = "Approved"
            job["approvedDoctorId"] = doctor["id"]
    
    return applications


def seed_shifts(jobs: List[Dict[str, Any]], doctors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Shifts table"""
    shifts = []
    
    # Get approved/taken jobs
    approved_jobs = [j for j in jobs if j["status"] in ["Approved", "Taken", "Completed"] and j.get("approvedDoctorId")]
    
    shift_statuses = ["Scheduled", "Started", "Exit Pending", "Completed"]
    
    for i, job in enumerate(approved_jobs[:5]):  # Limit to 5 shifts
        doctor_id = job["approvedDoctorId"]
        status = shift_statuses[i % len(shift_statuses)]
        
        start_time = datetime.fromisoformat(job["startDate"].replace("Z", "+00:00"))
        end_time = datetime.fromisoformat(job["endDate"].replace("Z", "+00:00"))
        
        shift = {
            "id": generate_id(),
            "jobId": job["id"],
            "doctorId": doctor_id,
            "date": job["startDate"],
            "startTime": job["startTime"],
            "endTime": job["endTime"],
            "actualStartTime": start_time.isoformat() + "Z" if status in ["Started", "Exit Pending", "Completed"] else None,
            "actualEndTime": end_time.isoformat() + "Z" if status == "Completed" else None,
            "status": status,
            "checkIn": start_time.isoformat() + "Z" if status in ["Started", "Exit Pending", "Completed"] else None,
            "checkOut": end_time.isoformat() + "Z" if status == "Completed" else None,
            "proofOfCompletion": {
                "photo": f"https://example.com/proof/{job['id']}.jpg",
                "timesheet": f"https://example.com/timesheets/{job['id']}.pdf",
                "note": "Shift completed successfully",
            } if status == "Completed" else None,
            "createdAt": get_past_timestamp(days=3 - i),
            "updatedAt": get_past_timestamp(days=1 - i),
        }
        shifts.append(shift)
    
    return shifts


def seed_payments(shifts: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Payments table"""
    payments = []
    
    payment_statuses = ["Pending", "Processing", "Paid"]
    
    completed_shifts = [s for s in shifts if s["status"] == "Completed"]
    
    for i, shift in enumerate(completed_shifts):
        # Find the job to get payment info
        job_id = shift["jobId"]
        
        status = payment_statuses[i % len(payment_statuses)]
        due_date = datetime.fromisoformat(shift["date"].replace("Z", "+00:00")) + timedelta(days=7)
        paid_date = due_date - timedelta(days=2) if status == "Paid" else None
        
        payment = {
            "id": generate_id(),
            "shiftId": shift["id"],
            "jobId": job_id,
            "doctorId": shift["doctorId"],
            "amount": 400 + (i * 50),  # Estimated amount
            "status": status,
            "dueDate": due_date.isoformat() + "Z",
            "paidDate": paid_date.isoformat() + "Z" if paid_date else None,
            "createdAt": get_past_timestamp(days=2 - i),
            "updatedAt": get_past_timestamp(days=1 - i),
        }
        payments.append(payment)
    
    return payments


def seed_notifications(users: List[Dict[str, Any]], jobs: List[Dict[str, Any]], applications: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Notifications table"""
    notifications = []
    
    notification_types = ["application", "approval", "shift", "payment", "message"]
    
    for i, user in enumerate(users[:8]):  # Limit to 8 notifications
        notification = {
            "id": generate_id(),
            "userId": user["id"],
            "type": notification_types[i % len(notification_types)],
            "title": f"New {notification_types[i % len(notification_types)].title()}",
            "message": f"You have a new {notification_types[i % len(notification_types)]}.",
            "timestamp": get_past_timestamp(days=3 - (i % 3)),
            "read": i % 2 == 0,
            "actionUrl": f"/{notification_types[i % len(notification_types)]}/{i+1}",
            "relatedEntityId": jobs[i % len(jobs)]["id"] if jobs else None,
            "relatedEntityType": "job" if jobs else None,
        }
        notifications.append(notification)
    
    return notifications


def seed_feedback(doctors: List[Dict[str, Any]], jobs: List[Dict[str, Any]], users: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for Feedback table"""
    feedbacks = []
    
    hr_users = [u for u in users if u["userType"] == "hr"]
    completed_jobs = [j for j in jobs if j["status"] == "Completed"]
    
    for i, job in enumerate(completed_jobs[:3]):  # Limit to 3 feedbacks
        doctor = doctors[i % len(doctors)]
        hr_user = hr_users[i % len(hr_users)]
        
        feedback = {
            "id": generate_id(),
            "doctorId": doctor["id"],
            "doctorName": doctor["name"],
            "doctorAvatar": doctor["avatar"],
            "rating": 4 + (i % 2),
            "comment": f"Excellent work on {job['role']} position. Very professional and reliable.",
            "date": get_past_timestamp(days=5 - i),
            "jobId": job["id"],
            "jobTitle": job["role"],
            "createdBy": hr_user["id"],
            "createdAt": get_past_timestamp(days=5 - i),
        }
        feedbacks.append(feedback)
    
    return feedbacks


def seed_admin_messages(users: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for AdminMessages table"""
    messages = []
    
    hr_users = [u for u in users if u["userType"] == "hr"]
    issue_types = ["Payment", "Technical", "Account", "Other"]
    
    for i, hr_user in enumerate(hr_users[:3]):  # Limit to 3 messages
        message = {
            "id": generate_id(),
            "from": "hr",
            "userId": hr_user["id"],
            "message": f"Need assistance with {issue_types[i % len(issue_types)].lower()} issue.",
            "timestamp": get_past_timestamp(days=2 - i),
            "read": i % 2 == 0,
            "issueType": issue_types[i % len(issue_types)],
        }
        messages.append(message)
        
        # Add admin response
        admin_message = {
            "id": generate_id(),
            "from": "admin",
            "userId": None,
            "message": f"Thank you for contacting us. We'll look into your {issue_types[i % len(issue_types)].lower()} issue.",
            "timestamp": get_past_timestamp(days=1 - i),
            "read": True,
            "issueType": issue_types[i % len(issue_types)],
        }
        messages.append(admin_message)
    
    return messages


def seed_hr_doctor_pool(users: List[Dict[str, Any]], doctors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate seed data for HRDoctorPool table"""
    pool_entries = []
    
    hr_users = [u for u in users if u["userType"] == "hr"]
    
    # Each HR user has 2-3 doctors in their pool
    for i, hr_user in enumerate(hr_users):
        num_doctors = 2 + (i % 2)
        for j in range(num_doctors):
            pool_entry = {
                "id": generate_id(),
                "hrId": hr_user["id"],
                "doctorId": doctors[(i * num_doctors + j) % len(doctors)]["id"],
                "addedAt": get_past_timestamp(days=20 - (i * num_doctors + j)),
            }
            pool_entries.append(pool_entry)
    
    return pool_entries


# ============================================================================
# MAIN SEED FUNCTION
# ============================================================================

def generate_all_seed_data() -> Dict[str, List[Dict[str, Any]]]:
    """Generate all seed data in correct order"""
    
    print("Generating seed data...")
    
    # Generate in dependency order
    users = seed_users()
    print(f"Generated {len(users)} users")
    
    doctors = seed_doctors(users)
    print(f"Generated {len(doctors)} doctors")
    
    documents = seed_documents(doctors)
    print(f"Generated {len(documents)} documents")
    
    hospitals = seed_hospitals(users)
    print(f"Generated {len(hospitals)} hospitals")
    
    jobs = seed_jobs(hospitals, users)
    print(f"Generated {len(jobs)} jobs")
    
    applications = seed_applications(jobs, doctors)
    print(f"Generated {len(applications)} applications")
    
    shifts = seed_shifts(jobs, doctors)
    print(f"Generated {len(shifts)} shifts")
    
    payments = seed_payments(shifts)
    print(f"Generated {len(payments)} payments")
    
    notifications = seed_notifications(users, jobs, applications)
    print(f"Generated {len(notifications)} notifications")
    
    feedbacks = seed_feedback(doctors, jobs, users)
    print(f"Generated {len(feedbacks)} feedbacks")
    
    admin_messages = seed_admin_messages(users)
    print(f"Generated {len(admin_messages)} admin messages")
    
    hr_doctor_pool = seed_hr_doctor_pool(users, doctors)
    print(f"Generated {len(hr_doctor_pool)} HR doctor pool entries")
    
    return {
        "users": users,
        "doctors": doctors,
        "documents": documents,
        "hospitals": hospitals,
        "jobs": jobs,
        "applications": applications,
        "shifts": shifts,
        "payments": payments,
        "notifications": notifications,
        "feedbacks": feedbacks,
        "admin_messages": admin_messages,
        "hr_doctor_pool": hr_doctor_pool,
    }


if __name__ == "__main__":
    """Example usage - print seed data as JSON"""
    import json
    
    seed_data = generate_all_seed_data()
    
    # Print summary
    print("\n" + "="*50)
    print("SEED DATA SUMMARY")
    print("="*50)
    for table_name, records in seed_data.items():
        print(f"{table_name}: {len(records)} records")
    
    # Optionally save to JSON file
    with open("seed_data.json", "w") as f:
        json.dump(seed_data, f, indent=2, default=str)
    
    print("\nSeed data saved to seed_data.json")

