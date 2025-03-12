CREATE TABLE ORDERS (
    ONUM INT,
    AMT DECIMAL(10,2),
    ODATE DATE,
    CNUM INT,
    SNUM INT
);

INSERT INTO ORDERS (ONUM, AMT, ODATE, CNUM, SNUM) VALUES
(3001, 18.69, TO_DATE('1994-10-03', 'YYYY-MM-DD'), 2008, 1007),
(3003, 767.19, TO_DATE('1994-10-03', 'YYYY-MM-DD'), 2001, 1001),
(3002, 1900.10, TO_DATE('1994-10-03', 'YYYY-MM-DD'), 2007, 1004),
(3005, 5160.45, TO_DATE('1994-10-03', 'YYYY-MM-DD'), 2003, 1002),
(3006, 1098.16, TO_DATE('1994-10-04', 'YYYY-MM-DD'), 2008, 1007),
(3009, 1713.23, TO_DATE('1994-10-04', 'YYYY-MM-DD'), 2002, 1003),
(3007, 75.75, TO_DATE('1994-10-05', 'YYYY-MM-DD'), 2004, 1002),
(3008, 4723.00, TO_DATE('1994-10-05', 'YYYY-MM-DD'), 2006, 1001),
(3010, 1309.95, TO_DATE('1994-10-06', 'YYYY-MM-DD'), 2004, 1002),
(3011, 9891.88, TO_DATE('1994-10-06', 'YYYY-MM-DD'), 2006, 1001);


--1.Display all snum without duplicates from all orders.
SELECT DISTINCT SNUM FROM ORDERS;

--2.Produce orderno, amount and date form all rows in the order table.
SELECT ONUM, AMT, ODATE FROM ORDERS;

--3.All orders for more than $1000.
SELECT * FROM ORDERS WHERE AMT > 1000;

--4.All orders taken on Oct 3Rd and Oct 4th 1994.
SELECT * FROM ORDERS 
WHERE ODATE IN (TO_DATE('1994-10-03', 'YYYY-MM-DD'), TO_DATE('1994-10-04', 'YYYY-MM-DD'));

--5. All orders except those with 0 or NULL value in amt field.
SELECT * FROM ORDERS 
WHERE AMT IS NOT NULL AND AMT <> 0;

--6.Count the number of salespeople currently listing orders in the order table.
SELECT COUNT(DISTINCT SNUM) AS Salespeople_Count FROM ORDERS;

--7. Largest order taken by each salesperson, datewise.
SELECT ODATE, SNUM, MAX(AMT) AS Largest_Order 
FROM ORDERS 
GROUP BY ODATE, SNUM 
ORDER BY ODATE, SNUM;

--8.Largest order taken by each salesperson with order value more than $3000
SELECT SNUM, MAX(AMT) AS Largest_Order
FROM ORDERS
WHERE AMT > 3000
GROUP BY SNUM
ORDER BY SNUM;

--9. Which day had the hightest total amount ordered.
SELECT ODATE, AMT, SNUM, CNUM
FROM ORDERS
WHERE AMT = (SELECT MAX(AMT) FROM ORDERS);
--10.Count all orders for Oct 3rd
SELECT COUNT(*) AS Order_Count
FROM ORDERS
WHERE ODATE = TO_DATE('1994-10-03', 'YYYY-MM-DD');

--11.Select each customer’s smallest order.
SELECT CNUM,MIN(AMT)
       FROM ORDERS 
       GROUP BY CNUM;
       
--12. Get the output like “ For dd/mm/yy there are ___ orders.
SELECT 'For ' || TO_CHAR(ODATE, 'DD/MM/YY') || ' there are ' || 
       COUNT(*) || ' Orders'
FROM ORDERS
GROUP BY ODATE;
--13.Assume that each salesperson has a 12% commission. Produce order no., salesperson no.,
--and amount of salesperson’s commission for that order.
SELECT ONUM, SNUM, AMT * 0.12 AS COMMISSION
FROM ORDERS;

--14. Display the totals of orders for each day and place the results in descending order.
SELECT ODATE, SUM(AMT) AS TOTAL_ORDERS  
FROM ORDERS  
GROUP BY ODATE  
ORDER BY TOTAL_ORDERS DESC;

--15. List each order number followed by the name of the customer who made the order.
SELECT O.ONUM AS Order_Number, C.CNAME AS Customer_Name  
FROM ORDERS O  
JOIN CUST C ON O.CNUM = C.CNUM;
--16. Names of salesperson and customer for each order after the order number.

SELECT O.ONUM, O.SNUM, O.CNUM
FROM ORDERS O, CUST C, SALESPEOPLE S
WHERE O.CNUM = C.CNUM  
AND O.SNUM = S.SNUM;

--17.Calculate the amount of the salesperson’s commission on each order with a rating above
--100.
SELECT O.ONUM, O.SNUM, O.AMT, (O.AMT * 0.12) AS COMMISSION
FROM ORDERS O, CUST C
WHERE O.CNUM = C.CNUM 
AND C.RATING > 100;
--18.Produce all pairs of orders by given customer, names that customers and eliminates
--duplicates.
SELECT O1.ONUM AS Order1, O2.ONUM AS Order2, C.CNAME AS Customer_Name
FROM ORDERS O1
JOIN ORDERS O2 ON O1.CNUM = O2.CNUM AND O1.ONUM < O2.ONUM
JOIN CUST C ON O1.CNUM = C.CNUM;
--19. Extract all the orders of Motika.
SELECT * 
FROM ORDERS 
WHERE SNUM = (SELECT SNUM FROM SALESPEOPLE WHERE SNAME = 'Motika');
--20.All orders credited to the same salesperson who services Hoffman.
SELECT * 
FROM ORDERS 
WHERE SNUM = (SELECT SNUM FROM CUST WHERE CNAME = 'Hoffman');
--21.All orders that are greater than the average for Oct 4.
SELECT * 
FROM ORDERS 
WHERE AMT > (SELECT AVG(AMT) FROM ORDERS WHERE ODATE = TO_DATE('1994-10-04', 'YYYY-MM-DD'));

--22.Find all orders attributed to salespeople servicing customers in london.
SELECT O.ONUM, O.AMT, O.ODATE, O.CNUM, O.SNUM
FROM ORDERS O
JOIN CUST C ON O.CNUM = C.CNUM
WHERE C.CITY = 'London';

--23. Obtain all orders for the customer named Cisnerous. (Assume you don’t know his
--customer no. (cnum)).
SELECT O.*
FROM ORDERS O
JOIN CUST C ON O.CNUM = C.CNUM
WHERE C.CNAME = 'Cisnerous';

--24. Find total amount in orders for each salesperson for whom this total is greater than the
--amount of the largest order in the table.
SELECT O.SNUM, SUM(O.AMT) AS TOTAL_AMOUNT
FROM ORDERS O
GROUP BY O.SNUM
HAVING SUM(O.AMT) > (SELECT MAX(AMT) FROM ORDERS);
--25. Find all customers with order on 3rd Oct.
SELECT DISTINCT C.CNUM, C.CNAME
FROM CUST C
JOIN ORDERS O ON C.CNUM = O.CNUM
WHERE O.ODATE = TO_DATE('1994-10-03', 'YYYY-MM-DD');

--26.Check if the correct salesperson was credited with each sale.
SELECT O.ONUM, O.SNUM AS Credited_Salesperson, C.SNUM AS Actual_Salesperson, C.CNUM, C.CNAME
FROM ORDERS O
JOIN CUST C ON O.CNUM = C.CNUM
WHERE O.SNUM <> C.SNUM;
--27.Find all orders with above average amounts for their customers.
SELECT O.ONUM, O.AMT, O.CNUM, C.CNAME
FROM ORDERS O
JOIN CUST C ON O.CNUM = C.CNUM
WHERE O.AMT > (SELECT AVG(O2.AMT) FROM ORDERS O2 WHERE O2.CNUM = O.CNUM);
--28.Find the sums of the amounts from order table grouped by date, eliminating all those dates where the sum was not at least 2000 above the maximum amount.
SELECT ODATE, SUM(AMT) AS TOTAL_AMOUNT
FROM ORDERS
GROUP BY ODATE
HAVING SUM(AMT) >= (SELECT MAX(AMT) FROM ORDERS) + 2000;
--29.Select all orders that had amounts that were greater that atleast one of the orders from Oct 6th
SELECT ONUM, AMT, ODATE, CNUM, SNUM
FROM ORDERS
WHERE AMT > ANY (
    SELECT AMT 
    FROM ORDERS 
    WHERE ODATE = TO_DATE('1994-10-06', 'YYYY-MM-DD')
);
--30.Find all orders with amounts smaller than any amount for a customer in San Jose. (Both using ANY and without ANY)
-- using ANY
SELECT ONUM, AMT, ODATE, CNUM, SNUM
FROM ORDERS
WHERE AMT < ANY (
    SELECT AMT 
    FROM ORDERS 
    WHERE CNUM IN (
        SELECT CNUM 
        FROM CUST 
        WHERE CITY = 'San Jose'
    )
);
-- without using ANY
SELECT ONUM, AMT, ODATE, CNUM, SNUM
FROM ORDERS
WHERE AMT < (
    SELECT MIN(AMT) 
    FROM ORDERS 
    WHERE CNUM IN (
        SELECT CNUM 
        FROM CUST 
        WHERE CITY = 'San Jose'
    )
);

--31.Find all orders for amounts greater than any for the customers in London.
SELECT * 
FROM ORDERS
WHERE AMT > (
    SELECT MIN(AMT)
    FROM ORDERS
    WHERE CNUM IN (
        SELECT CNUM 
        FROM CUST 
        WHERE CITY = 'London'
    )
);
--32.For every salesperson, dates on which highest and lowest orders were brought.
SELECT SNUM, 
       MAX(ODATE) KEEP (DENSE_RANK FIRST ORDER BY AMT DESC) AS HIGHEST_ORDER_DATE, 
       MIN(ODATE) KEEP (DENSE_RANK FIRST ORDER BY AMT ASC) AS LOWEST_ORDER_DATE
FROM ORDERS
GROUP BY SNUM;