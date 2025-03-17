import numpy as np
import pandas as pd
import json




doc_reports_path = "D:/DATA SCIENCE/N26/KYC_Challenge/doc_reports.csv"
facial_similarity_path = "D:/DATA SCIENCE/N26/KYC_Challenge/facial_similarity_reports.csv"

doc_reports = pd.read_csv(doc_reports_path, encoding='utf-8', low_memory=False)
facial_similarity_reports = pd.read_csv(facial_similarity_path, encoding='utf-8', low_memory=False)

print(doc_reports.head())
print(facial_similarity_reports.head())

#converting the created_at column to a datetime format
doc_reports["created_at"] = pd.to_datetime(doc_reports["created_at"], errors="coerce")
facial_similarity_reports["created_at"] = pd.to_datetime(facial_similarity_reports["created_at"], errors="coerce")

# Replace Null values with None 
doc_reports = doc_reports.where(pd.notna(doc_reports), None)
facial_similarity_reports = facial_similarity_reports.where(pd.notna(facial_similarity_reports), None)

# Save cleaned data
doc_reports.to_csv("cleaned_doc_reports.csv", index=False)
facial_similarity_reports.to_csv("cleaned_facial_similarity_reports.csv", index=False)