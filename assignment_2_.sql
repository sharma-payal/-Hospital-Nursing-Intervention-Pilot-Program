/* =========================================================
   0. CREATE SCHEMA AND START CLEAN
   ========================================================= */

-- Create schema if it does not exist
CREATE SCHEMA IF NOT EXISTS hospital_data;

-- Use this schema
USE hospital_data;

-- If you need a clean restart, drop tables in FK‑safe order
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS bed_fact;
DROP TABLE IF EXISTS business;
DROP TABLE IF EXISTS bed_type;
SET FOREIGN_KEY_CHECKS = 1;


/* =========================================================
   1. CREATE DIMENSION TABLES AND FACT TABLE
   ========================================================= */

-- Dimension: bed_type (bed type lookup)
CREATE TABLE bed_type (
    bed_id      INT PRIMARY KEY,     -- PK, also used as FK in fact table
    bed_code    VARCHAR(50),         -- e.g. ICU, SICU, etc.
    bed_desc    VARCHAR(255)         -- human readable description
);

-- Dimension: business (hospital)
CREATE TABLE business (
    business_id     INT PRIMARY KEY, -- PK, also used as FK in fact table
    business_name   VARCHAR(255),    -- hospital name
    business_type   VARCHAR(100)     -- e.g. hospital type; add more cols as per CSV
    -- Add more descriptive columns from your CSV as needed:
    -- city VARCHAR(100),
    -- county_name VARCHAR(100),
    -- state VARCHAR(50),
    -- etc.
);

-- Fact: bed_fact (stores numeric measures per hospital/bed_type)
CREATE TABLE bed_fact (
    fact_id         INT AUTO_INCREMENT PRIMARY KEY,  -- surrogate PK for fact table
    business_id     INT,                             -- FK to business
    bed_id          INT,                             -- FK to bed_type
    license_beds    INT,                             -- fact: number of licensed beds
    census_beds     INT,                             -- fact: number of occupied beds
    staffed_beds    INT,                             -- fact: number of staffed beds
    -- If your CSV has more columns, add them here (e.g., report_year INT, etc.)

    INDEX idx_bed_fact_business (business_id),
    INDEX idx_bed_fact_bed (bed_id)
);


/* =========================================================
   2. ADD FOREIGN KEY RELATIONSHIPS (STAR SCHEMA)
   ========================================================= */

ALTER TABLE bed_fact
  ADD CONSTRAINT fk_bed_fact_business
    FOREIGN KEY (business_id)
    REFERENCES business(business_id);

ALTER TABLE bed_fact
  ADD CONSTRAINT fk_bed_fact_bed_type
    FOREIGN KEY (bed_id)
    REFERENCES bed_type(bed_id);


/* =========================================================
   3. IMPORT DATA FROM CSV FILES
   =========================================================
   NOTE:
   - You must replace the file paths with the real absolute paths.
   - Column lists after IGNORE 1 LINES must match the exact order
     of columns in each CSV file.
   - LOCAL requires that local file import is enabled on your setup.
   ========================================================= */

-- Import bed_type.csv into bed_type table
LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/bed_type.csv'
INTO TABLE bed_type
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  bed_id,
  bed_code,
  bed_desc
);
-- Import business.csv into business table
LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/business.csv'
INTO TABLE business
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  business_id,
  business_name,
  business_type
  -- If CSV has more columns, list them here and add columns to table DDL
);
-- Import bed_fact.csv into bed_fact table
LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/bed_fact.csv'
INTO TABLE bed_fact
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  business_id,
  bed_id,
  license_beds,
  census_beds,
  staffed_beds
  -- Again, match CSV order; add extra columns if needed
);
/* =========================================================
   4. ANALYSIS QUERIES – STEP 6a
      ICU OR SICU (bed_id = 4 OR 15)
   =========================================================
   Assumptions:
   - bed_id = 4  => ICU
   - bed_id = 15 => SICU
   - Change these IDs if they are different in your data.
   ========================================================= */

-- 6a‑1: Top 10 hospitals by total ICU + SICU LICENSED beds
SELECT
    b.business_name,
    SUM(f.license_beds) AS total_icu_sicu_license_beds
FROM bed_fact f
JOIN business b   ON f.business_id = b.business_id
JOIN bed_type bt  ON f.bed_id = bt.bed_id
WHERE f.bed_id IN (4, 15)                    -- ICU or SICU
GROUP BY b.business_name
ORDER BY total_icu_sicu_license_beds DESC
LIMIT 10;                                   -- only top 10 rows


-- 6a‑2: Top 10 hospitals by total ICU + SICU CENSUS beds
SELECT
    b.business_name,
    SUM(f.census_beds) AS total_icu_sicu_census_beds
FROM bed_fact f
JOIN business b   ON f.business_id = b.business_id
JOIN bed_type bt  ON f.bed_id = bt.bed_id
WHERE f.bed_id IN (4, 15)
GROUP BY b.business_name
ORDER BY total_icu_sicu_census_beds DESC
LIMIT 10;


-- 6a‑3: Top 10 hospitals by total ICU + SICU STAFFED beds
SELECT
    b.business_name,
    SUM(f.staffed_beds) AS total_icu_sicu_staffed_beds
FROM bed_fact f
JOIN business b   ON f.business_id = b.business_id
JOIN bed_type bt  ON f.bed_id = bt.bed_id
WHERE f.bed_id IN (4, 15)
GROUP BY b.business_name
ORDER BY total_icu_sicu_staffed_beds DESC
LIMIT 10;


/* =========================================================
   5. ANALYSIS QUERIES – STEP 7a
      ONLY HOSPITALS WITH BOTH ICU AND SICU
   =========================================================
   Logic:
   - Use conditional SUM + HAVING to ensure:
       ICU volume > 0 AND SICU volume > 0
   - Run separately for license, census, and staffed beds.
   ========================================================= */

-- 7a‑1: License beds – top 10 hospitals that have BOTH ICU and SICU
SELECT
    b.business_name,
    SUM(f.license_beds) AS total_icu_sicu_license_beds
FROM bed_fact f
JOIN business b ON f.business_id = b.business_id
WHERE f.bed_id IN (4, 15)
GROUP BY b.business_name
HAVING
    SUM(CASE WHEN f.bed_id = 4  THEN f.license_beds ELSE 0 END) > 0 AND
    SUM(CASE WHEN f.bed_id = 15 THEN f.license_beds ELSE 0 END) > 0
ORDER BY total_icu_sicu_license_beds DESC
LIMIT 10;


-- 7a‑2: Census beds – top 10 hospitals that have BOTH ICU and SICU
SELECT
    b.business_name,
    SUM(f.census_beds) AS total_icu_sicu_census_beds
FROM bed_fact f
JOIN business b ON f.business_id = b.business_id
WHERE f.bed_id IN (4, 15)
GROUP BY b.business_name
HAVING
    SUM(CASE WHEN f.bed_id = 4  THEN f.census_beds ELSE 0 END) > 0 AND
    SUM(CASE WHEN f.bed_id = 15 THEN f.census_beds ELSE 0 END) > 0
ORDER BY total_icu_sicu_census_beds DESC
LIMIT 10;


-- 7a‑3: Staffed beds – top 10 hospitals that have BOTH ICU and SICU
SELECT
    b.business_name,
    SUM(f.staffed_beds) AS total_icu_sicu_staffed_beds
FROM bed_fact f
JOIN business b ON f.business_id = b.business_id
WHERE f.bed_id IN (4, 15)
GROUP BY b.business_name
HAVING
    SUM(CASE WHEN f.bed_id = 4  THEN f.staffed_beds ELSE 0 END) > 0 AND
    SUM(CASE WHEN f.bed_id = 15 THEN f.staffed_beds ELSE 0 END) > 0
ORDER BY total_icu_sicu_staffed_beds DESC
LIMIT 10;
