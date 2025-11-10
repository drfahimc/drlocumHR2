"""
SQLAlchemy Seed Script
Populates database using SQLAlchemy ORM
"""

from seed import generate_all_seed_data
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import sys


def seed_database(database_url: str, echo: bool = False):
    """
    Seed database using SQLAlchemy
    
    Args:
        database_url: Database connection URL (e.g., 'sqlite:///app.db' or 'postgresql://user:pass@localhost/db')
        echo: Whether to echo SQL queries
    """
    try:
        engine = create_engine(database_url, echo=echo)
        Session = sessionmaker(bind=engine)
        session = Session()
        
        seed_data = generate_all_seed_data()
        
        # Import your models here (adjust based on your actual model structure)
        # Example:
        # from models import User, Doctor, Hospital, Job, Application, Shift, Payment, Notification, Feedback, AdminMessage, HRDoctorPool, Document
        
        print("\nSeeding database...")
        
        # Note: You'll need to map the seed data dictionaries to your actual model instances
        # Example for Users:
        # for user_data in seed_data['users']:
        #     user = User(**user_data)
        #     session.add(user)
        
        # session.commit()
        print("Database seeded successfully!")
        
        session.close()
        
    except Exception as e:
        print(f"Error seeding database: {e}")
        sys.exit(1)


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Seed database with sample data')
    parser.add_argument('--database-url', type=str, required=True,
                       help='Database connection URL (e.g., sqlite:///app.db)')
    parser.add_argument('--echo', action='store_true',
                       help='Echo SQL queries')
    
    args = parser.parse_args()
    
    seed_database(args.database_url, args.echo)

