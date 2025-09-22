# Bank Fraud Detection SQL Project

## Project Overview

This project aims to detect and analyze fraudulent activities in banking transactions using SQL. It involves creating a relational database with multiple interconnected tables, running queries to extract insights, and identifying high-risk accounts and customers.

---

## Objectives

* Build a relational database to store customer, account, transaction, card, and alert data.
* Detect fraudulent transactions using advanced SQL queries.
* Identify high-risk accounts and locations prone to fraud.
* Generate actionable insights for fraud prevention.

---

## Database Tables

| Table Name       | Description                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------- |
| customers    | Stores customer personal details including name, DOB, gender, contact, and account open date. |
| accounts     | Contains account information, type, balance, and status linked to customers.                  |
| transactions | Tracks all transactions, including type, amount, location, device, and fraud flag.            |
| cards        | Contains debit/credit card details linked to accounts.                                        |
| alerts       | Records alerts generated for suspicious transactions.                                         |

---

## Entity-Relationship Diagram

* The database uses primary and foreign keys to maintain relationships:

  * `customers` → `accounts` → `transactions` → `alerts`
  * `accounts` → `cards`
* ER Diagram ensures data integrity and enables complex queries for fraud detection.

---

## Key Features

* Detect fraudulent transactions by account, transaction type, and location.
* Identify high-risk customers based on multiple metrics: fraud count, alerts, and fraud-to-balance ratio.
* Analyze transaction patterns such as multiple-city transactions and sudden large frauds.
* Generate summary reports like monthly transactions, total frauds, and alerts.

---

## Sample Queries

1. Find Active Accounts

```sql
SELECT concat(first_name, " ", last_name) Full_Name, account_status
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE account_status = 'Active';
```

2. Top 10 Accounts by Transaction Amount

```sql
SELECT a.account_id, concat(first_name," ",last_name) Full_Name, sum(amount) Total_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY a.account_id
ORDER BY Total_amount DESC
LIMIT 10;
```

3. Accounts with More Than 2 Fraudulent Transactions

```sql
SELECT a.account_id, concat(first_name," ",last_name) Full_Name, sum(is_fraud) Total_Fraud
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY a.account_id
HAVING Total_Fraud > 2;
```

4. High-Risk Accounts Using Multiple Metrics

```sql
SELECT acc.account_id, COUNT(t.transaction_id) Total_Transaction, SUM(is_fraud) Total_Fraud,
       SUM(amount*is_fraud) Total_Fraud_Amount, COUNT(a.alert_id) Total_Alerts
FROM transactions t
JOIN accounts acc ON t.account_id = acc.account_id
LEFT JOIN alerts a ON t.transaction_id = a.transaction_id
GROUP BY acc.account_id
HAVING Total_Fraud > 2 OR Total_Fraud_Amount > 50000 OR Total_Alerts > 2;
```

---

## Insights

* Certain accounts repeatedly show fraudulent behavior and need monitoring.
* Fraud hotspots exist in specific locations.
* Multiple frauds in a single day/hour indicate coordinated attacks.
* Accounts with sudden large frauds (>2x average normal transactions) are high-risk.

---

## Tools & Technologies

* Database: MySQL / MySQL Workbench
* Data Storage: CSV files for bulk upload
* Visualization: Charts in PPT / Excel
* ER Diagram: MySQL Workbench / Draw\.io

---

## Conclusion

* A complete bank fraud detection system is implemented using SQL.
* Queries range from basic customer/account info to advanced fraud analytics.
* Provides actionable insights for monitoring high-risk accounts.

---

✅ Tip for PPT:

* Use bullets from this README in slides to make it visually clean.
* Include ER diagram and query screenshots alongside this content for maximum impact.

---

If you want, I can also create a 1-slide version of this README, optimized for PPT, where all key points, tables, and sample queries are compact and visually appealing.

Do you want me to do that?
