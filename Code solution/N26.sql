-- creating the tables 

CREATE TABLE doc_reports (
    user_id TEXT,
    result TEXT,
    visual_authenticity_result TEXT,
    image_integrity_result TEXT,
    face_detection_result TEXT,
    image_quality_result TEXT,
    created_at TIMESTAMP,
    supported_document_result TEXT,
    conclusive_document_quality_result TEXT,
    colour_picture_result TEXT,
    data_validation_result TEXT,
    data_consistency_result TEXT,
    data_comparison_result TEXT,
    attempt_id TEXT,
    police_record_result TEXT,
    compromised_document_result TEXT,
    properties JSONB,
    sub_result TEXT,
    PRIMARY KEY (user_id, attempt_id)
);

CREATE TABLE facial_similarity_reports (
    user_id TEXT,
    result TEXT,
    face_comparison_result TEXT,
    created_at TIMESTAMP,
    facial_image_integrity_result TEXT,
    visual_authenticity_result TEXT,
    properties JSONB,
    attempt_id TEXT,
    PRIMARY KEY (user_id, attempt_id)
);

-- loading the data into the tables 
copy doc_reports FROM 'D:/DATA SCIENCE/N26/KYC_Challenge/cleaned/cleaned_doc_reports.csv' DELIMITER ',' CSV HEADER;

copy facial_similarity_reports FROM 'D:/DATA SCIENCE/N26/KYC_Challenge/cleaned/cleaned_facial_similarity_reports.csv' DELIMITER ',' CSV HEADER;

-- exploring the data in my dataset
SELECT * FROM facial_similarity_reports
SELECT * FROM doc_reports

SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'facial_similarity_reports';

SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'doc_reports';


-- calculating the overall pass rate

SELECT 
COUNT(DISTINCT user_id) AS passed_customers,
(SELECT COUNT(DISTINCT user_id) FROM facial_similarity_reports) AS total_customers,
ROUND(COUNT(DISTINCT user_id) * 100.0 / 
(SELECT COUNT(DISTINCT user_id) FROM facial_similarity_reports), 2) AS pass_rate
FROM facial_similarity_reports AS f
JOIN doc_reports AS d
USING (user_id)
WHERE f.result = 'clear' AND d.result = 'clear';

-- pass rate by attempt number

WITH attempt_ranked AS(
SELECT attempt_id, user_id, result,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS attempt_number
FROM facial_similarity_reports
)
SELECT ar.attempt_number,
COUNT(DISTINCT CASE WHEN f.result = 'clear' AND d.result = 'clear' THEN ar.attempt_id END ) AS passed_attempts,
COUNT(DISTINCT ar.attempt_id ) AS total_attempts,
ROUND(COUNT(DISTINCT CASE WHEN f.result = 'clear' AND d.result = 'clear' THEN ar.attempt_id END) * 100 / COUNT(DISTINCT ar.attempt_id),2) AS pass_rate
FROM attempt_ranked AS ar
JOIN facial_similarity_reports AS f
USING(attempt_id)
JOIN doc_reports AS d
USING (attempt_id)
GROUP BY ar.attempt_number
ORDER BY ar.attempt_number

-- failures reasons

SELECT result, COUNT(*) AS failure_count
FROM doc_reports
WHERE result != 'clear'
GROUP BY result
ORDER BY failure_count DESC;


SELECT result, COUNT(*) AS failure_count
FROM facial_similarity_reports
WHERE result != 'clear'
GROUP BY result
ORDER BY failure_count DESC;


-- rejection failures

SELECT visual_authenticity_result,image_integrity_result, 
face_detection_result, image_quality_result,  COUNT(*) AS rejection_count
FROM doc_reports 
WHERE sub_result = 'rejected'
GROUP BY visual_authenticity_result,image_integrity_result, 
face_detection_result, image_quality_result
ORDER BY rejection_count DESC;

-- suspecious failures

SELECT visual_authenticity_result,image_integrity_result, 
face_detection_result, image_quality_result,  COUNT(*) AS rejection_count
FROM doc_reports 
WHERE sub_result = 'suspected'
GROUP BY visual_authenticity_result,image_integrity_result, 
face_detection_result, image_quality_result
ORDER BY rejection_count DESC;

-- caution failures

SELECT visual_authenticity_result,image_integrity_result, 
face_detection_result, image_quality_result,  COUNT(*) AS rejection_count
FROM doc_reports 
WHERE sub_result = 'caution'
GROUP BY visual_authenticity_result,image_integrity_result, 
face_detection_result, image_quality_result
ORDER BY rejection_count DESC;

-- pass rate over time 

SELECT DATE_TRUNC('week', f.created_at) AS week,
COUNT(DISTINCT CASE WHEN f.result = 'clear' AND d.result = 'clear' THEN f.user_id END) * 100 / COUNT(DISTINCT f.user_id) AS pass_rate
FROM facial_similarity_reports AS f
JOIN doc_reports AS d
USING(user_id)
GROUP BY week
ORDER BY week;

-- Examine the following SQL query, and explain clearly and succinctly what it means. Will the query work? Explain why or why not. 

WITH processed_users AS ( 
SELECT TRIM(UPPER(LEFT(u.phone_country, 2))) AS short_phone_country, u.id  
FROM users u 
) 
SELECT t.user_id,  
t.merchant_country,  
sum(t.amount / fx.rate / power(10, cd.exponent)) AS amount  
FROM transactions t 
JOIN fx_rates fx ON (fx.ccy = t.currency AND fx.base_ccy = 'EUR') 
JOIN currency_details cd ON cd.ccy = t.currency 
JOIN processed_users pu ON pu.id = t.user_id 
WHERE t.source = 'GAIA' 
AND pu.short_phone_country = TRIM(UPPER(LEFT(t.merchant_country, 2)))
GROUP BY t.user_id, t.merchant_country 
ORDER BY amount DESC;

SELECT column_name FROM information_schema.columns 
WHERE table_name = 'currency_details';


SELECT DISTINCT t.currency 
FROM transactions t
LEFT JOIN currency_details cd ON cd.ccy = t.currency
WHERE cd.ccy IS NULL;

SELECT DISTINCT t.user_id 
FROM transactions t
LEFT JOIN users u ON u.id = t.user_id
WHERE u.id IS NULL;

SELECT COUNT(*) FROM transactions WHERE source = 'GAIA';

SELECT COUNT(*) 
FROM transactions t
JOIN users u ON u.id = t.user_id
WHERE LEFT(u.phone_country, 2) = t.merchant_country;

SELECT DISTINCT phone_country 
FROM users 
LIMIT 20;

SELECT DISTINCT merchant_country, LENGTH(merchant_country) 
FROM transactions
ORDER BY merchant_country;

SELECT merchant_country, COUNT(*)
FROM transactions
WHERE LENGTH(TRIM(merchant_country)) < 3
GROUP BY merchant_country
ORDER BY COUNT(*) DESC;

UPDATE transactions
SET merchant_country = NULL
WHERE LENGTH(TRIM(merchant_country)) < 3 OR merchant_country ~ '[^A-Z]';


UPDATE transactions
SET merchant_country = RIGHT(TRIM(REGEXP_REPLACE(merchant_country, '[^A-Z]', '', 'g')), 3);

UPDATE transactions
SET merchant_country = TRIM(UPPER(merchant_country));


SELECT DISTINCT merchant_country FROM transactions ORDER BY merchant_country;


SELECT DISTINCT TRIM(UPPER(LEFT(phone_country, 3))) AS cleaned_phone_country
FROM users
ORDER BY cleaned_phone_country;


-- creating the tables 
CREATE TABLE transactions (
currency VARCHAR(3) NOT NULL,
amount BIGINT NOT NULL,
state VARCHAR(25) NOT NULL,
created_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
merchant_category VARCHAR(100),
merchant_country VARCHAR(3),
entry_method VARCHAR(4) NOT NULL,
user_id UUID NOT NULL,
type VARCHAR(20) NOT NULL,
source VARCHAR(20) NOT NULL,
id UUID PRIMARY KEY
);

DROP TABLE transactions

ALTER TABLE transactions 
ALTER COLUMN created_date TYPE TIME WITHOUT TIME ZONE USING created_date::TIME;

ALTER TABLE transactions
ALTER COLUMN merchant_country TYPE VARCHAR(200);

copy transactions FROM 'D:/DATA SCIENCE/N26/KYC_Challenge/fct_data/fct_data/transactions_1.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM transactions

CREATE TABLE users (
failed_sign_in_attempts int,
kyc varchar(20),
birth_year int,
country varchar(2),
state varchar(25) not null,
created_date timestamp without time zone not null,
terms_version date,
phone_country varchar(300),
has_email boolean not null,
id uuid primary key
);


ALTER TABLE users 
ALTER COLUMN created_date TYPE TIME WITHOUT TIME ZONE USING created_date::TIME;

copy users FROM 'D:/DATA SCIENCE/N26/KYC_Challenge/fct_data/fct_data/users.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM users


CREATE TABLE fx_rates (
base_ccy varchar(3),
ccy varchar(10),
rate float
);

ALTER TABLE fx_rates
ALTER COLUMN rate TYPE float

copy fx_rates FROM 'D:/DATA SCIENCE/N26/KYC_Challenge/fct_data/fct_data/fx_rates.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM fx_rates


CREATE TABLE currency_details (
ccy varchar(10) primary key,
iso_code INT,
exponent INT,
is_crypto boolean not null
);

copy currency_details FROM 'D:/DATA SCIENCE/N26/KYC_Challenge/fct_data/fct_data/currency_details.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM currency_details


-- 3)  Now it’s your turn! Write a query to identify users whose first transaction was a successful card payment over $10 USD  

WITH first_transactions AS (
    SELECT 
        t.user_id, 
        t.id AS transaction_id,
        t.created_date,
        t.amount,
        t.currency,
        t.state,
        t.entry_method,
        ROW_NUMBER() OVER (PARTITION BY t.user_id ORDER BY t.created_date ASC) AS rank
    FROM transactions t
)
SELECT ft.user_id, 
       ft.transaction_id,
       ft.created_date,
       ft.amount,
       ft.currency
FROM first_transactions ft
JOIN fx_rates fx ON (fx.ccy = ft.currency AND fx.base_ccy = 'USD')  
WHERE ft.rank = 1 
AND ft.state = 'COMPLETED' 
AND ft.entry_method = 'chip'  
AND (ft.amount / fx.rate) > 10  
ORDER BY ft.created_date;

