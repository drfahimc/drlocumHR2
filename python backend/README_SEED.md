# Database Seed Scripts

This directory contains seed scripts for populating the database with sample data based on `schema.md`.

## Files

- `seed.py` - Core seed data generator (contains all data generation functions)
- `seed_sqlalchemy.py` - SQLAlchemy ORM seed script
- `seed_sql.py` - Raw SQL seed script (SQLite, PostgreSQL, MySQL)
- `seed_firestore.py` - Firebase Firestore seed script
- `seed_mongodb.py` - MongoDB seed script

## Usage

### 1. Generate Seed Data (JSON)

```bash
python seed.py
```

This generates `seed_data.json` with all seed data.

### 2. Seed SQLite Database

```bash
python seed_sql.py --sqlite app.db
```

### 3. Generate SQL File

```bash
# PostgreSQL
python seed_sql.py --sql-file seed_data.sql --db-type postgresql

# MySQL
python seed_sql.py --sql-file seed_data.sql --db-type mysql
```

Then import:
```bash
psql -d your_database -f seed_data.sql
# or
mysql -u user -p database < seed_data.sql
```

### 4. Seed Firestore

```bash
python seed_firestore.py --credentials path/to/serviceAccountKey.json
```

### 5. Seed MongoDB

```bash
python seed_mongodb.py --connection-string mongodb://localhost:27017/ --database drlocumdr
```

### 6. Seed using SQLAlchemy

```bash
python seed_sqlalchemy.py --database-url sqlite:///app.db
# or
python seed_sqlalchemy.py --database-url postgresql://user:pass@localhost/dbname
```

## Seed Data Overview

The seed data includes:

- **8 Users**: 3 HR users + 5 Doctor users
- **5 Doctors**: With profiles, specialties, qualifications
- **10-15 Documents**: Medical licenses, certificates, ID proofs
- **3 Hospitals**: Managed by HR users
- **9-15 Jobs**: Various roles, shifts, and statuses
- **10 Applications**: Doctor applications for jobs
- **5 Shifts**: Shift instances for completed jobs
- **3 Payments**: Payment records for completed shifts
- **8 Notifications**: User notifications
- **3 Feedbacks**: HR feedback for doctors
- **6 Admin Messages**: Messages between HR and admin
- **6-9 HR Doctor Pool entries**: Curated doctor pools

## Default Credentials

All seed users have password: `password123`

- HR Users: `hr1@hospital.com`, `hr2@clinic.com`, `hr3@medical.com`
- Doctor Users: `doctor1@example.com` through `doctor5@example.com`

## Customization

Edit `seed.py` to customize:
- Number of records
- Data values
- Relationships between entities
- Date ranges
- Status distributions

## Dependencies

Install required packages:

```bash
# For SQLAlchemy
pip install sqlalchemy

# For Firestore
pip install firebase-admin

# For MongoDB
pip install pymongo
```

## Notes

- All IDs are generated as UUIDs
- Timestamps are in ISO format
- Passwords are SHA256 hashed (use bcrypt in production)
- The seed data respects relationships between tables
- Some records reference others (e.g., Jobs reference Hospitals)

