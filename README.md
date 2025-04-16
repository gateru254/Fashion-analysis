# Fashion Analysis 👚.
- The project analyzes fashion trends, styles, and consumer behaviour using SQL.
## Overview 
 - The Fashion analysis project leverages data visualization and statistical methods to identify patterns, predict trends, and understand customer preferences.

## Steps 🪜
- Sign up [Aiven](https://aiven.io) or login,to create a new service and select PostgreSQL
- Launch Dbeaver, Create a new PostgreSQL database connection.
- Insert/Write/Paste the credentials from the aiven account to the Dbeaver ie,Host,Port,Postgress,Username ,Password
- Test connection ✅
- Create fashion table, Insert values to the fashion table.

### Files 📂
  - fashion script --  SQL queries for fashion analysis
  - Fashion script1 -- fashion data
-  Fashion analysis update.pptx -- Power point presentation for the insights and recommedation

---

### Data Cleaning 🧹
:one: Converting data types order_date and delivery to date type
   
:two: Making delivery days > order days

```sql
    update fashion 
    set order_date=delivery_date,
    delivery_date = order_date 
    where order_date> delivery_date
 ```

:three: Renaming column names    
```sql
       alter table fashion rename category to clothingtype1
     ---then rename clothing type to category 
        alter table fashion rename clothing_type to category 
     ---renaming it to the initial column name 
        alter table fashion rename clothingtype1 to clothing_type 
```
 --- 
 
### Exploratory Data Analysis
- Using the cleaned dataset, we explored:
  
  **Objectives**
  - Consumer behaviour
  - Sales trends over time
  - Inventory performance
  - Time Series analysis.
 ### Findings 🔎
:one: Identify the top 5 selling products.
```sql 
select category,sum(revenue) as total_sales
from fashion
group by 1
order by total_sales desc 
limit 5;
```
>>Output
 
| Category  | Total Sales (USD) | 
|-----------|-------------------|
| Women     | $178,421.30       |
| Children  | $174,068.61       |
| Men       | $147,875.52       |

:two: Get the total sales per year 
```sql
     select  extract(year from order_date)as order_year,sum(revenue) as total_sales
     from fashion
     group by order_year
     order by total_sales desc;
```

>>Output

| Year | Total Sales (USD) |
|------|-------------------|
| 2022 | $336,154.14       |
| 2023 | $122,738.23       |
| 2024 | $41,473.06        |

:three: Determine the monthly trend of total sales.
```sql
     select to_char(month from order_date)as month_order,sum(revenue) as total_sales 
     from fashion
     group by month_order
     order by total_sales desc;
```
>>> output

| Month     | Total Sales (USD) |
|-----------|-------------------|
| April     | $80,571.50        |
| May       | $58,494.43        |
| March     | $55,121.90        |
| January   | $53,830.08        |
| October   | $45,156.63        |
| September | $38,624.82        |
| June      | $36,209.08        |
| July      | $36,034.30        |
| February  | $32,434.34        |
| November  | $27,642.11        |
| August    | $26,097.57        |
| December  | $10,148.67        |

:four: Compare the number of repeat vs new customers. 
```sql
select customer_category,count(*) as no_of_customers
from 
(select count(*) as no_of_customers, customer_name,
case 
	 when count(*)=1 then 'new'
	 when count(*)>1 then 'repeat'
end as customer_category
from fashion
group by customer_name)
group by customer_category;
```
>>> Output

| Customer category| No of Customers |
|------------------|-----------------|
| new	             |100              |

:five: Analyze sales distribution by day of the week.

```sql
select to_char(order_date,'day') as day_of_week,sum(revenue) as total_sales
from fashion 
group by day_of_week 
order by total_sales desc;
```
>>> Output

| Day       | Total Sales (USD) |
|-----------|-------------------|
| Friday    | $93,422.07        |
| Saturday  | $90,778.29        |
| Tuesday   | $79,751.76        |
| Sunday    | $68,645.34        |
| Monday    | $65,587.57        |
| Thursday  | $63,625.21        |
| Wednesday | $38,555.19        |

---
### Additional resources 
- Find more questions and insights in the fashion script file.
- Fashion analysis update (pptx) has both the findings and recommendation for the fashion analysis project.

---

### Technology
SQL: Language used to extract,retrieve and analyze data.

PostgreSql: Database used to analyze the data.

Data Visualization Tools : Excel.

Dataset: Fashion

### Contributors:👥
@https://github.com/gateru254  - Data cleaning,analysis,insight generation and documentation.

@https://github.com/Katekariuki - Data cleaning,analysis,insight generation and documentation.
























  
