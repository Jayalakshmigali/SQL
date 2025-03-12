CREATE TABLE SALESPEOPLE (
    SNUM INT PRIMARY KEY,
    SNAME VARCHAR(50),
    CITY VARCHAR(50),
    COMM DECIMAL(4,2)
);

INSERT INTO SALESPEOPLE VALUES
(1001, 'Peel', 'London', 0.12),
(1002, 'Serres', 'San Jose', 0.13),
(1004, 'Motika', 'London', 0.11),
(1007, 'Rafkin', 'Barcelona', 0.15),
(1003, 'Axelrod', 'New York', 0.10);

-- 1.Display snum,sname,city and comm of all salespeople.
SELECT SNUM, SNAME, CITY, COMM FROM SALESPEOPLE;

--2.Display names and commissions of all salespeople in London.
SELECT SNAME, COMM FROM SALESPEOPLE WHERE CITY = 'London';

--3. Names and cities of all salespeople in London with commission above 0.10.
SELECT SNAME, CITY FROM SALESPEOPLE WHERE CITY = 'London' AND COMM > 0.10;

-- 4. All salespeople either in Barcelona or in London.
SELECT * FROM SALESPEOPLE WHERE CITY IN ('Barcelona', 'London');

-- 5. All salespeople with commission between 0.10 and 0.12 (excluding boundaries).
SELECT * FROM SALESPEOPLE WHERE COMM > 0.10 AND COMM < 0.12;

 --6.All customers serviced by peel or Motika.
SELECT * FROM CUST WHERE SNUM IN (SELECT SNUM FROM SALESPEOPLE WHERE SNAME IN ('Peel', 'Motika'));

--7.All combinations of salespeople and customers who shared a city. (ie same city).
SELECT S.SNUM, S.SNAME, S.CITY, C.CNUM, C.CNAME  
FROM SALESPEOPLE S  
JOIN CUST C ON S.CITY = C.CITY;

--8.Produce all pairs of salespeople which are living in the same city. Exclude combinations of
--salespeople with themselves as well as duplicates with the order reversed.
SELECT S1.SNUM AS Salesperson1, S1.SNAME AS Salesperson1_Name, 
       S2.SNUM AS Salesperson2, S2.SNAME AS Salesperson2_Name, 
       S1.CITY AS City
FROM SALESPEOPLE S1
JOIN SALESPEOPLE S2 ON S1.CITY = S2.CITY AND S1.SNUM < S2.SNUM;

--9. Find average commission of salespeople in london.
SELECT AVG(COMM) AS AVERAGE_COMMISSION
FROM SALESPEOPLE
WHERE CITY = 'London';

--10.Extract commissions of all salespeople servicing customers in London.
SELECT DISTINCT S.SNUM, S.SNAME, S.COMM
FROM SALESPEOPLE S
JOIN CUST C ON S.SNUM = C.SNUM
WHERE C.CITY = 'London';

--11.Find names and numbers of all salesperson who have more than one customer.
SELECT S.SNUM, S.SNAME
FROM SALESPEOPLE S
JOIN CUST C ON S.SNUM = C.SNUM
GROUP BY S.SNUM, S.SNAME
HAVING COUNT(C.CNUM) > 1;
--12.Find all salespeople who have customers in their cities who they don’t service. ( Both way using Join and Correlated subquery.)
SELECT DISTINCT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
JOIN CUST C ON S.CITY = C.CITY
LEFT JOIN CUST C2 ON S.SNUM = C2.SNUM
WHERE C2.CNUM IS NULL;
--13.Find salespeople number, name and city who have multiple customers.
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
JOIN CUST C ON S.SNUM = C.SNUM
GROUP BY S.SNUM, S.SNAME, S.CITY
HAVING COUNT(C.CNUM) > 1;
--14.Find salespeople who serve only one customer.
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
JOIN CUST C ON S.SNUM = C.SNUM
GROUP BY S.SNUM, S.SNAME, S.CITY
HAVING COUNT(C.CNUM) = 1;
--15.Extract rows of all salespeople with more than one current order.
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
JOIN ORDERS O ON S.SNUM = O.SNUM
GROUP BY S.SNUM, S.SNAME, S.CITY
HAVING COUNT(O.ONUM) > 1;
--16.Find all salespeople who have customers with a rating of 300. (use EXISTS)
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
WHERE EXISTS (
    SELECT 1 
    FROM CUST C 
    WHERE C.SNUM = S.SNUM 
    AND C.RATING = 300
);
--17.Find all salespeople who have customers with a rating of 300. (use Join).
SELECT DISTINCT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
JOIN CUST C ON S.SNUM = C.SNUM
WHERE C.RATING = 300;
--18.Select all salespeople with customers located in their cities who are not assigned to them. (use EXISTS).
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
WHERE EXISTS (
    SELECT 1 
    FROM CUST C
    WHERE C.CITY = S.CITY  
    AND C.SNUM <> S.SNUM   
);
--19.Find salespeople with customers located in their cities ( using both ANY and IN).
--ANY
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
WHERE S.CITY = ANY (
    SELECT C.CITY FROM CUST C WHERE C.SNUM = S.SNUM
);
--IN
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
WHERE S.CITY IN (
    SELECT C.CITY FROM CUST C WHERE C.SNUM = S.SNUM
);
--20.Find all salespeople for whom there are customers that follow them in alphabetical order. (Using ANY and EXISTS)
SELECT S.SNUM, S.SNAME, S.CITY
FROM SALESPEOPLE S
WHERE S.SNAME < ANY (
    SELECT C.CNAME FROM CUST C WHERE C.SNUM = S.SNUM
);
--21.Find all salespeople who have no customers located in their city. ( Both using ANY and ALL)
-- Using ANY
SELECT SNUM, SNAME, CITY
FROM SALESPEOPLE
WHERE CITY <> ANY (
    SELECT CITY 
    FROM CUST 
    WHERE CUST.SNUM = SALESPEOPLE.SNUM
);
-- Using ALl
SELECT SNUM, SNAME, CITY
FROM SALESPEOPLE
WHERE CITY <> ALL (
    SELECT CITY 
    FROM CUST 
    WHERE CUST.SNUM = SALESPEOPLE.SNUM
);
--22.Find all salespeople and customers located in london.
SELECT S.SNUM, S.SNAME, C.CNUM, C.CNAME, C.CITY
FROM SALESPEOPLE S
JOIN CUST C ON S.SNUM = C.SNUM
WHERE C.CITY = 'London';

--23. List all of the salespeople and indicate those who don’t have customers in their cities as well as those who do have.
SELECT S.SNUM, S.SNAME, S.CITY, 
       CASE 
           WHEN EXISTS (
               SELECT 1 
               FROM CUST C 
               WHERE C.CITY = S.CITY AND C.SNUM = S.SNUM
           ) 
           THEN 'Has Customers in City' 
           ELSE 'No Customers in City' 
       END AS STATUS
FROM SALESPEOPLE S;

--24.Append strings to the selected fields, indicating weather or not a given salesperson was matched to a customer in his city.
SELECT S.SNUM, 
       S.SNAME || ' (' || S.CITY || ')' AS SALESPERSON_INFO, 
       CASE 
           WHEN EXISTS (
               SELECT 1 
               FROM CUST C 
               WHERE C.CITY = S.CITY AND C.SNUM = S.SNUM
           ) 
           THEN 'Matched to Customer in City' 
           ELSE 'Not Matched to Customer in City' 
       END AS STATUS
FROM SALESPEOPLE S;
--25.Write command that produces the name and number of each salesperson and each customer with more than one current order. Put the result in alphabetical order.
SELECT S.SNUM AS Number, S.SNAME AS Name, 'Salesperson' AS Type
FROM SALESPEOPLE S
JOIN ORDERS O ON S.SNUM = O.SNUM
GROUP BY S.SNUM, S.SNAME
HAVING COUNT(O.ONUM) > 1

UNION

SELECT C.CNUM AS Number, C.CNAME AS Name, 'Customer' AS Type
FROM CUST C
JOIN ORDERS O ON C.CNUM = O.CNUM
GROUP BY C.CNUM, C.CNAME
HAVING COUNT(O.ONUM) > 1

ORDER BY Name;