CREATE TABLE IF NOT EXISTS mortgage_terms (
    id integer GENERATED ALWAYS AS IDENTITY,
    remaining_terms smallint,
    rate double precision, -- in percentage
    monthly_rate double precision GENERATED ALWAYS AS (rate / 1200) STORED, -- in exact value
    loan_bal double precision,
    monthly_payment double precision GENERATED ALWAYS AS 
    (rate / 1200 * (1 + rate / 1200)^remaining_terms / 
        ((1 + rate / 1200)^remaining_terms - 1) * loan_bal) STORED);

INSERT INTO mortgage_terms (remaining_terms, rate, loan_bal) VALUES (18, 5.5, 250000);
INSERT INTO mortgage_terms (remaining_terms, rate, loan_bal) VALUES (18, 5.5, 50000);


WITH RECURSIVE balance(m) AS (
    VALUES ((SELECT loan_bal FROM mortgage_terms WHERE id=2))
    UNION ALL 
    SELECT GREATEST(m * (1 + (SELECT monthly_rate FROM mortgage_terms WHERE id=2)) 
    - (SELECT monthly_payment FROM mortgage_terms WHERE id=1), 0) FROM balance WHERE m > 0
), 
ful(pb, b) AS (SELECT lag(m) OVER (), m  FROM balance)

SELECT b, pb * (SELECT monthly_rate FROM mortgage_terms WHERE id=2) interest FROM ful ORDER BY b DESC;
WITH RECURSIVE balance(m) AS (
    VALUES ((SELECT loan_bal FROM mortgage_terms WHERE id=2))
    UNION ALL 
    SELECT GREATEST(m * (1 + (SELECT monthly_rate FROM mortgage_terms WHERE id=2)) 
    - (SELECT monthly_payment FROM mortgage_terms WHERE id=2), 0) FROM balance WHERE m > 0
), 
ful(pb, b) AS (SELECT lag(m) OVER (), m  FROM balance)

SELECT b, pb * (SELECT monthly_rate FROM mortgage_terms WHERE id=2) interest FROM ful ORDER BY b DESC;
