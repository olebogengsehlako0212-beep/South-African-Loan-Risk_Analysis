-- Default Rate by Province: Which provinces carry the highest default risk?
SELECT 
	applicants.province,
	COUNT(*) as total_loans,
	SUM( CASE WHEN repayments.status = 'ddefaulted' THEN 1 ELSE 0 END) as total_defaults,
	100.0* SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END) / COUNT(*) as default_rate
FROM applicants
LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
LEFT JOIN repayments ON repayments.loan_id = loans.loan_id
GROUP BY applicants.province
ORDER BY default_rate DESC;


-- Default Rate by employment type query: Does Employment status predict default risk?
SELECT
    applicants.employment_type,
    COUNT(*) as total_loans,
    SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END) as total_defaults,
    ROUND( 100.0* SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END)/ COUNT(*),1) as default_rate
FROM applicants 
LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
LEFT JOIN repayments  ON loans.loan_id = repayments.loan_id
GROUP BY applicants.employment_type
ORDER BY default_rate DESC;

--Interest rate & income by repayment status query: Do defaulted borrowers carry higher interest rates?
SELECT 
	repayments.status,
	AVG(loans.interest_rate) as avg_interest_rate,
	AVG(applicants.monthly_income) as avg_income,
	COUNT(*) as total
FROM applicants
LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
LEFT JOIN repayments ON loans.loan_id = repayments.loan_id
GROUP BY repayments.status
ORDER BY avg_interest_rate DESC;

-- Defualt rate by loan purpose query: Which loan types carry the highest default risk?
SELECT loans.loan_purpose,
	COUNT(*) as total,
	AVG(loans.interest_rate) as avg_interest_rate,
	AVG(applicants.monthly_income) as avg_income,
	ROUND( 100.0* SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END)/ COUNT(*),1) as default_rate
FROM loans 
LEFT JOIN applicants ON loans.applicant_id = applicants.applicant_id
LEFT JOIN repayments ON loans.loan_id = repayments.loan_id
GROUP BY loans.loan_purpose;

--Individual borrower risk ranking within province: Who are the riskiest borrowers in each province?
SELECT 
	applicants.name, 
	applicants.province,
	applicants.monthly_income,
	repayments.missed_payments,
	repayments.status,
	RANK() OVER (PARTITION BY applicants.province ORDER BY repayments.missed_payments DESC) as risk_ranked
	FROM applicants
	LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
	LEFT JOIN repayments ON repayments.loan_id = loans.loan_id
ORDER BY applicants.province, risk_ranked;

--Default rate by income band: Does income level predict default risk?	
SELECT
COUNT(*),
( 100.0* SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END)/ COUNT(*)) as default_rate ,
CASE 
	WHEN applicants.monthly_income < 15000 THEN 'Low Income'
	WHEN applicants.monthly_income >15000 AND applicants.monthly_income <= 35000 THEN 'Middle Income'
	ELSE 'High income'
END AS income_band
FROM applicants
LEFT JOIN loans ON loans.applicant_id = applicants.applicant_id
LEFT JOIN repayments ON repayments.loan_id = loans.loan_id
GROUP BY income_band
ORDER BY default_rate DESC;

--Default rate by loan term: Do shorter loan terms carry higher default risks?
SELECT 
	COUNT(*),
	100.0* SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END) / COUNT(*) as default_rate,
	CASE 
		WHEN loans.loan_term_months <= 36 THEN 'Short Term'
		WHEN loans.loan_term_months >=37 AND loans.loan_term_months <60 THEN 'Medium Term'
		ELSE 'Long Term'
	END AS term_band
FROM applicants
LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
LEFT JOIN repayments ON repayments.loan_id = loans.loan_id
GROUP BY term_band
ORDER BY default_rate DESC;

--Default rate by number of dependants: Does number of dependants affect default risk?
SELECT 
	applicants.dependants,
	COUNT(*),
	100.0* SUM( CASE WHEN repayments.status = 'defaulted' THEN 1 ELSE 0 END) / COUNT(*) as default_rate
FROM applicants
LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
LEFT JOIN repayments ON repayments.loan_id = loans.loan_id
GROUP BY applicants.dependants
ORDER BY default_rate DESC;

--Full Applicant Risk Profile: Which Borrowers are high, medium and low risk overall?
WITH applicant_profile AS (
	SELECT
		applicants.name,
		applicants.province,
		applicants.monthly_income,
		loans.loan_purpose,
		loans.loan_term_months,
		repayments.missed_payments,
		repayments.status,
		CASE 
			WHEN applicants.monthly_income < 15000 THEN 'Low Income'
			WHEN applicants.monthly_income <=35000 THEN 'Middle Income'
			ELSE 'High Income'
		END AS income_band 
	FROM applicants
	LEFT JOIN loans ON applicants.applicant_id = loans.applicant_id
	LEFT JOIN repayments ON loans.loan_id = repayments.loan_id
)	

SELECT 
	name,
	province,
	monthly_income,
	loan_purpose,
	loan_term_months,
	missed_payments,
	status, 
	income_band,
	CASE 
		WHEN income_band = 'Low Income' AND loan_purpose = 'Personal' THEN 'High Risk'
		WHEN income_band = 'Low Income' OR loan_purpose = 'Personal' THEN 'Medium Risk'
		ELSE 'Low Risk'
	END AS risk_metre
FROM applicant_profile
ORDER BY risk_metre, missed_payments DESC;