"""
MongoDB Seed Script
Populates MongoDB database with seed data
"""

from seed import generate_all_seed_data
from pymongo import MongoClient
import sys


def seed_mongodb(connection_string: str, database_name: str):
    """
    Seed MongoDB database
    
    Args:
        connection_string: MongoDB connection string (e.g., 'mongodb://localhost:27017/')
        database_name: Name of the database to seed
    """
    try:
        client = MongoClient(connection_string)
        db = client[database_name]
        
        seed_data = generate_all_seed_data()
        
        # Map seed data keys to MongoDB collection names
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
        
        print("\nSeeding MongoDB database...")
        
        for seed_key, collection_name in collection_mapping.items():
            records = seed_data.get(seed_key, [])
            if records:
                collection = db[collection_name]
                result = collection.insert_many(records)
                print(f"Inserted {len(result.inserted_ids)} documents into {collection_name}")
        
        print("\nMongoDB database seeded successfully!")
        
        client.close()
        
    except Exception as e:
        print(f"Error seeding MongoDB: {e}")
        sys.exit(1)


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Seed MongoDB database with sample data')
    parser.add_argument('--connection-string', type=str, default='mongodb://localhost:27017/',
                       help='MongoDB connection string')
    parser.add_argument('--database', type=str, required=True,
                       help='Database name')
    
    args = parser.parse_args()
    
    seed_mongodb(args.connection_string, args.database)

