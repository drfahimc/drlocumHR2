"""
Firebase/Firestore Seed Script
Populates Firestore database with seed data
"""

from seed import generate_all_seed_data
import firebase_admin
from firebase_admin import credentials, firestore
import sys
import os


def convert_to_firestore_value(value):
    """Convert Python values to Firestore-compatible types"""
    if value is None:
        return None
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        return {k: convert_to_firestore_value(v) for k, v in value.items()}
    if isinstance(value, list):
        return [convert_to_firestore_value(item) for item in value]
    return str(value)


def seed_firestore(credential_path: str = None):
    """
    Seed Firestore database
    
    Args:
        credential_path: Path to Firebase service account JSON file
    """
    try:
        # Initialize Firebase Admin
        if credential_path and os.path.exists(credential_path):
            cred = credentials.Certificate(credential_path)
            firebase_admin.initialize_app(cred)
            print(f"[OK] Initialized Firebase with credentials: {credential_path}")
        else:
            # Try to use default credentials
            try:
                firebase_admin.initialize_app()
                print("[OK] Initialized Firebase with default credentials")
            except:
                raise Exception("No credentials provided and no default credentials found")
        
        db = firestore.client()
        
        seed_data = generate_all_seed_data()
        
        # Map seed data keys to Firestore collection names
        collection_mapping = {
            "users": "users",
            "doctors": "doctors",
            "documents": "documents",
            "hospitals": "hospitals",
            "jobs": "jobs",
            "applications": "applications",
            "shifts": "shifts",
            "payments": "payments",
            "notifications": "notifications",
            "feedbacks": "feedback",
            "admin_messages": "admin_messages",
            "hr_doctor_pool": "hr_doctor_pool",
        }
        
        print("\n" + "="*60)
        print("SEEDING FIRESTORE DATABASE")
        print("="*60)
        
        total_inserted = 0
        
        for seed_key, collection_name in collection_mapping.items():
            records = seed_data.get(seed_key, [])
            if records:
                collection_ref = db.collection(collection_name)
                batch = db.batch()
                batch_count = 0
                inserted_count = 0
                
                # Firestore batch limit is 500 operations
                for record in records:
                    # Convert values to Firestore-compatible types
                    firestore_record = convert_to_firestore_value(record)
                    
                    # Use record ID as document ID if available
                    doc_id = record.get("id")
                    if doc_id:
                        doc_ref = collection_ref.document(doc_id)
                    else:
                        doc_ref = collection_ref.document()
                    
                    batch.set(doc_ref, firestore_record)
                    batch_count += 1
                    inserted_count += 1
                    
                    # Commit batch if we reach 500 operations
                    if batch_count >= 500:
                        batch.commit()
                        batch = db.batch()
                        batch_count = 0
                
                # Commit remaining operations
                if batch_count > 0:
                    batch.commit()
                
                print(f"[OK] Inserted {inserted_count} documents into '{collection_name}'")
                total_inserted += inserted_count
        
        print("\n" + "="*60)
        print(f"[OK] Firestore database seeded successfully!")
        print(f"  Total documents inserted: {total_inserted}")
        print("="*60)
        
    except Exception as e:
        print(f"\n[ERROR] Error seeding Firestore: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Seed Firestore database with sample data')
    parser.add_argument('--credentials', type=str, default='API.json',
                       help='Path to Firebase service account JSON file (default: API.json)')
    
    args = parser.parse_args()
    
    seed_firestore(args.credentials)

