
---------------------------------------------------DATA PREPARATION AND UNDERSTANDING-----------------------------------------------------------------------------

---Q1.	What is the total number of rows in each of the 3 tables in the database?

       SELECT * FROM
(SELECT 'CUSTOMER' AS TABLE_NAME, COUNT(*) AS NO_RECORDS FROM CUSTOMER UNION ALL
SELECT 'TRANSACTIONS' AS TABLE_NAME, COUNT(*) AS NO_RECORDS FROM TRANSACTIONS
UNION ALL
SELECT 'PROD_CAT_INFO' AS TABLE_NAME, COUNT(*) AS NO_RECORDS FROM PROD_CAT_INFO)
AS T1---2. What is the total number of transactions that have a return?SELECT COUNT(TRANSACTION_ID) AS COUNT_TRANSACTIONS
FROM TRANSACTIONS
WHERE QTY < 0 

---3. As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls convert the date variables 
---into valid date formats before proceeding ahead.        select convert(date,tran_date,105) as tran_date from Transactions

	   select convert(date,dob,105) as Dob from Customer

----4. What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in different columns.       	  

	  select
          datediff(day,min(tran_date),max(tran_date)) as DIFFERENCEIN_DAYS,
          datediff(month,min(tran_date),max(tran_date)) as DIFFERENCEIN_MONTHS,
          datediff(year,min(tran_date),max(tran_date)) as DIFFERENCEIN_YEARS
		  from Transactions


----5. Which product category does the sub-category “DIY” belong to?  

         SELECT PROD_CAT 
		 FROM prod_cat_info
		 where prod_subcat = 'DIY'

		 -------------------------------------------------------------------DATA ANALYSIS----------------------------------------------------------------------------------------1. Which channel is most frequently used for transactions?          		 SELECT TOP 1 STORE_TYPE, COUNT (STORE_TYPE) AS COUNT_CHANNEL_TYPE		 FROM Transactions		 GROUP BY Store_type		 ORDER BY COUNT(STORE_TYPE) DESC----------- Q2: WHAT IS COUNT OF MALE AND FEMALE CUUSTOMERS IN DATABASE 		SELECT COUNT(CUSTOMER_ID) AS COUNT_OF_MALES		FROM Customer		WHERE GENDER = 'M'				SELECT COUNT(CUSTOMER_ID) AS COUNT_OF_FEMALES		FROM Customer		WHERE GENDER = 'F'        ------------3. From which city do we have the maximum number of customers and how many? SELECT TOP 1 CITY_CODE , COUNT(CUSTOMER_ID) as MAX_CUSTFROM CustomerGROUP BY city_codeORDER BY COUNT(CUSTOMER_ID) DESC----------4. How many sub-categories are there under the Books category?		SELECT PROD_CAT , COUNT (PROD_SUBCAT) AS COUNT_SUB_CATEGORIES 		FROM prod_cat_info		WHERE prod_cat = 'BOOKS'		GROUP BY prod_cat  ---------5. What is the maximum quantity of products ever ordered?

		SELECT MAX(QTY) AS MAX_QTY_SOLD
		FROM Transactions
		WHERE Qty>0


--------6. What is the net total revenue generated in categories Electronics and Books?


     SELECT SUM(CONVERT(NUMERIC,TOTAL_AMT)) AS NET_REVENUE FROM prod_cat_info
	 LEFT JOIN Transactions
	 ON prod_cat_info.prod_cat_code=Transactions.prod_cat_code
	                  AND 
      Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
	 WHERE prod_cat IN ('ELECTRONICS' , 'BOOKS') 




--------7. How many customers have >10 transactions with us, excluding returns?
  

     SELECT CUST_ID , COUNT (TRANSACTION_ID) AS COUNT_TRANSCATION
	 FROM Transactions
	 WHERE Qty > 0
	 GROUP BY cust_id
	 HAVING COUNT (TRANSACTION_ID) > 10 



-------8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”? 


        SELECT SUM(CONVERT(NUMERIC , total_amt)) AS Combined_revenue
        From prod_cat_info
        LEFT JOIN Transactions
        ON prod_cat_info.prod_cat_code=Transactions.prod_cat_code
                  AND 
        prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
        Where Store_type = 'Flagship Store' AND 
        prod_cat IN ( 'ELECTRONICS' , 'CLOTHING') 


------9. What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat. 
 
       Select prod_subcat,
SUM(CAST(Total_Amt as NUMERIC)) [REVENUE]
FROM
	(SELECT cust_id ,prod_subcat,
    Total_Amt  
	FROM Transactions 
    Left Join prod_cat_info
    ON Transactions.prod_cat_code = prod_cat_info.prod_cat_code
                                 And
    	Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
    WHERE prod_cat = 'Electronics'
	    ) as Z
Left Join Customer
ON Z.cust_id = Customer.customer_Id
WHERE Gender = 'M'
GROUP BY prod_subcat 


-------10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales? 


		  SELECT TOP 5
          prod_subcat,SUM(CAST(Total_Amt as NUMERIC)) [Total Sales], SUM(Sales)*100 / SUM(SUM(SALES)) OVER() Percent_Sales,
          SUM(Returns)*100 / Sum(Sum(Returns)) OVER() Percent_Return
          FROM 
          (SELECT prod_subcat, total_amt,
          CASE WHEN CAST(Total_Amt as numeric) < 0
          THEN Abs(CAST(Total_Amt as numeric))
          ELSE 0
          END [Returns],
          CASE WHEN CAST(Total_Amt as numeric) > 0
          THEN ABS(CAST(Total_Amt as numeric))
          ELSE 0
          END [Sales]
          FROM Transactions
          Left Join prod_cat_info
          ON Transactions.prod_cat_code = prod_cat_info.prod_cat_code
                                           And
          Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
          	) as X
          Group by prod_subcat
          Order by [Total Sales] Desc
          
          

---11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max 
---transaction date available in the data?


     Select SUM(Cast(Total_amt as Numeric)) [Total Revenue]
From
    (Select total_amt 
     From Transactions
     Left Join Customer
     on Transactions.cust_id = Customer.customer_Id
     Where DATEDIFF(YEAR,Convert(Date,DOB,105),GETDATE()) Between 25 and 35
	                             And
          DATEDIFF(Day,Convert(Date,Tran_Date, 105),(Select Max(Convert(Date,Tran_Date,105)) from Transactions))  <=30
) as Z




---12.Which product category has seen the max value of returns in the last 3 months of transactions? 


Select Top 1 Prod_Cat
From
     (Select prod_cat, Count(Transaction_id) Return_Count
      From Transactions
      Left Join prod_cat_info
      on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
                                    And
      Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
      Where CAST(Total_amt as numeric) < 0
                    And
      	 Datediff(MONTH, Convert(Date,Tran_Date,105),(Select Max(Convert(Date,Tran_Date,105)) from Transactions)) <= 3
      Group by prod_cat
) as Z
Order by Return_Count Desc



---13.Which store-type sells the maximum products; by value of sales amount and by quantity sold? 

     Select Top 1 Store_type
From
   (Select Store_type, Sum(Cast(Total_Amt as Numeric)) as [Sales],
    Sum(Cast(Qty as numeric)) as [Quantity]
    From Transactions
    Group by Store_type
   ) As Z 
Order by Sales desc , Quantity Desc


---14.What are the categories for which average revenue is above the overall average. 
   
    Select prod_cat
From
   (Select prod_cat , AVG(Cast(Total_Amt as Numeric)) [Category Average]
    From Transactions
    Left Join prod_cat_info
    on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
                                 And
       Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
    Group by prod_cat
   ) as X
Where [Category Average] > (Select AVG(Cast(Total_amt as numeric)) From Transactions)


--15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold. 

Select y.prod_cat, prod_subcat , [Average Revenue], [Total Revenue]
From
    (Select Top 5 prod_cat , SUM(Cast(Qty as numeric)) Quantity
    From Transactions
    Left Join prod_cat_info
    on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
                                 And
       Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
    Group by prod_cat
    Order by Quantity desc) as X
Inner Join    
    (Select prod_cat, prod_subcat , AVG(Cast(Total_amt as Numeric)) [Average Revenue] , SUM(Cast(Total_amt as Numeric)) [Total Revenue]
    From Transactions
    Left Join prod_cat_info
    on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
                                 And
       Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
    Group by prod_cat, prod_subcat
    ) As Y
on X.prod_cat = y.prod_cat
