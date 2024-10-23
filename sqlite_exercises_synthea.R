# SQLite SQL Exercises for Synthea Database
# This script walks through creating the SQLite database and performing exercises on it.
# Answers are provided at the bottom for reference.

# Step 1: Create a SQLite Database
library(DBI)
library(RSQLite)
library(purrr)
library(data.table)

# Create a new SQLite database named 'synthea'
con <- dbConnect(SQLite(), dbname = "synthea.sqlite")

# Step 2: List All CSV Files in the Directory
csv_files <- list.files(path = "csv", pattern = "*.csv", full.names = TRUE)

# Step 3: Import Each CSV File as a Table
import_csv_to_sqlite <- function(csv_file, con) {
  # Extract table name from file name
  table_name <- tools::file_path_sans_ext(basename(csv_file))
  
  # Use fread to read the CSV file into an R DataFrame
  df <- fread(csv_file, colClasses = "character")  # Read all columns as character, which causes some issues in the SQL syntax but makes my life easier
  
  dbWriteTable(con, table_name, df, overwrite = TRUE)
}

# Import all CSV files into the SQLite database using the above function
walk(csv_files, ~import_csv_to_sqlite(.x, con))

# Verify contents
dbListTables(con)

# Step 4: Exercises! To be done in class, if we have time, or at your leisure.

# ---------------------------
# Exercise 1: Simple SELECT Query
# Example: Retrieve the first 5 rows from the 'patients' table, displaying the patient ID, birthdate, and sex.
dbGetQuery(con, "SELECT Id, BIRTHDATE, GENDER FROM patients LIMIT 5")

# Exercise: Retrieve the first 5 rows from the 'providers' table, displaying the provider ID and organization.

# ---------------------------
# Exercise 2: WHERE Clause
# Example: Retrieve all patients of 'GENDER' who are 'F' in the database. 
dbGetQuery(con, "SELECT Id, BIRTHDATE, GENDER FROM patients WHERE GENDER = 'F' LIMIT 5")

# Exercise: Retrieve all encounters where the cost is greater than 100.
# YOU WILL NEED TO CAST THE ENCOUNTER COST TO A DATA TYPE OF INT USING THIS SYNTAX: CAST(FIELD AS INT)

# ---------------------------
# Exercise 3: ORDER BY Clause
# Example: Retrieve all patient records, ordered by birthdate in ascending order.
dbGetQuery(con, "SELECT * FROM patients ORDER BY BIRTHDATE ASC LIMIT 5")

# Exercise: Retrieve all records from the 'medications' table, ordered by total cost in descending order.

# ---------------------------
# Exercise 4: COUNT and GROUP BY
# Example: Count the number of patients by their sex.
dbGetQuery(con, "SELECT GENDER, COUNT(*) FROM patients GROUP BY GENDER")

# Exercise: Count the number of encounters by each patient.

# ---------------------------
# Exercise 5: INNER JOIN
# Example: Join the 'patients' and 'encounters' tables to retrieve the encounter dates for each patient.
dbGetQuery(con, "
SELECT p.Id, p.BIRTHDATE, e.START
FROM patients p
INNER JOIN encounters e
ON p.Id = e.PATIENT
LIMIT 5")

# Exercise: Join the 'patients' and 'conditions' tables to display each patient's birthdate and their medical condition.

# ---------------------------
# Exercise 6: LEFT JOIN
# Example: Perform a LEFT JOIN between the 'patients' and 'medications' tables to list all patients and any medications they may have been prescribed.
dbGetQuery(con, "
SELECT p.Id, p.BIRTHDATE, m.DESCRIPTION
FROM patients p
LEFT JOIN medications m
ON p.Id = m.PATIENT
LIMIT 5")

# Exercise: Perform a LEFT JOIN between the 'patients' and 'immunizations' tables to list all patients and any immunizations they may have received.

# ---------------------------
# Exercise 7: UNION
# Example: Combine results from 'conditions' and 'medications' to get a list of all unique descriptions.
dbGetQuery(con, "
SELECT DESCRIPTION FROM conditions
UNION
SELECT DESCRIPTION FROM medications")

# Exercise: Combine the lists of distinct descriptions from 'immunizations' and 'medications'.

# ---------------------------
# Exercise 8: Subqueries
# Example: Find all patients who have had encounters costing more than 100
dbGetQuery(con, "
SELECT Id, BIRTHDATE FROM patients
WHERE Id IN (
  SELECT PATIENT FROM encounters WHERE CAST(BASE_ENCOUNTER_COST AS INT) > 100)")

# Exercise: Retrieve all medications prescribed to patients who are male.

# ---------------------------
# Exercise 9: Conditional Statements (CASE)
# Example: Add a column that categorizes the base cost in 'encounters' as 'High' if it is greater than 100, otherwise 'Low'.
dbGetQuery(con, "
SELECT Id, START, BASE_ENCOUNTER_COST,
  CASE
    WHEN CAST(BASE_ENCOUNTER_COST AS INT) > 100 THEN 'High'
    ELSE 'Low'
  END AS Cost_Category
FROM encounters
LIMIT 5")

# Exercise: Add a column to the 'medications' table that categorizes the total cost as 'Expensive' if it is greater than 300, otherwise 'Affordable'.

# ---------------------------
# Exercise Answers (for reference)

# Exercise 1: SELECT Id, BIRTHDATE, GENDER FROM patients LIMIT 5;
# Exercise 2: SELECT Id, START, BASE_ENCOUNTER_COST FROM encounters WHERE CAST(BASE_ENCOUNTER_COST AS INT) > 100 LIMIT 5;
# Exercise 3: SELECT * FROM medications ORDER BY TOTALCOST DESC LIMIT 5;
# Exercise 4: SELECT PATIENT, COUNT(*) FROM encounters GROUP BY PATIENT;
# Exercise 5: SELECT p.Id, p.BIRTHDATE, c.DESCRIPTION FROM patients p INNER JOIN conditions c ON p.Id = c.PATIENT LIMIT 5;
# Exercise 6: SELECT p.Id, p.BIRTHDATE, i.DESCRIPTION FROM patients p LEFT JOIN immunizations i ON p.Id = i.PATIENT LIMIT 5;
# Exercise 7: SELECT DESCRIPTION FROM immunizations UNION SELECT DESCRIPTION FROM medications;
# Exercise 8: SELECT DESCRIPTION FROM medications WHERE PATIENT IN (SELECT Id FROM patients WHERE GENDER = 'M');
# Exercise 9: SELECT Id, DESCRIPTION, TOTALCOST, CASE WHEN CAST(TOTALCOST AS INT) > 300 THEN 'Expensive' ELSE 'Affordable' END AS Cost_Category FROM medications LIMIT 5;

# Disconnect from the SQLite database
dbDisconnect(con)