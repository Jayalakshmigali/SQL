CREATE TABLE CUST (
    CNUM INT PRIMARY KEY,
    CNAME VARCHAR(50),
    CITY VARCHAR(50),
    RATING INT,
    SNUM INT,
    FOREIGN KEY (SNUM) REFERENCES SALESPEOPLE(SNUM)
);
INSERT INTO CUST (CNUM, CNAME, CITY, RATING, SNUM) VALUES
(2001, 'Hoffman', 'London', 100, 1001),
(2002, 'Giovanne', 'Rome', 200, 1003),
(2003, 'Liu', 'San Jose', 300, 1002),
(2004, 'Grass', 'Brelin', 100, 1002),
(2006, 'Clemens', 'London', 300, 1007),
(2007, 'Pereira', 'Rome', 100, 1004);



-- 1.All customers with rating of 100.
SELECT * FROM CUST WHERE RATING = 100;

--2.All customers in San Jose, who have rating more than 200.
SELECT * FROM CUST WHERE CITY = 'San Jose' AND RATING > 200;

--3.All customers who were either located in San Jose or had a rating above 200.
SELECT * FROM CUST 
WHERE CITY = 'San Jose' 
OR RATING > 200;

--4.All customers excluding those with rating <= 100 unless they are located in Rome.
SELECT * FROM CUST 
WHERE RATING > 100 
   OR CITY = 'Rome';

--5.All customers with NULL values in city column.
SELECT * FROM CUST WHERE CITY IS NULL;

--6.All customers serviced by peel or Motika.
SELECT * FROM CUST 
WHERE SNUM IN (SELECT SNUM FROM SALESPEOPLE WHERE SNAME IN ('Peel', 'Motika'));

--7.All customers whose names begin with a letter from A to B.
SELECT * FROM CUST 
WHERE CNAME LIKE 'A%' OR CNAME LIKE 'B%';
--8.Count the number of different non NULL city values in customers table.
SELECT COUNT(DISTINCT CITY) AS Unique_City_Count
FROM CUST
WHERE CITY IS NOT NULL;

--9. First customer in alphabetical order whose name begins with G.
SELECT MIN(CNAME) FROM CUST
WHERE CNAME LIKE 'G%';

--10.Find highest rating in each city. Put the output in this form. For the city (city), the highest rating is : (rating).
SELECT 'For the city ' || CITY || ', the highest rating is : ' || MAX(RATING) AS OUTPUT  
FROM CUST  
GROUP BY CITY;

--11.Name of all customers matched with the salespeople serving them.
SELECT C.CNAME AS Customer_Name, S.SNAME AS Salesperson_Name  
FROM CUST C  
JOIN SALESPEOPLE S ON C.SNUM = S.SNUM;
--12.Produce all customer serviced by salespeople with a commission above 12%.
SELECT C.*
FROM CUST C, SALESPEOPLE S
WHERE C.SNUM = S.SNUM
AND S.COMM > 0.12;
--13.Find all pairs of customers having the same rating.
SELECT C1.CNUM AS CUSTOMER1, C1.CNAME AS CUSTOMER1_NAME, 
       C2.CNUM AS CUSTOMER2, C2.CNAME AS CUSTOMER2_NAME, 
       C1.RATING
FROM CUST C1, CUST C2
WHERE C1.RATING = C2.RATING 
AND C1.CNUM < C2.CNUM;
--14. Find all pairs of customers having the same rating, each pair coming once only.

SELECT C1.CNUM AS CUSTOMER1_ID, C1.CNAME AS CUSTOMER1_NAME, 
       C2.CNUM AS CUSTOMER2_ID, C2.CNAME AS CUSTOMER2_NAME, 
       C1.RATING
FROM CUST C1
JOIN CUST C2 ON C1.RATING = C2.RATING 
AND C1.CNUM < C2.CNUM;
--15.Policy is to assign three salesperson to each customers. Display all such combinations.
SELECT C.CNUM, C.CNAME, S.SNUM, S.SNAME 
FROM CUST C
CROSS JOIN (SELECT SNUM, SNAME FROM SALESPEOPLE ORDER BY SNUM FETCH FIRST 3 ROWS ONLY) S
ORDER BY C.CNUM, S.SNUM;

--16.Display all customers located in cities where salesman serres has customer.
SELECT DISTINCT C.*
FROM CUST C
WHERE C.CITY IN (
    SELECT DISTINCT C2.CITY
    FROM CUST C2
    JOIN SALESPEOPLE S ON C2.SNUM = S.SNUM
    WHERE S.SNAME = 'Serres'
);
--17.Find all pairs of customers served by single salesperson.
SELECT C1.CNUM AS Customer1, C1.CNAME AS Customer1_Name, 
       C2.CNUM AS Customer2, C2.CNAME AS Customer2_Name, 
       C1.SNUM AS Salesperson
FROM CUST C1
JOIN CUST C2 ON C1.SNUM = C2.SNUM AND C1.CNUM < C2.CNUM;

--18. Produce names and cities of all customers with the same rating as Hoffman.
SELECT CNAME, CITY 
FROM CUST 
WHERE RATING = (SELECT RATING FROM CUST WHERE CNAME = 'Hoffman');
--19.Find all customers whose cnum is 1000 above the snum of serres.
SELECT C.CNUM, C.CNAME, C.CITY, C.RATING, C.SNUM
FROM CUST C
JOIN SALESPEOPLE S ON C.CNUM = S.SNUM + 1000
WHERE S.SNAME = 'Serres';
--20.Count the customers with rating above San Jose’s average.
SELECT COUNT(*) AS Customer_Count
FROM CUST
WHERE RATING > (
    SELECT AVG(RATING)
    FROM CUST
    WHERE CITY = 'San Jose'
);
--21.Produce the names and rating of all customers who have above average orders.
SELECT C.CNAME, C.RATING
FROM CUST C
JOIN ORDERS O ON C.CNUM = O.CNUM
WHERE O.AMT > (SELECT AVG(AMT) FROM ORDERS);
--22. Find names and numbers of all customers with ratings equal to the maximum for their city.
SELECT CNUM, CNAME, CITY, RATING
FROM CUST C
WHERE RATING = (
    SELECT MAX(RATING)
    FROM CUST
    WHERE CITY = C.CITY
);
--23. Extract cnum,cname and city from customer table if and only if one or more of the customers in the table are located in San Jose.
SELECT CNUM, CNAME, CITY 
FROM CUST 
WHERE EXISTS (SELECT 1 FROM CUST WHERE CITY = 'San Jose');
--24. Find salespeople no. who have multiple customers
SELECT SNUM 
FROM CUST
GROUP BY SNUM
HAVING COUNT(CNUM) > 1;
--25.Extract from customers table every customer assigned the a salesperson who currently has at least one other customer ( besides the customer being selected) with orders in order table.
SELECT C.CNUM, C.CNAME, C.CITY, C.RATING, C.SNUM
FROM CUST C
WHERE EXISTS (
    SELECT 1 
    FROM CUST C2
    JOIN ORDERS O ON C2.CNUM = O.CNUM
    WHERE C2.SNUM = C.SNUM  
    AND C2.CNUM <> C.CNUM   
);
--26.Select customers who have a greater rating than any customer in rome.
SELECT CNUM, CNAME, CITY, RATING
FROM CUST
WHERE RATING > ANY (
    SELECT RATING 
    FROM CUST 
    WHERE CITY = 'Rome'
);
--27.Select those customers whose ratings are higher than every customer in Paris. ( Using both ALL and NOT EXISTS).
-- using ALL
SELECT CNUM, CNAME, CITY, RATING, SNUM
FROM CUST
WHERE RATING > ALL (
    SELECT RATING 
    FROM CUST 
    WHERE CITY = 'Paris'
);
-- Using NOT EXISTS
SELECT C1.CNUM, C1.CNAME, C1.CITY, C1.RATING, C1.SNUM
FROM CUST C1
WHERE NOT EXISTS (
    SELECT 1 
    FROM CUST C2 
    WHERE C2.CITY = 'Paris' 
    AND C1.RATING <= C2.RATING
);
--28. Select all customers whose ratings are equal to or greater than ANY of the Seeres
SELECT CNUM, CNAME, CITY, RATING, SNUM
FROM CUST
WHERE RATING >= ANY (
    SELECT RATING 
    FROM CUST 
    WHERE CNAME = 'Seeres'
);

--29.Create a union of two queries that shows the names, cities and ratings of all customers. Those with a rating of 200 or greater will also have the words ‘High Rating’, while the others will have the words ‘Low Rating’.
SELECT CNAME, CITY, RATING, 'High Rating' AS RATING_STATUS
FROM CUST
WHERE RATING >= 200
UNION
SELECT CNAME, CITY, RATING, 'Low Rating' AS RATING_STATUS
FROM CUST
WHERE RATING < 200;