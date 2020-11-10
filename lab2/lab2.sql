/*
Lab 2 report Rasmus Karlbäck (raska260) and Anton Orö (antor907)
*/

/* All non code should be within SQL-comments like this */ 


/*
Drop all user created tables that have been created when solving the lab
*/

SET FOREIGN_KEY_CHECKS=0;
SELECT 'Dropping our tables' AS 'Message';

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
SELECT 'Tables dropped' AS 'Message';

/* Have the source scripts in the file so it is easy to recreate!*/

SOURCE company_schema.sql;
SOURCE company_data.sql;


SELECT 'Beginning lab 2' AS 'Message';
/*
Task 3
*/

create table jbmanager(id integer primary key, bonus integer not null default 0, constraint fk_man_emp foreign key (id) references jbemployee(id));
/*
Query OK, 0 rows affected (0.05 sec)

*/
insert into jbmanager(id) select id from jbemployee where id in (select distinct manager from jbemployee union select distinct manager from jbdept);
/*
Query OK, 12 rows affected (0.00 sec)
Records: 12  Duplicates: 0  Warnings: 0

*/
alter table jbemployee drop foreign key fk_emp_mgr;
/*
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

*/
alter table jbemployee add constraint fk_emp_mgr foreign key (manager) references jbmanager(id);
/*
Query OK, 25 rows affected (0.11 sec)
Records: 25  Duplicates: 0  Warnings: 0

*/
alter table jbdept drop foreign key fk_dept_mgr;
/*
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

*/
alter table jbdept add constraint fk_dept_mgr foreign key (manager) references jbmanager(id);
/*
Query OK, 19 rows affected (0.11 sec)
Records: 19  Duplicates: 0  Warnings: 0

*/
/*
You have to initialize the bonus to 0, otherwise you can’t do bonus + 10000 since this returns a null value.
*/

/*
Task 4
*/
update jbmanager set bonus = bonus + 10000 where jbmanager.id in (select manager from jbdept);
/*
Query OK, 11 rows affected (0.00 sec)
Rows matched: 11  Changed: 11  Warnings: 0

*/
/*
Task 5
*/

create table jbcustomer(id integer primary key, name varchar(50) not null, streetaddress varchar(50) not null, city integer not null, constraint fk_city foreign key (city) references jbcity(id));
/*
Query OK, 0 rows affected (0.04 sec)

*/
create table jbaccount(accountnumber integer primary key, balance float not null default 0, customer integer not null, constraint fk_customer foreign key (customer) references jbcustomer(id));
/*
Query OK, 0 rows affected (0.05 sec)

*/
create table jbtransaction(transactionnumber integer primary key, sdate timestamp not null default current_timestamp(), employee int not null, account int not null, constraint fk_employee foreign key (employee) references jbemployee(id), constraint fk_account foreign key (account) references jbaccount(accountnumber));
/*
Query OK, 0 rows affected (0.07 sec)

*/
create table jbwithdraw(id integer primary key, amount integer not null default 0, constraint fk_with_trans foreign key (id) references jbtransaction(transactionnumber));
/*
Query OK, 0 rows affected (0.08 sec)

*/
create table jbdeposit(id integer primary key, amount integer not null default 0, constraint fk_dep_trans foreign key (id) references jbtransaction(transactionnumber));
/*
Query OK, 0 rows affected (0.07 sec)

*/
alter table jbdebit drop foreign key fk_debit_employee;
/*
Query OK, 0 rows affected (0.05 sec)
Records: 0  Duplicates: 0  Warnings: 0
*/

/*
Create a customer to own all the accounts.
*/
insert into jbcustomer(id,name,streetaddress,city) values(1,'Klas Göran','Flensburgsgatan 1',118);
/*
Query OK, 1 row affected (0.01 sec)

*/
/*
Move the content of jbdebit into jbtransaction, this is where it belongs now.
*/

insert into jbaccount(accountnumber, customer) (select distinct account,1 from jbdebit);
/*
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0

*/
insert into jbtransaction(transactionnumber,sdate,employee,account) select * from jbdebit;
/*
Query OK, 6 rows affected (0.03 sec)
Records: 6  Duplicates: 0  Warnings: 0

*/

alter table jbdebit add constraint fk_debit_transaction foreign key (id) references jbtransaction(transactionnumber);
/*
Query OK, 6 rows affected (0.10 sec)
Records: 6  Duplicates: 0  Warnings: 0

*/

alter table jbdebit drop sdate,drop employee,drop account;
/*
Query OK, 0 rows affected (0.10 sec)
Records: 0  Duplicates: 0  Warnings: 0

*/














