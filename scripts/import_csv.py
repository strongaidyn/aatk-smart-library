import csv
import requests
import sys
import os

# Configuration
API_URL = os.getenv("API_URL", "http://localhost:8080/api/v1")
LIBRARY_ID = os.getenv("LIBRARY_ID", "1")  # Default library ID
AUTH_TOKEN = os.getenv("AUTH_TOKEN", "")   # If auth is required

def import_csv(file_path):
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return

    with open(file_path, mode='r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            # Map CSV row to CreatePhysicalBookRequest
            # Note: BookLore uses "PhysicalBook" for books without initial file, 
            # or we can try to find an endpoint for digital books if we want to link files.
            # Since the task asks for a simple import, we'll use the physical book endpoint 
            # we just modified to include grade/subject.
            
            payload = {
                "libraryId": int(LIBRARY_ID),
                "title": row.get("title"),
                "authors": [a.strip() for a in row.get("authors", "").split(",")],
                "description": row.get("description"),
                "publisher": row.get("publisher"),
                "publishedDate": row.get("year"),
                "language": row.get("language", "").split("/")[0].strip(), # Take first language
                "grade": int(row.get("grade")) if row.get("grade") else None,
                "subject": row.get("subject"),
                "isbn": row.get("isbn")
            }
            
            headers = {
                "Content-Type": "application/json"
            }
            if AUTH_TOKEN:
                headers["Authorization"] = f"Bearer {AUTH_TOKEN}"
                
            try:
                response = requests.post(f"{API_URL}/books/physical", json=payload, headers=headers)
                if response.status_code in [200, 201]:
                    print(f"Successfully imported: {payload['title']}")
                else:
                    print(f"Failed to import {payload['title']}: {response.status_code} - {response.text}")
            except Exception as e:
                print(f"Error importing {payload['title']}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python import_csv.py <path_to_csv>")
    else:
        import_csv(sys.argv[1])
