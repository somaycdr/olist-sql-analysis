# olist-sql-analysis# Olist E-Commerce SQL Analysis (MySQL)

Business analysis of the Brazilian Olist e-commerce dataset (2016-2018) using MySQL 8.

## Dataset
[Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Tables used: customers, orders, order_items, products, category_translation.
Revenue = item price of delivered orders (excludes shipping). Currency: BRL.

## Business Questions and Key Findings

| # | Question | Key finding |
|---|---|---|
| Q1 | Monthly revenue and orders | 13.22M total revenue, 96,478 delivered orders. Peak Nov 2017 (987,765; 7,289 orders). Jan-Aug 2018 revenue ~2.4x Jan-Aug 2017 |
| Q2 | Top 10 categories by revenue | Top 10 = ~62% of revenue. health_beauty #1 (1.23M, 9.3%) |
| Q3 | State-wise customers and revenue | SP = 38% of revenue; top 3 states (SP, RJ, MG) = 63% |
| Q4 | Average delivery time by state | SP 8.7 days vs RR 29.3 days; overall ~12.5 days |
| Q5 | Late delivery % | 8.11% of delivered orders (7,826 of 96,470) arrived after the estimated date |
| Q5b | Late % by state (100+ orders) | AL highest (23.9%); RJ 13.5% vs SP 5.9%. Slow does not always mean late (AM: 26 days, 4.1% late) |
| Q6 | Month-over-month growth (LAG) | Revenue grew in 13 of 19 months. Biggest spike Nov 2017 (+52.4%), biggest drop Dec 2017 (-26.5%). Growth flat through 2018 |
| Q7 | Top 5 categories per year (RANK) | Same top 5 in 2017 and 2018. health_beauty moved #3 to #1; bed_bath_table #1 to #3 (2018 = Jan-Aug only) |
| Q8 | Repeat vs one-time customers | 97% one-time (90,557), 3% repeat (2,801) |

## SQL Skills Used
JOINs (up to 4 tables), GROUP BY / HAVING, CASE WHEN, CTEs, window functions (LAG, RANK with PARTITION BY), DATEDIFF, DATE_FORMAT, aggregate functions.

## Data Notes
- No delivered orders in Nov 2016 and only 1 each in Sep and Dec 2016, so trend analysis starts from Jan 2017.
- 8 delivered orders have no delivery date and are excluded from delivery-time queries.
- customer_unique_id (not customer_id) is used to count real customers.

## Files
- `sql/03_analysis_queries.sql`: all analysis queries with comments
