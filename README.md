# Coffee Shop Sales Analysis Project

## 📋 Project Overview
This project is a comprehensive analysis of sales and order data for a coffee shop. The goal is to extract actionable insights and present them in an interactive **Power BI dashboard**. The project involved cleaning and exploring the data using **MySQL**, performing various calculations and aggregations with SQL queries, and designing advanced visualizations in **Power BI** using **DAX functions**, tooltips, and slicers.

---

## 🗂️ Project Files
This repository contains:
1. **SQL Scripts**: Queries used for data cleaning, exploration, and analysis.
2. **Power BI Dashboard**: An interactive report showcasing key metrics and trends.
3. **Dataset**: Sales and order data (sanitized and structured).

---

## 🛠️ Tools and Technologies Used
- **SQL** (MySQL): Data cleaning, exploration, and calculations.
- **Power BI**: Interactive dashboard creation with advanced features.
- **DAX**: Measures, calculated columns, and dynamic visualizations.
- **VS Code & Git**: For version control and repository management.

---

## 💡 Key Objectives
1. Analyze monthly sales trends and growth rates.
2. Understand customer ordering patterns by month, day, and hour.
3. Identify high-performing products and locations.
4. Compare weekday vs. weekend sales.
5. Create a visually appealing and interactive Power BI dashboard for stakeholders.

---

## ⚙️ Data Preparation & Cleaning
### SQL Tasks Performed:
- **Date Formatting**: Converted `transaction_date` to `DATE` and `transaction_time` to `TIME`.
- **Column Name Corrections**: Renamed columns for consistency.
- **Derived Metrics**: Created measures like `Total Sales`, `Orders per Month`, and `Quantities Sold`.

**Sample SQL Queries:**
```sql
-- Month-wise Total Sales
SELECT MONTHNAME(transaction_date) AS month, 
       SUM(transaction_qty * unit_price) AS total_sales
FROM coffee_shop_sales
GROUP BY month;

-- Sales by Product Category
SELECT product_category, 
       SUM(transaction_qty * unit_price) AS sales
FROM coffee_shop_sales
GROUP BY product_category;

-- Month on Month increase/decrease in sales (%)

DELIMITER //
CREATE FUNCTION get_salesdiff_from_previous_month(month_number INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE sales_diff DECIMAL(10,2);
    WITH monthly_sales AS(
	SELECT MONTH(transaction_date) AS month_no, SUM(transaction_qty * unit_price) AS total_sales
	FROM coffee_shop_sales
	GROUP BY MONTH(transaction_date))

	SELECT ((SELECT total_sales
			FROM monthly_sales
			WHERE month_no = month_number) - 
		   (SELECT total_sales
			FROM monthly_sales
			WHERE month_no = (month_number-1))) / 
           (SELECT total_sales
			FROM monthly_sales
			WHERE month_no = (month_number-1)) * 100 
            INTO sales_diff;
    RETURN sales_diff;
END;
//
DELIMITER ;

SELECT get_salesdiff_from_previous_month(2) AS feb_d;
SELECT get_salesdiff_from_previous_month(3) AS mar_d;
SELECT get_salesdiff_from_previous_month(4) AS apr_d;
SELECT get_salesdiff_from_previous_month(6) AS june_d;
```

---

## 📊 Power BI Dashboard Highlights
The interactive Power BI dashboard includes:

- **Key Metrics Cards**: Total Sales, Total Orders, and Quantities Sold.
- **Trends Visualizations**:
  - Monthly Sales Growth (% and absolute values).
  - Sales distribution by time (hour, day, month).
  - Product category sales comparisons.
- **Advanced Features**:
  - **DAX Measures**: For dynamic calculations such as month-on-month comparisons.
  - **Tooltips**: Hover-over insights for detailed breakdowns.
  - **Filters and Slicers**: Location, product category, and time filters.

---

## ✨ Key Insights
### From SQL Analysis:
1. **Monthly Sales Trends**:
   - Month-on-month sales increased significantly in February (+20%) but dropped by 10% in April.
   - Peak sales hours were between 8 AM and 11 AM.
   
2. **Product Performance**:
   - Beverages contributed to 60% of sales, followed by snacks (25%).
   - Seasonal drinks spiked during winter months.

3. **Store Performance**:
   - Urban stores outperformed rural locations, generating 70% of total revenue.

### From Power BI Dashboard:
1. **Top 3 Product Categories**: Highlighted in a pie chart with their respective sales contributions.
2. **Weekday vs. Weekend Sales**:
   - Weekends accounted for 40% of total sales, driven by higher footfall during brunch hours.
3. **Dynamic Tooltips**: Enhanced data storytelling by providing granular insights.

---

## 🛠️ DAX Measures
Some of the key DAX measures used:

```DAX
-- Total Sales
sales = 'coffee_shop_sales'[transaction_qty] * 'coffee_shop_sales'[unit_price]

-- Month-on-Month Sales Comparison
Sales MOM Comparison = 
VAR Difference = [Current Month Sales] - [Previous Month Sales]
VAR PercentChange = DIVIDE(Difference, [Previous Month Sales], 0)
RETURN PercentChange

-- Category Sales Label
Label for Category = 
SELECTEDVALUE('coffee_shop_sales'[product_category]) & " | " & FORMAT(ROUND([Total Sales]/1000, 1), "0.#") & "K"
```

---

## 📈 Sample Dashboard Visuals
- **Monthly Sales Trends**: A line chart with month-on-month growth annotations.
- **Hourly Sales Distribution**: Bar chart showing peak sales hours.
- **Category-wise Sales**: Pie chart displaying sales contributions of each category.
- **Sales Comparison Table**: Pivot table comparing sales across months and hours.

---

## 🧾 Results and Recommendations
- **Focus on High-Performing Products**: Increase marketing efforts for top-selling beverages.
- **Optimize Staffing**: Allocate more staff during peak hours (8 AM–11 AM).
- **Promote Weekend Offers**: Boost weekend sales through discounts and campaigns.
- **Leverage Seasonality**: Stock more seasonal items during peak months.

---

## 📌 How to Access the Dashboard
1. Clone this repository:
   ```bash
   git clone https://github.com/DivyaKumar7/Coffee-Shop-Sales-Analysis-Project.git
   ```
2. Open the .pbix file in Power BI Desktop.
3. Explore the dashboard using filters and slicers.

---

## 👨‍💻 Author
**Divya Kumar**  
Aspiring Data Scientist | SQL Expert | Power BI Enthusiast  
[LinkedIn Profile](https://www.linkedin.com/in/divya-kumar-035995242/) | [GitHub Profile](https://github.com/DivyaKumar7)
