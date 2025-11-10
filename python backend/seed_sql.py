"""
Raw SQL Seed Script
Populates database using raw SQL queries
Supports SQLite, PostgreSQL, MySQL
"""

from seed import generate_all_seed_data
import sqlite3
import sys
from typing import Dict, List, Any


def escape_sql_string(value: Any) -> str:
    """Escape SQL string values"""
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, dict):
        return f"'{str(value).replace(chr(39), chr(39)+chr(39))}'"  # Escape single quotes
    if isinstance(value, list):
        return f"'{str(value).replace(chr(39), chr(39)+chr(39))}'"  # Escape single quotes
    # String value - escape single quotes
    escaped = str(value).replace("'", "''")
    return f"'{escaped}'"


def generate_insert_sql(table_name: str, records: List[Dict[str, Any]]) -> List[str]:
    """Generate INSERT SQL statements"""
    if not records:
        return []
    
    sql_statements = []
    
    # Get column names from first record
    columns = list(records[0].keys())
    
    for record in records:
        values = [escape_sql_string(record.get(col)) for col in columns]
        values_str = ", ".join(values)
        columns_str = ", ".join(columns)
        sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({values_str});"
        sql_statements.append(sql)
    
    return sql_statements


def seed_sqlite(db_path: str):
    """Seed SQLite database"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    seed_data = generate_all_seed_data()
    
    print("\nSeeding SQLite database...")
    
    # Map table names
    table_mapping = {
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
    
    try:
        for seed_key, table_name in table_mapping.items():
            records = seed_data.get(seed_key, [])
            if records:
                sql_statements = generate_insert_sql(table_name, records)
                for sql in sql_statements:
                    cursor.execute(sql)
                print(f"Inserted {len(records)} records into {table_name}")
        
        conn.commit()
        print("\nDatabase seeded successfully!")
        
    except Exception as e:
        conn.rollback()
        print(f"Error seeding database: {e}")
        raise
    finally:
        conn.close()


def generate_sql_file(output_file: str, database_type: str = "postgresql"):
    """Generate SQL file with INSERT statements"""
    seed_data = generate_all_seed_data()
    
    # Map table names based on database type
    if database_type.lower() == "postgresql":
        table_mapping = {
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
    else:  # MySQL
        table_mapping = {
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
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(f"-- Seed data for {database_type.upper()}\n")
        f.write(f"-- Generated from schema.md\n\n")
        
        if database_type.lower() == "postgresql":
            f.write("BEGIN;\n\n")
        
        for seed_key, table_name in table_mapping.items():
            records = seed_data.get(seed_key, [])
            if records:
                f.write(f"-- Inserting {len(records)} records into {table_name}\n")
                sql_statements = generate_insert_sql(table_name, records)
                for sql in sql_statements:
                    f.write(sql + "\n")
                f.write("\n")
        
        if database_type.lower() == "postgresql":
            f.write("COMMIT;\n")
    
    print(f"SQL file generated: {output_file}")


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate SQL seed files or seed SQLite database')
    parser.add_argument('--sqlite', type=str, help='Path to SQLite database file')
    parser.add_argument('--sql-file', type=str, help='Output SQL file path')
    parser.add_argument('--db-type', type=str, choices=['postgresql', 'mysql'], default='postgresql',
                       help='Database type for SQL file (default: postgresql)')
    
    args = parser.parse_args()
    
    if args.sqlite:
        seed_sqlite(args.sqlite)
    elif args.sql_file:
        generate_sql_file(args.sql_file, args.db_type)
    else:
        parser.print_help()
        sys.exit(1)

