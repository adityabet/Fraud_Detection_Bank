CREATE DATABASE IF NOT EXISTS bank_fraud_detection;
USE bank_fraud_detection;

-- customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    gender ENUM('M','F'),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255),
    account_open_date DATE
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Fraud Detection\\customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- accounts table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type ENUM('Savings','Current','Credit'),
    account_balance DECIMAL(15,2),
    account_status ENUM('Active','Dormant','Closed'),
    created_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Fraud Detection\\accounts.csv'
INTO TABLE accounts
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Transaction table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type ENUM('Deposit','Withdrawal','Transfer','Payment'),
    amount DECIMAL(15,2),
    transaction_date DATETIME,
    location VARCHAR(100),
    device ENUM('Mobile','Web','ATM'),
    is_fraud BOOLEAN,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Fraud Detection\\transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- cards table
CREATE TABLE cards (
    card_id INT PRIMARY KEY,
    account_id INT,
    card_type ENUM('Debit','Credit'),
    card_number VARCHAR(20),
    expiry_date DATE,
    cvv INT,
    status ENUM('Active','Blocked'),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Fraud Detection\\cards.csv'
INTO TABLE cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Alerts Table
CREATE TABLE alerts (
    alert_id INT PRIMARY KEY,
    transaction_id INT,
    alert_type VARCHAR(50),
    alert_date DATETIME,
    status ENUM('Open','Closed'),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Fraud Detection\\alerts.csv'
INTO TABLE alerts
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Basic Queries
#1. Find all active accounts
SELECT concat(first_name, " ", last_name) Full_Name, account_status
FROM customers, accounts
WHERE customers.customer_id = accounts.customer_id
AND account_status = 'Active';

#2. Count the total number of transactions per transaction type.
SELECT transaction_type, count(amount) Total_Number_Transaction
FROM transactions
GROUP BY transaction_type;

#3. Show customers along with their account types.
SELECT concat(first_name," ",last_name) Full_name, account_type
FROM customers c, accounts a
WHERE c.customer_id = a.customer_id;

#4. Count the number of accounts per customer.
SELECT customers.customer_id, concat(first_name," ",last_name) Full_Name, count(account_id) Accounts_Per_Customer
FROM customers, accounts
WHERE customers.customer_id = accounts.customer_id
GROUP BY customers.customer_id
ORDER BY customers.customer_id;

-- Intermediate Queries
#5. Find the total transaction amount per account.
SELECT t.account_id, concat(first_name," ",last_name) Full_Name, sum(amount) Total_transaction
FROM transactions t, accounts a, customers c 
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
GROUP BY t.account_id
ORDER BY Total_transaction desc;

#6. Show the top 10 accounts with the highest total transaction amounts.
SELECT a.account_id, concat(first_name," ",last_name) Full_Name, 
	   sum(amount) Total_amount
FROM transactions t, accounts a, customers c
WHERE t.account_id = a.account_id 
AND 
a.customer_id = c.customer_id
GROUP BY a.account_id
ORDER BY Total_amount desc
LIMIT 10;

#7. Display the total number of fraudulent transactions per account.
SELECT a.account_id, 
	   concat(first_name, " ", last_name) Full_Name, 
	   sum(is_fraud) Total_No_Fraud
FROM accounts a, customers c, transactions t 
WHERE a.account_id = t.account_id AND a.customer_id = c.customer_id
GROUP BY a.account_id
ORDER BY Total_No_Fraud desc;

#8. Find the average transaction amount per transaction type.
SELECT transaction_type, 
	   round(avg(amount),2) Avg_Transaction_Amount
FROM transactions
GROUP BY transaction_type;

#9. Display the number of transactions per device type (Mobile, Web, ATM).
SELECT device, count(*) Total_Transaction
FROM transactions
GROUP BY device;

#10. List all customers who have more than one account.
SELECT c.customer_id, concat(first_name," ",last_name) Full_Name, count(account_id) Total_No_Accounts
FROM customers c, accounts a 
WHERE c.customer_id = a.customer_id 
GROUP BY c.customer_id
ORDER BY Total_No_Accounts desc;

#11. Find accounts that have never had a fraudulent transaction.
SELECT c.customer_id, concat(first_name," ",last_name) Full_Name, a.account_id
FROM transactions t, customers c, accounts a
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
AND
a.account_id NOT IN (SELECT distinct account_id
				     FROM transactions 
                     WHERE is_fraud = 1);
                     
#12. List all alerts with the corresponding transaction amount and account ID.
SELECT a.alert_id, a.alert_type, a.status, t.amount, t.account_id
FROM alerts a, transactions t
WHERE a.transaction_id = t.transaction_id;

#13. Show the most common transaction location.
SELECT location, count(location) Common_Location
FROM transactions
GROUP BY location 
ORDER BY Common_Location desc
LIMIT 1;

-- Advanced Level
#14. Find accounts with more than 2 fraudulent transactions.
SELECT a.account_id, 
	   concat(first_name," ",last_name) Full_Name, 
       sum(is_fraud) Total_Fraud
FROM transactions t, accounts a, customers c
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
GROUP BY a.account_id 
HAVING Total_fraud > 2;

#15. Detect customers whose transactions exceed 90 Thousand in a single day.
SELECT a.account_id, 
	   concat(first_name," ",last_name) Full_Name, 
       sum(amount) Total_amount, DATE(transaction_date) Transaction_Date
FROM transactions t, accounts a, customers c
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
GROUP BY a.account_id, Transaction_Date
HAVING Total_amount > 90000;

#16. Show the top 5 locations with the highest number of fraud transactions. 
SELECT location, sum(is_fraud) Total_No_Fraud
FROM transactions
GROUP BY location
ORDER BY Total_No_Fraud desc
LIMIT 5;

#17. Find the average transaction amount for fraudulent vs non-fraudulent transactions.
SELECT is_fraud, round(avg(amount),2) Average_amount
FROM transactions
GROUP BY is_fraud;

#18. Identify customers who made transactions from multiple cities in a single day.
SELECT a.account_id, concat(first_name, " ", last_name) Full_Name, DATE(transaction_date) Trans_Date, Count(distinct location) Multiple_Cities
FROM transactions t, customers c, accounts a 
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
GROUP BY Trans_Date, a.account_id
HAVING Multiple_cities > 1;

#19. List accounts that had fraudulent transactions on consecutive days.
SELECT *
FROM (SELECT *, datediff(lead(date(transaction_date)) over(partition by account_id order by transaction_date), DATE(transaction_date)) datediff
	  FROM transactions where is_fraud = 1) d
where d.datediff = 1;

#20. Find customers whose total withdrawal amount in a month exceeds 2 lakh.
SELECT account_id, transaction_type, count(transaction_type) Total_Transaction, sum(amount) Total_amount, month(transaction_date) Months
FROM transactions
WHERE transaction_type = 'Withdrawal'
GROUP BY account_id, Months
HAVING Total_amount > 200000;

#21. Show accounts where the total fraud amount is more than 10% of the account balance.
SELECT accounts.account_id, account_balance, sum(amount) Fraud_amount
FROM accounts, transactions
WHERE accounts.account_id = transactions.account_id
AND is_fraud = 1
GROUP BY accounts.account_id
HAVING Fraud_amount > 0.1 * account_balance;

#22. Generate a monthly summary report of total transactions, total frauds, and total alerts.
SELECT account_id, MONTH(transaction_date) Monthly, count(transaction_type) Total_transactions, sum(is_fraud) Total_Fraud, count(alert_id) alerts
FROM transactions t, alerts a
WHERE t.transaction_id = a.transaction_id
AND 
is_fraud = 1
GROUP BY account_id, monthly
HAVING count(*) > 1
ORDER BY Monthly asc;

#23. Identify high-risk accounts using a combination of number of transactions, total fraud amount, and number of alerts.
SELECT acc.account_id, 
       count(t.transaction_id) Total_Transaction, 
       sum(is_fraud) Total_fraud, sum(amount * is_fraud) Total_Fraud_Amount, 
       count(alert_id) Total_Alerts
FROM transactions t
JOIN accounts acc
ON t.account_id = acc.account_id
LEFT JOIN alerts a
ON t.transaction_id = a.transaction_id
GROUP BY acc.account_id
HAVING Total_Fraud > 2 OR Total_Fraud_Amount > 50000 OR Total_Alerts > 2
ORDER BY Total_Fraud desc;

#24. Find customers who had multiple frauds within the same hour.
SELECT c.customer_id, a.account_id, 
	   concat(first_name," ",last_name) Full_Name, 
       hour(transaction_date) Hourly, 
       SUM(is_fraud) Fraud_Count, 
       date(transaction_date) Trans_Date, 
       count(c.customer_id)
FROM transactions t, accounts a, customers c 
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
AND is_fraud = 1
GROUP BY Hourly, a.account_id, Trans_Date
ORDER BY Fraud_Count desc
LIMIT 5;

#25. Show the top 5 accounts with the highest fraud-to-balance ratio.
SELECT a.account_id, account_balance,
	   sum(amount * is_fraud) Total_Fraud_amount,
       round((sum(amount * is_fraud) * 100) / account_balance,2) Fraud_To_Balance
FROM transactions t, accounts a
WHERE t.account_id = a.account_id
GROUP BY a.account_id, account_Balance
ORDER BY Fraud_To_Balance desc
LIMIT 5;

#26. Find customers whose fraud transaction count is greater than 30% of their total transactions.
SELECT c.customer_id, a.account_id, sum(is_fraud) Total_Fraud_Count, 
	   round((sum(is_fraud) * 100/count(*)),2) Percentage_Fraud
FROM transactions t, accounts a, customers c
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
GROUP BY a.account_id, c.customer_id
HAVING Percentage_Fraud > 30
ORDER BY Total_Fraud_Count desc;

#27. Find accounts where the average fraud transaction amount is higher than the account’s average normal transaction amount.
SELECT account_id,
	   ROUND(AVG(CASE WHEN is_fraud = 1 THEN amount END),2) Average_Fraud_Amount,
       ROUND(AVG(CASE WHEN is_fraud = 0 THEN amount END),2) Average_Normal_Amount
FROM transactions
GROUP BY account_id
HAVING Average_Fraud_Amount > Average_Normal_Amount;

#28. Identify customers who had fraud transactions in more than 3 different cities.
SELECT c.customer_id, a.account_id, 
	   concat(first_name," ",last_name) Full_Name, 
       count(distinct location) Diff_Cities
FROM transactions t, accounts a, customers c
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
AND
is_fraud = 1
GROUP BY a.account_id
HAVING Diff_Cities = 3;

#29. Detect accounts with sudden large frauds (fraud amount > 2x their average normal transaction amount).
SELECT concat(first_name, " ", last_name) Full_Name, a.account_id, 
	   round(sum(CASE WHEN is_fraud = 1 THEN amount END),2) Total_Fraud_Amount,
	   (round(avg(CASE WHEN is_fraud = 0 THEN amount END),2) * 2) Avg_Normal_Amount_2x
FROM transactions t, accounts a, customers c
WHERE t.account_id = a.account_id AND a.customer_id = c.customer_id
GROUP BY a.account_id
HAVING Total_Fraud_Amount > Avg_Normal_Amount_2x
ORDER BY Avg_Normal_Amount_2x desc;

-- =============================================== Thankyou =============================================================
	
       





















                   




