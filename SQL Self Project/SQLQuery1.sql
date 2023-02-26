select top 1 * from Customers
select top 1 * from Orders
select top 1 * from OrderDetails
select top 1 * from Category
select top 1 * from Shippers
select top 1 * from Payments
select top 1 * from suppliers
select top 1 * from products

---Get the Total Revenue generated through each Payment Method.
---Consider the Total Order Amount of orders to calculate the Total Revenue.
---Print the Payment ID and Total Revenue in your result.
---Sort the result set in ascending order of Payment ID.

select paymentid,sum(total_order_amount)as revenue from orders 
group by paymentid 
order by paymentid

---Get the MAX Sale Price of Products across each Sub-Category
---Sort the result set in alphabetical order of sub category

select sub_category,max(sale_price)as max_sales_price from products 
group by sub_category order by sub_category

---Identify the 16th order placed by each customer if any.
---Print CustomerID, OrderID, FirstName, LastName, PaymentID, OrderDate, Total_Order_Amount in the result.
---Sort the result set in ascending order of CustomerID

with cte as ( select c.CustomerID,OrderID,FirstName,LastName,PaymentID,OrderDate,total_order_amount, 
dense_rank() over(partition by c.customerid order by orderdate) as s_no from Customers c 
join orders o on o.CustomerID=c.CustomerID ) select CustomerID,OrderID,FirstName,LastName,PaymentID,OrderDate,total_order_amount 
from cte where s_no=16 order by CustomerID

---Let the Billing_Code start with eight 0s, followed by first 3 characters of OrderID, followed by first 3 letters of 
---the customer’s First Name.
---Print OrderId and Billing_Code.
---Sort the result in ascending order of OrderID

select orderid,concat('00000000',left(orderid,3),left(firstname,3))as Billing_Code from customers c 
join orders o on c.customerid=o.customerid order by orderid;

--Print ProductID and the combination of Brand Name and Product Name.
--The Brand Name and the Product Name should be separated by a space, an hyphen, followed by another space.
--Sort the result set in ascending order of ProductID

select productid,concat(brand,' - ',product)as we from Products order by productid

---Identify the orders for which one of the suppliers is based out of India.
---Finally print the count of such orders placed on each individual order date
---Print the final output in descending order of orderdate.

select o.OrderDate, COUNT(distinct o.OrderID)as order_id from Orders o join OrderDetails od on o.OrderID = od.OrderID 
join Suppliers s on s.SupplierID = od.SupplierID where Country = 'India' group by o.OrderDate order by o.OrderDate desc

---Calculate the number of orders placed in each month of each of the different years.
---Print Year, Month, the cumulative sum of count of orders and the cumulative average of count of orders in 2 separate columns.
---Sort the result in ascending order of Year, secondary sort on the basis calendar order of Months.

with cte as ( select year(orderdate) as year , month(OrderDate) as month, monthname( OrderDate) as monthname , 
count(OrderID) as order_num from orders group by year(orderdate), month(OrderDate),monthname( OrderDate) ) 
select year , monthname , sum(order_num) over(order by year,month) as cumulative_sum, 
avg(order_num) over (order by year,month) as cumulative_avg from cte


---Identify the City from all country from which the most orders were placed.
---Print Country, City, Number of orders from the city.
---Sort the result set in alphabetical order of Country names, City names

with cte as(select country,city,count(orderid) as order_num from customers c 
join orders o on c.customerid=o.customerid group by country, city 
),
cte1 as(select *, dense_rank() over(partition by country order by order_num desc)as rnk from cte
)select country, city, order_num from cte1 
where rnk=1 
order by country


---Identify top 5 categories which had the highest quantity of products ordered.
---Print Category ID, Category Name and Corresponding Total Quantity.
---Sort the result in descending order of Total Quantity

select top 5 c.categoryid,categoryname,sum(od.quantity) from products p 
join category c on c.categoryid=p.category_id join orderdetails od on p.productid=od.productid
group by c.categoryid,c.categoryname order by sum(od.quantity)desc 

---Print Payment Type, Allowed, followed by total transaction value.
---Consider Total Order Amount to calculate the total transaction value.
---Sort the result in alphabetical order of Payment Type.

select p.PaymentType,p.Allowed,sum(o.total_order_amount)as total_transaction_value from payments p 
left join orders o on p.paymentid=o.paymentid 
group by paymenttype,p.Allowed
order by PaymentType

---Write a query to find the shipdate of the 10th following OrderID.
---Print all the details from orders table and the 10th following shipdate

select *,lead(shipdate,10) over(order by orderid)as ord from orders


---Print Order ID,Shipper ID, Total order amount and 3 day rolling sum. (Find the 3 day rolling sum by 
---taking 2 previous rows and the current row.)
---Sort the result in ascending order of Shipper ID, for records with same 
---shipper ID, sort them in ascending order of Order ID

select orderid,shipperid,total_order_amount,sum(total_order_amount) 
over(partition by shipperid order by orderid rows between 2 preceding and current row)as f from orders 
order by shipperid,orderid

---Print all details of Orders which were placed by Customers whose ID is a multiple of 10,
---payment method by Payment with ID 4, shipped by Shipper with ID 3 and which are greater than 30,000 in order value.
---Sort the result set in descending order of Customer ID

select * from orders where (customerid % 10)=0 and paymentid like '%4%' and shipperid like '%3%'
and total_order_amount>30000 order by customerid desc

---Categorize the customers on the basis of the decade in which they were born.
---For example decade ‘50s’ is defined as year range between 1950 and 1959.
---decade ‘60s’ is defines a year range between 1960 and 1969 etc.
---Make sure you are using a lower case ‘s’ when giving the alias to each decade range.
---Print the decade followed by the corresponding count of customers from the decade.
---Sort the result set in ascending order of the Decade category.

select decade,count(customerid) from(select *,(case when year(date_of_birth) 
between 1950 and 1959 then '50s' when year(date_of_birth) between 1960 and 1969 then '60s' 
when year(date_of_birth) between 1970 and 1979 then '70s' 
when year(date_of_birth) between 1980 and 1989 then '80s' 
when year(date_of_birth) between 1990 and 1999 then '90s' else '20s' end)as decade from customers)
as c group by decade order by decade


---Identify the City from all country from which the most orders were placed.
---Print Country, City, Number of orders from the city.
---Sort the result set in alphabetical order of Country names, City names

with cte as(select country,city, count(orderid) as order_num from customers c 
join orders o on c.customerid=o.customerid group by country,city ), 
cte1 as ( select *, dense_rank() over(partition by country order by order_num desc)as rnk from cte ) 
select country,city,order_num from cte1 where rnk=1 order by country


---The values in the matrix represent total sum of quantity of products supplied out to orders 
---ordered through the different years and quarters. (Consider OrderDate)
---Sort the result in ascending order of Year, for records with same year, sort them in ascending order of Quarter

select year(orderdate),datepart(quarter,orderdate),sum(case when s.supplierid ='1' then quantity end)as 
Supplier_1, sum(case when s.supplierid ='2' then quantity end)as Supplier_2,
sum(case when s.supplierid ='3' then quantity end)as Supplier_3,
sum(case when s.supplierid ='4' then quantity end)as Supplier_4,
sum(case when s.supplierid ='5' then quantity end)as Supplier_5,
sum(case when s.supplierid ='6' then quantity end)as Supplier_6 from orders o 
join orderdetails od on o.orderid=od.orderid join suppliers s on od.supplierid=s.supplierid 
group by year(orderdate),datepart(quarter,orderdate)
order by year(orderdate),datepart(quarter,orderdate) 


---Print CustomerID and the Full Name in the final output. Sort the result in ascending order of CustomerID.
---If you see blank cells in the full name column that means you have concatenated a string with null.
---For such cases just print the first name without any concatenation.

select customerid,concat(firstname,' ',isnull(lastname,'')) as full_name from customers order by customerid;

---Calculate the amount of discount applied on each product using the sale and market prices of each product listed in the database.
---Print ProductID, Product Name, Sale Price, Market Price followed by the discount percentage. Make sure to only print the
---integer value of the discount percentage that you  calculate. Sort the result in ascending order of ProductID.

select productid,product,sale_price,market_price,floor(((market_price - Sale_price)*100)/market_price) from products


---Print month names followed by the number of orders delivered in that particular month for all months of the year 2020.
---Sort the result in descending order of order count

select datepart(month,deliverydate),count(orderid)from orders where year(deliverydate)='2020' 
group by datepart(month,deliverydate) order by count(orderid) desc;
