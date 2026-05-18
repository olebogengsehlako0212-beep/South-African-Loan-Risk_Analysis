# SA Loan Risk Analysis

A SQL-based credit risk analysis project examining default patterns across a synthetic South African lending dataset. It is built to demonstrate end-to-end analytical thinking, from database design through to business insight.

## Business Question
Which borrower characteristics most strongly predict loan default risk in a South African lending context?

## Tools Used
- SQLite (DB Browser) 
- SQL: joins, aggregations, CASE statements, window functions, CTEs
- Power BI (dashboard in progress)

## Database Structure
Three related tables:
- applicants: borrower demographics, income, employment type, province
- loans: loan amount, term, interest rate, purpose
- repayments: payment history, missed payments, repayment status

## Key Findings

**1. Income is the dominant default driver**
Low income borrowers (under R15,000/month) defaulted at 92.9%, compared to 8.3% for middle and high income borrowers. Employment type and province both appear to be proxies for income rather than independent risk factors.

**2. Personal loans carry the highest default risk**
Personal loans defaulted at 77.8% with an average interest rate of 22%,the highest of any loan category. This is consistent with the debt trap effect: high interest rates increase repayment burden for already-stretched borrowers.

**3. Short term loans are riskier than long term**
Loans with terms under 36 months defaulted at 64%, while long term loans (60+ months) defaulted at 0%. Short term loans in this dataset are predominantly personal loans taken by lower income borrowers.

**4. Dependants is a counterintuitive risk factor**
Borrowers with 0 dependants defaulted at 80%, while those with 3-4 defaulted at 0%. This is explained by the correlation between dependants, age, and income, younger, lower-income borrowers are more likely to have no dependants.

**5. Western Cape shows significantly lower default risk**
All Western Cape borrowers in this dataset are current or settled. This reflects the higher average income and salaried employment profile of Western Cape applicants rather than geography itself.

## Queries Included
1. Default rate by province
2. Default rate by employment type
3. Interest rate and income by repayment status
4. Default rate by loan purpose
5. Individual borrower risk ranking within province as a window fucntion
6. Default rate by income band
7. Default rate by loan term
8. Default rate by number of dependants
9. Full borrower risk profile,CTE combining income, loan purpose, and repayment history into a single risk flag/bucket per applicant

## Note on Data
This project uses a synthetic dataset designed to reflect realistic South African lending demographics and default patterns. A follow-up project applying the same methodology to the Home Credit Default Risk dataset (Kaggle) is planned.
