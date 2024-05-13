USE `hospital`;
SELECT b.business_name AS hospital_name, SUM(bf.license_beds) AS total_license_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
ORDER BY total_license_beds DESC
LIMIT 10;

SELECT b.business_name AS hospital_name, SUM(bf.census_beds) AS total_census_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
ORDER BY total_census_beds DESC
LIMIT 10;

SELECT b.business_name AS hospital_name, SUM(bf.staffed_beds) AS total_staffed_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
ORDER BY total_staffed_beds DESC
LIMIT 10;

SELECT b.business_name AS hospital_name, SUM(bf.license_beds) AS total_license_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
HAVING COUNT(DISTINCT bf.bed_id) = 2 -- Hospitals with both ICU and SICU
ORDER BY total_license_beds DESC
LIMIT 10;

SELECT b.business_name AS hospital_name, SUM(bf.census_beds) AS total_census_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
HAVING COUNT(DISTINCT bf.bed_id) = 2 -- Hospitals with both ICU and SICU
ORDER BY total_census_beds DESC
LIMIT 10;

SELECT b.business_name AS hospital_name, SUM(bf.staffed_beds) AS total_staffed_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
HAVING COUNT(DISTINCT bf.bed_id) = 2 -- Hospitals with both ICU and SICU
ORDER BY total_staffed_beds DESC
LIMIT 10;


CREATE TABLE Top10_Hospitals_ICU_SICU_License_Beds AS
SELECT b.business_name AS hospital_name, SUM(bf.license_beds) AS total_license_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
HAVING COUNT(DISTINCT bf.bed_id) = 2
ORDER BY total_license_beds DESC
LIMIT 10;

SELECT * FROM Top10_Hospitals_ICU_SICU_License_Beds;

CREATE TABLE Top10_Hospitals_ICU_SICU_Census_Beds AS
SELECT b.business_name AS hospital_name, SUM(bf.census_beds) AS total_census_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
HAVING COUNT(DISTINCT bf.bed_id) = 2
ORDER BY total_census_beds DESC
LIMIT 10;

SELECT * FROM Top10_Hospitals_ICU_SICU_Census_Beds;

CREATE TABLE Top10_Hospitals_ICU_SICU_Staffed_Beds AS
SELECT b.business_name AS hospital_name, SUM(bf.staffed_beds) AS total_staffed_beds
FROM bed_fact AS bf
JOIN business AS b ON bf.ims_org_id = b.ims_org_id
WHERE bf.bed_id IN (4, 15)
GROUP BY hospital_name
HAVING COUNT(DISTINCT bf.bed_id) = 2
ORDER BY total_staffed_beds DESC
LIMIT 10;

SELECT * FROM Top10_Hospitals_ICU_SICU_Staffed_Beds;
