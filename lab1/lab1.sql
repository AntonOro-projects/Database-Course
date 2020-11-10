/*
Lab 1 report Rasmus Karlbäck (raska260) and Anton Orö (antor907)
*/

/* All non code should be within SQL-comments like this */ 


/*
Drop all user created tables that have been created when solving the lab
*/

SELECT 'Dropping tables and views' as 'Message';

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS jbsale CASCADE;
DROP TABLE IF EXISTS jbsupply CASCADE;
DROP TABLE IF EXISTS jbdebit CASCADE;
DROP TABLE IF EXISTS jbparts CASCADE;
DROP TABLE IF EXISTS jbitem CASCADE;
DROP TABLE IF EXISTS jbsupplier CASCADE;
DROP TABLE IF EXISTS jbdept CASCADE;
DROP TABLE IF EXISTS jbstore CASCADE;
DROP TABLE IF EXISTS jbcity CASCADE;
DROP TABLE IF EXISTS jbemployee CASCADE;
DROP TABLE IF EXISTS cheapitems CASCADE;
DROP TABLE IF EXISTS jbaccount CASCADE;
DROP TABLE IF EXISTS jbcustomer CASCADE;
DROP TABLE IF EXISTS jbdeposit CASCADE;
DROP TABLE IF EXISTS jbmanager CASCADE;
DROP TABLE IF EXISTS jbtransaction CASCADE;
DROP TABLE IF EXISTS jbwithdraw CASCADE;


DROP VIEW IF EXISTS v CASCADE;
DROP VIEW IF EXISTS costview CASCADE;
DROP VIEW IF EXISTS joinview CASCADE;
DROP VIEW IF EXISTS jbsale_supply CASCADE;
SET FOREIGN_KEY_CHECKS=1;

SELECT 'Tables and views dropped' as 'Message';


/* Have the source scripts in the file so it is easy to recreate!*/

SOURCE company_schema.sql;
SOURCE company_data.sql;


/*
1) List all employees, i.e. all tuples in the jbemployee relation.
*/


select * from jbemployee;

/*
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0.00 sec)

*/


/*
2) List the name of all departments in alphabetical order. Note: by “name” we mean
the name attribute for all tuples in the jbdept relation.
*/

select name from jbdept order by name asc;

/*
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
19 rows in set (0.00 sec)

*/

/*
3) What parts are not in store, i.e. qoh = 0? (qoh = Quantity On Hand)
*/
select name from jbparts where qoh = 0;

/*
+-------------------+
| name              |
+-------------------+
| card reader       |
| card punch        |
| paper tape reader |
| paper tape punch  |
+-------------------+
4 rows in set (0.00 sec)

*/

/*
4) Which employees have a salary between 9000 (included) and 10000 (included)?
*/
select name from jbemployee where salary between 9000 and 10000;

/*
+----------------+
| name           |
+----------------+
| Edwards, Peter |
| Smythe, Carol  |
| Williams, Judy |
| Thomas, Tom    |
+----------------+
4 rows in set (0.00 sec)

*/

/*
5) What was the age of each employee when they started working (startyear)?
*/
select name, startyear - birthyear as age from jbemployee;

/*
+--------------------+------+
| name               | age  |
+--------------------+------+
| Ross, Stanley      |   18 |
| Ross, Stuart       |    1 |
| Edwards, Peter     |   30 |
| Thompson, Bob      |   40 |
| Smythe, Carol      |   38 |
| Hayes, Evelyn      |   32 |
| Evans, Michael     |   22 |
| Raveen, Lemont     |   24 |
| James, Mary        |   49 |
| Williams, Judy     |   34 |
| Thomas, Tom        |   21 |
| Jones, Tim         |   20 |
| Bullock, J.D.      |    0 |
| Collins, Joanne    |   21 |
| Brunet, Paul C.    |   21 |
| Schmidt, Herman    |   20 |
| Iwano, Masahiro    |   26 |
| Smith, Paul        |   21 |
| Onstad, Richard    |   19 |
| Zugnoni, Arthur A. |   21 |
| Choy, Wanda        |   23 |
| Wallace, Maggie J. |   19 |
| Bailey, Chas M.    |   19 |
| Bono, Sonny        |   24 |
| Schwarz, Jason B.  |   15 |
+--------------------+------+
25 rows in set (0.00 sec)

*/

/*
6) Which employees have a last name ending with “son”?
*/

select name from jbemployee where name like '%son, %';

/*
+---------------+
| name          |
+---------------+
| Thompson, Bob |
+---------------+
1 row in set (0.00 sec)

*/

/*
7) Which items (note items, not parts) have been delivered by a supplier called
Fisher-Price? Formulate this query using a subquery in the where-clause.
*/

select name from jbitem where supplier = (select id from jbsupplier where name = "Fisher-Price");

/*
+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0.00 sec)

*/

/*
8) Formulate the same query as above, but without a subquery.
*/

select jbitem.name from jbitem,jbsupplier where jbsupplier.name = "Fisher-Price" and jbitem.supplier = jbsupplier.id;

/*
+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0.00 sec)

*/

/*
9) Show all cities that have suppliers located in them. Formulate this query using a
subquery in the where-clause.
*/

select name from jbcity where id in (select city from jbsupplier);

/*
+----------------+
| name           |
+----------------+
| Amherst        |
| Boston         |
| New York       |
| White Plains   |
| Hickville      |
| Atlanta        |
| Madison        |
| Paxton         |
| Dallas         |
| Denver         |
| Salt Lake City |
| Los Angeles    |
| San Diego      |
| San Francisco  |
| Seattle        |
+----------------+
15 rows in set (0.00 sec)

*/

/*
10) What is the name and color of the parts that are heavier than a card reader?
Formulate this query using a subquery in the where-clause. (The SQL query must
not contain the weight as a constant.)
*/

select name,color from jbparts where weight > (select weight from jbparts where name = "card reader");

/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)

*/

/*
11) Formulate the same query as above, but without a subquery. (The query must not
contain the weight as a constant.)
*/

select jb1.name,jb1.color from jbparts as jb1,jbparts as jb2 where jb1.weight > jb2.weight and jb2.name = "card reader";

/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)

*/

/*
12) What is the average weight of black parts?
*/

select avg(weight) from jbparts where color = "black";

/*
+-------------+
| avg(weight) |
+-------------+
|    347.2500 |
+-------------+
1 row in set (0.00 sec)

*/

/*
13) What is the total weight of all parts that each supplier in Massachusetts (“Mass”)
has delivered? Retrieve the name and the total weight for each of these suppliers.
Do not forget to take the quantity of delivered parts into account. Note that one
row should be returned for each supplier.
*/

select jbsupplier.name, sum(jbsupply.quan*jbparts.weight) as w from jbparts, jbcity, jbsupply, jbsupplier where jbparts.id = jbsupply.part and jbsupply.supplier=jbsupplier.id and jbsupplier.city = jbcity.id and jbcity.state = "Mass" group by jbsupplier.name;

/*
+--------------+---------+
| name         | w       |
+--------------+---------+
| DEC          |    3120 |
| Fisher-Price | 1135000 |
+--------------+---------+
2 rows in set (0.00 sec)

*/

/*
14) Create a new relation (a table), with the same attributes as the table items using
the CREATE TABLE syntax where you define every attribute explicitly (i.e. not 
10
as a copy of another table). Then fill the table with all items that cost less than the
average price for items. Remember to define primary and foreign keys in your
table!
*/
create table cheapitems (id INT(3) PRIMARY KEY, name VARCHAR(50), dept INT(2), price INT(4), qoh INT(4), supplier INT(3), CONSTRAINT fk_supplier FOREIGN KEY (supplier) REFERENCES jbsupplier (id), CONSTRAINT fk_dept FOREIGN KEY (dept) REFERENCES jbdept(id));

/*
Query OK, 0 rows affected (0.05 sec)

*/

insert into cheapitems (id,name,dept,price,qoh,supplier) select id,name,dept,price,qoh,supplier from jbitem where price < (select avg(price) from jbitem);

/*
Query OK, 14 rows affected (0.00 sec)
Records: 14  Duplicates: 0  Warnings: 0

*/

/*
15) Create a view that contains the items that cost less than the average price for
items.
*/
create view v as select * from jbitem where price < (select avg(price) from jbitem);

/*
Query OK, 0 rows affected (0.03 sec)

*/

/*
16) What is the difference between a table and a view? One is static and the other is
dynamic. Which is which and what do we mean by static respectively dynamic?

View is dynamic, while a table is static. Because when you create a view you use a select statement, which means that it executes a query which is dynamic. A view does not hold data in itself, so if the data in the referenced table changes, then the view fields will also change. A table is static since it doesn’t change when another is updated, an update must happen on that table directly. A dynamic table (view) can react to a change in another table.
*/
/*
17) Create a view, using only the implicit join notation, i.e. only use where statements
but no inner join, right join or left join statements, that calculates the total cost of
each debit, by considering price and quantity of each bought item. (To be used for
charging customer accounts). The view should contain the sale identifier (debit)
and total cost.
*/

create view costview as select jbdebit.id, sum(jbitem.price*jbsale.quantity) as cost from jbdebit,jbsale,jbitem where jbdebit.id = jbsale.debit and jbsale.item = jbitem.id group by jbdebit.id;

/*
Query OK, 0 rows affected (0.03 sec)

*/

/*
18) Do the same as in (17), using only the explicit join notation, i.e. using only left,
right or inner joins but no where statement. Motivate why you use the join you do
(left, right or inner), and why this is the correct one (unlike the others).

The most logical choice is inner joins, since this will guarantee that we get only valid data in the resulting table. If for example we would use left joins we could instead see if there was a receipt for something that there was not a sale for, or a sale for an item that does not exist. So it really depends on the purpose of the query. 
*/

create view joinview as select jbdebit.id, sum(quantity*price) as cost from jbdebit inner join jbsale on jbsale.debit = jbdebit.id inner join jbitem on jbsale.item=jbitem.id group by jbdebit.id;

/*
Query OK, 0 rows affected (0.03 sec)

*/

/*
19) Oh no! An earthquake!
*/

/*
a) Remove all suppliers in Los Angeles from the table jbsupplier. This will not
work right away (you will receive error code 23000) which you will have to
solve by deleting some other related tuples. However, do not delete more
tuples from other tables than necessary and do not change the structure of the
tables, i.e. do not remove foreign keys. Also, remember that you are only
allowed to use “Los Angeles” as a constant in your queries, not “199” or
“900”.
*/

delete from jbsale where item in (select id from jbitem where supplier in (select id from jbsupplier where city in (select id from jbcity where name = "Los Angeles")));
/*
Query OK, 1 row affected (0.00 sec)

*/
delete from jbitem where supplier in (select id from jbsupplier where city in (select id from jbcity where name = "Los Angeles"));
/*
Query OK, 2 rows affected (0.00 sec)

*/
delete from cheapitems where supplier in (select id from jbsupplier where city in (select id from jbcity where name = "Los Angeles"));
/*
Query OK, 1 row affected (0.01 sec)

*/
delete from jbsupplier where city in (select id from jbcity where name = "Los Angeles");
/*
Query OK, 1 row affected (0.00 sec)

*/




/*
b) Explain what you did and why.

Because if we remove a supplier, then we can no longer get that item which means that we can no longer have sales registered for this item. So we need to start removing from the “bottom”. This means that we first remove from jbsale, then jbitem, then we can finally remove from jbsupplier.
*/

/*
20) An employee has tried to find out which suppliers that have delivered items that
have been sold. He has created a view and a query that shows the number of items
sold from a supplier.
*/

create view jbsale_supply(supplier, item, quantity) as select jbsupplier.name, jbitem.name, jbsale.quantity from jbsupplier inner join jbitem on jbsupplier.id = jbitem.supplier left join jbsale on jbsale.item=jbitem.id;
/*
Query OK, 0 rows affected (0.03 sec)

*/
select supplier,sum(quantity) from jbsale_supply group by supplier; 

/*
+--------------+---------------+
| supplier     | sum(quantity) |
+--------------+---------------+
| Cannon       |             6 |
| Fisher-Price |          NULL |
| Levi-Strauss |             1 |
| Playskool    |             2 |
| White Stag   |             4 |
| Whitman's    |             2 |
+--------------+---------------+
6 rows in set (0.00 sec)

*/                                                                                                         	




