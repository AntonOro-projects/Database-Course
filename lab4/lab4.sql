SET FOREIGN_KEY_CHECKS=0;
SELECT 'Dropping our tables' AS 'Message';

DROP TABLE IF EXISTS YEAR;
DROP TABLE IF EXISTS WEEKDAY;
DROP TABLE IF EXISTS AIRPORT;
DROP TABLE IF EXISTS ROUTE;
DROP TABLE IF EXISTS WEEKLYSCHEDULE;
DROP TABLE IF EXISTS FLIGHT;
DROP TABLE IF EXISTS PASSENGER;
DROP TABLE IF EXISTS CONTACT;
DROP TABLE IF EXISTS RESERVATION;
DROP TABLE IF EXISTS CREDITCARD;
DROP TABLE IF EXISTS BOOKING;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS DEBUG;

DROP VIEW IF EXISTS allFlights;

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;

DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

SET FOREIGN_KEY_CHECKS=1;
SELECT 'Tables dropped' AS 'Message';

CREATE TABLE YEAR (YEAR INTEGER PRIMARY KEY, PROFITFACTOR DOUBLE NOT NULL);

CREATE TABLE WEEKDAY (DAY VARCHAR(10) PRIMARY KEY, WEEKDAYFACTOR DOUBLE NOT NULL, YEAR INTEGER NOT NULL, CONSTRAINT fk_weekday_year FOREIGN KEY (YEAR) REFERENCES YEAR(YEAR));

CREATE TABLE AIRPORT (AIRPORTCODE VARCHAR(3) PRIMARY KEY, AIRPORTNAME VARCHAR(30) NOT NULL, COUNTRY VARCHAR(30) NOT NULL);

CREATE TABLE ROUTE (ID INTEGER PRIMARY KEY AUTO_INCREMENT, ROUTEPRICE DOUBLE NOT NULL, ARRIVESTO VARCHAR(3) NOT NULL, DEPARTSFROM VARCHAR(3) NOT NULL, YEAR INTEGER NOT NULL, CONSTRAINT fk_arrives_airport FOREIGN KEY (ARRIVESTO) REFERENCES AIRPORT(AIRPORTCODE), CONSTRAINT fk_departs_airport FOREIGN KEY (DEPARTSFROM) REFERENCES AIRPORT(AIRPORTCODE), CONSTRAINT fk_route_year FOREIGN KEY (YEAR) REFERENCES YEAR(YEAR));

CREATE TABLE WEEKLYSCHEDULE (ID INTEGER PRIMARY KEY AUTO_INCREMENT, ROUTE INTEGER NOT NULL, DEPARTURETIME TIME NOT NULL, WEEKDAY VARCHAR(10), CONSTRAINT fk_weekly_route FOREIGN KEY (ROUTE) REFERENCES ROUTE(ID), CONSTRAINT fk_week_day FOREIGN KEY (WEEKDAY) REFERENCES WEEKDAY(DAY));

CREATE TABLE FLIGHT (FLIGHTNUMBER INTEGER PRIMARY KEY AUTO_INCREMENT, WEEK INTEGER NOT NULL, WEEKLYFLIGHT INTEGER NOT NULL, CONSTRAINT fk_flight_route FOREIGN KEY (WEEKLYFLIGHT) REFERENCES WEEKLYSCHEDULE(ID));

CREATE TABLE RESERVATION (RESERVATIONNUMBER INTEGER PRIMARY KEY NOT NULL, RESERVEDSEATS INTEGER NOT NULL, FLIGHTNUMBER INTEGER NOT NULL, CONSTRAINT fk_reserv_flight FOREIGN KEY (FLIGHTNUMBER) REFERENCES FLIGHT(FLIGHTNUMBER));

CREATE TABLE PASSENGER (PASSPORTNUMBER INTEGER, RESERVATIONNUMBER INTEGER, NAME VARCHAR(30) NOT NULL, PRIMARY KEY(PASSPORTNUMBER, RESERVATIONNUMBER), CONSTRAINT fk_pass_reserv FOREIGN KEY (RESERVATIONNUMBER) REFERENCES RESERVATION(RESERVATIONNUMBER));

CREATE TABLE CONTACT (PASSPORTNUMBER INTEGER, RESERVATIONNUMBER INTEGER, PHONENUMBER BIGINT NOT NULL, EMAIL VARCHAR(30), PRIMARY KEY (PASSPORTNUMBER, RESERVATIONNUMBER), CONSTRAINT fk_contact_passenger FOREIGN KEY (PASSPORTNUMBER, RESERVATIONNUMBER) REFERENCES PASSENGER(PASSPORTNUMBER, RESERVATIONNUMBER));

CREATE TABLE CREDITCARD (CARDNUMBER BIGINT PRIMARY KEY, CREDITCARDHOLDER VARCHAR(30) NOT NULL);

CREATE TABLE BOOKING (RESERVATIONNUMBER INTEGER PRIMARY KEY NOT NULL, PRICE INTEGER NOT NULL, CARDNUMBER BIGINT NOT NULL, CONTACT INTEGER NOT NULL, CONSTRAINT fk_booking_reserv FOREIGN KEY (RESERVATIONNUMBER) REFERENCES RESERVATION(RESERVATIONNUMBER), CONSTRAINT fk_booking_credit FOREIGN KEY (CARDNUMBER) REFERENCES CREDITCARD(CARDNUMBER), CONSTRAINT fk_booking_contact FOREIGN KEY (CONTACT) REFERENCES CONTACT(PASSPORTNUMBER));

CREATE TABLE TICKET(TICKETNUMBER INTEGER(200) PRIMARY KEY, RESERVATIONNUMBER INTEGER(200), PASSPORTNUMBER INTEGER(200), CONSTRAINT fk_ticket_booking FOREIGN KEY (RESERVATIONNUMBER) REFERENCES BOOKING(RESERVATIONNUMBER), CONSTRAINT fk_ticket_passenger FOREIGN KEY (PASSPORTNUMBER, RESERVATIONNUMBER) REFERENCES PASSENGER(PASSPORTNUMBER, RESERVATIONNUMBER));

DELIMITER //

CREATE PROCEDURE addYear(IN year INTEGER, IN factor DOUBLE)
BEGIN
	INSERT INTO YEAR(YEAR, PROFITFACTOR) VALUES (year, factor);
END //

CREATE PROCEDURE addDay(IN year INTEGER, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
	INSERT INTO WEEKDAY(DAY, WEEKDAYFACTOR, YEAR) VALUES (day, factor, year);
END //

CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
	INSERT INTO AIRPORT(AIRPORTCODE, AIRPORTNAME, COUNTRY) VALUES (airport_code, name, country);
END //

CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INTEGER, IN routeprice DOUBLE)
BEGIN
	INSERT INTO ROUTE(ROUTEPRICE, ARRIVESTO, DEPARTSFROM, YEAR) VALUES (routeprice, arrival_airport_code, departure_airport_code, year);
END //

CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year_in INTEGER, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
DECLARE routeid INTEGER;
DECLARE weeklyflight_temp INTEGER; 
DECLARE i INTEGER DEFAULT 1;

SELECT ID INTO routeid FROM ROUTE WHERE ARRIVESTO = arrival_airport_code AND DEPARTSFROM = departure_airport_code AND YEAR = year_in;
INSERT INTO WEEKLYSCHEDULE(ROUTE, DEPARTURETIME, WEEKDAY) VALUES (routeid, departure_time, day);
SET weeklyflight_temp = (SELECT ID FROM WEEKLYSCHEDULE ORDER BY ID DESC LIMIT 1);

WHILE (i <= 52) DO
	INSERT INTO FLIGHT(WEEK, WEEKLYFLIGHT) VALUES (i, weeklyflight_temp);
	SET i = i + 1;
END WHILE;
END //

CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year_in INTEGER, IN week_in INTEGER, IN day VARCHAR(10), IN time TIME, IN number_of_passengers INTEGER, OUT output_reservation_nr INTEGER)
BEGIN
	DECLARE route_id INTEGER;
	DECLARE schedule_id INTEGER;
	DECLARE flight_nr INTEGER;
	DECLARE reservation_nr INTEGER;
	DECLARE flag BINARY;
	
	SET route_id = (SELECT ID FROM ROUTE WHERE ARRIVESTO = arrival_airport_code AND DEPARTSFROM = departure_airport_code AND YEAR = year_in);
	SET schedule_id = (SELECT ID FROM WEEKLYSCHEDULE WHERE ROUTE=route_id AND DEPARTURETIME = time AND WEEKDAY = day);	
	SET flight_nr = (SELECT FLIGHTNUMBER FROM FLIGHT WHERE WEEKLYFLIGHT = schedule_id AND WEEK = week_in);
	SET reservation_nr = (SELECT FLOOR(1 + (RAND() * 21412345)));
	SET flag = 1;
	
	WHILE flag = 1 DO
		IF(reservation_nr IN (SELECT RESERVATIONNUMBER FROM RESERVATION)) THEN
			SET reservation_nr = (SELECT FLOOR(1 + (RAND() * 21412345)));
		ELSE
			SET flag = 0;
		END IF;
	END WHILE;	
	
	IF(schedule_id) THEN
		IF(calculateFreeSeats(flight_nr) >= number_of_passengers) THEN
			INSERT INTO RESERVATION(RESERVATIONNUMBER, RESERVEDSEATS, FLIGHTNUMBER) SELECT reservation_nr, number_of_passengers, FLIGHTNUMBER FROM FLIGHT WHERE WEEK = week_in AND WEEKLYFLIGHT = (schedule_id);
		ELSE
			SELECT "There are not enough seats available on the chosen flight" AS "Message";
		END IF;
	ELSE
		SELECT "There exist no flight for the given route, date and time" AS "Message";
	END IF;
	
	SET output_reservation_nr = reservation_nr;
END //

CREATE PROCEDURE addPassenger(IN reservation_nr INTEGER, IN passport_nr INTEGER, IN name_in VARCHAR(30))
BEGIN 	
	IF (reservation_nr IN (SELECT RESERVATIONNUMBER FROM BOOKING)) THEN
		SELECT "The booking has already been payed and no further passengers can be added" as "Message";
	ELSEIF (reservation_nr IN (SELECT RESERVATIONNUMBER FROM RESERVATION)) THEN
		INSERT INTO PASSENGER(PASSPORTNUMBER, RESERVATIONNUMBER, NAME) VALUES (passport_nr, reservation_nr, name_in);
	ELSE 
		SELECT "The given reservation number does not exist" as "Message";
	END IF;
END //

CREATE PROCEDURE addContact(IN reservation_nr INTEGER, IN passport_nr INTEGER, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
	IF (reservation_nr IN (SELECT RESERVATIONNUMBER FROM RESERVATION)) THEN
		IF (passport_nr IN (SELECT PASSPORTNUMBER FROM PASSENGER WHERE RESERVATIONNUMBER=reservation_nr)) THEN
			IF (passport_nr IN (SELECT PASSPORTNUMBER FROM CONTACT)) THEN
				SELECT "The contact already exists" as "Message";	
			ELSE
				INSERT INTO CONTACT(PASSPORTNUMBER, RESERVATIONNUMBER, PHONENUMBER, EMAIL) VALUES(passport_nr, reservation_nr, phone, email);
			END IF;
		ELSE
			SELECT "The person is not a passenger of the reservation" as "Message";
		END IF;
	ELSE
		SELECT "The given reservation number does not exist" as "Message";
	END IF;
END //

CREATE PROCEDURE addPayment(IN reservation_nr INTEGER, IN cardholder_name VARCHAR(30), IN credit_card_nr BIGINT)
BEGIN
	DECLARE passport_nr INTEGER;
	DECLARE flight_nr INTEGER;
	DECLARE free_seats INTEGER;
	DECLARE booking_price INTEGER;
	SET passport_nr = (SELECT PASSPORTNUMBER FROM CONTACT WHERE PASSPORTNUMBER IN (SELECT PASSPORTNUMBER FROM PASSENGER WHERE RESERVATIONNUMBER = reservation_nr));
	SET flight_nr = (SELECT FLIGHTNUMBER FROM RESERVATION WHERE RESERVATIONNUMBER = reservation_nr);
	SET free_seats = calculateFreeSeats(flight_nr);
	SET booking_price = calculatePrice(flight_nr);
	
	IF (reservation_nr IN (SELECT RESERVATIONNUMBER FROM RESERVATION)) THEN
		IF (free_seats >= (SELECT COUNT(PASSPORTNUMBER) FROM PASSENGER WHERE RESERVATIONNUMBER = reservation_nr)) THEN
			IF (passport_nr) THEN
				#SELECT SLEEP(5);
				IF(SELECT CARDNUMBER FROM CREDITCARD WHERE CARDNUMBER = credit_card_nr) THEN
					INSERT INTO BOOKING(RESERVATIONNUMBER, PRICE, CARDNUMBER, CONTACT) VALUES (reservation_nr, booking_price, credit_card_nr, passport_nr);
				ELSE
					INSERT INTO CREDITCARD(CARDNUMBER, CREDITCARDHOLDER) VALUES (credit_card_nr, cardholder_name);
					INSERT INTO BOOKING(RESERVATIONNUMBER, PRICE, CARDNUMBER, CONTACT) VALUES (reservation_nr, booking_price, credit_card_nr, passport_nr);
				END IF;
			ELSE
				SELECT "The reservation has no contact yet" as "Message";
			END IF;
		ELSE
			DELETE FROM CONTACT WHERE (PASSPORTNUMBER, RESERVATIONNUMBER) IN (SELECT PASSPORTNUMBER, RESERVATIONNUMBER FROM PASSENGER WHERE RESERVATIONNUMBER = reservation_nr);
			DELETE FROM PASSENGER WHERE RESERVATIONNUMBER = reservation_nr;
			DELETE FROM RESERVATION WHERE RESERVATIONNUMBER = reservation_nr ;


			SELECT "There are not enough seats available on the flight anymore, deleting reservation" as "Message";
		END IF;
	ELSE
		SELECT "The given reservation number does not exist" as "Message";
	END IF;
END //

CREATE FUNCTION calculateFreeSeats(flightnumber_in INTEGER)
RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE free_seats INTEGER;
	
	SET free_seats = 40;
	IF (SELECT SUM(RESERVATIONNUMBER) FROM RESERVATION WHERE FLIGHTNUMBER = flightnumber_in AND RESERVATIONNUMBER IN (SELECT RESERVATIONNUMBER FROM BOOKING) > 0) THEN
		SET free_seats = free_seats - (SELECT SUM(RESERVEDSEATS) FROM RESERVATION WHERE FLIGHTNUMBER = flightnumber_in AND RESERVATIONNUMBER IN (SELECT RESERVATIONNUMBER FROM BOOKING));
	END IF;
	
	RETURN free_seats;
END //

CREATE FUNCTION calculatePrice(flightnumber_in INTEGER)
RETURNS DOUBLE
DETERMINISTIC
BEGIN
	DECLARE price DOUBLE;
	DECLARE routeprice_var DOUBLE;
	DECLARE weekdayfac DOUBLE;
	DECLARE bookedpassengers INTEGER;
	DECLARE profitfac DOUBLE;
	
	SET routeprice_var = (SELECT ROUTEPRICE FROM ROUTE WHERE ID = (SELECT ROUTE FROM WEEKLYSCHEDULE WHERE ID = (SELECT WEEKLYFLIGHT FROM FLIGHT WHERE FLIGHTNUMBER=flightnumber_in)));
	SET weekdayfac = (SELECT WEEKDAYFACTOR FROM WEEKDAY WHERE DAY = (SELECT WEEKDAY FROM WEEKLYSCHEDULE WHERE ID = (SELECT WEEKLYFLIGHT FROM FLIGHT WHERE FLIGHTNUMBER = flightnumber_in)));
	SET profitfac = (SELECT PROFITFACTOR FROM YEAR WHERE YEAR = (SELECT YEAR FROM WEEKDAY WHERE DAY = (SELECT WEEKDAY FROM WEEKLYSCHEDULE WHERE ID = (SELECT WEEKLYFLIGHT FROM FLIGHT WHERE FLIGHTNUMBER = flightnumber_in))));
	SET bookedpassengers = (SELECT SUM(RESERVEDSEATS) FROM RESERVATION WHERE FLIGHTNUMBER = flightnumber_in AND RESERVATIONNUMBER IN (SELECT RESERVATIONNUMBER FROM BOOKING));
	IF (bookedpassengers IS NULL) THEN
		SET bookedpassengers = 0;
	END IF;	
	SET price = routeprice_var * weekdayfac * (bookedpassengers + 1)/40 * profitfac;
	
	
	RETURN price;
END //


CREATE TRIGGER issueTicket 
AFTER INSERT 
ON BOOKING FOR EACH ROW 
BEGIN
	DECLARE ticket_nr INTEGER;
	DECLARE flag BINARY;
	
	SET ticket_nr = (SELECT FLOOR(1 + (RAND() * 21412345)));
	SET flag = 1;
	
	WHILE flag = 1 DO
		IF(ticket_nr IN (SELECT TICKETNUMBER FROM TICKET)) THEN
			SET ticket_nr = (SELECT FLOOR(1 + (RAND() * 21412345)));
		ELSE
			SET flag = 0;
			INSERT INTO TICKET(TICKETNUMBER, RESERVATIONNUMBER, PASSPORTNUMBER) SELECT ticket_nr, NEW.RESERVATIONNUMBER, NEW.CONTACT FROM PASSENGER WHERE RESERVATIONNUMBER = NEW.RESERVATIONNUMBER AND PASSPORTNUMBER = NEW.CONTACT;
		END IF;
	END WHILE;	
END//


CREATE VIEW allFlights AS SELECT calculateFreeSeats(f.FLIGHTNUMBER) AS nr_of_free_seats, ROUND(calculatePrice(f.FLIGHTNUMBER),3) AS current_price_per_seat, f.WEEK AS departure_week, weekly.DEPARTURETIME as departure_time, weekly.WEEKDAY AS departure_day, rout.YEAR AS departure_year, air1.AIRPORTNAME AS destination_city_name, air2.AIRPORTNAME AS departure_city_name FROM FLIGHT f LEFT JOIN (SELECT ID, ROUTE,  DEPARTURETIME, WEEKDAY FROM WEEKLYSCHEDULE) weekly ON f.WEEKLYFLIGHT = weekly.ID LEFT JOIN (SELECT ID, YEAR, ARRIVESTO, DEPARTSFROM FROM ROUTE) AS rout ON weekly.ROUTE = rout.ID LEFT JOIN (SELECT AIRPORTCODE, AIRPORTNAME FROM AIRPORT) AS air1 ON rout.ARRIVESTO = air1.AIRPORTCODE LEFT JOIN (SELECT AIRPORTCODE, AIRPORTNAME FROM AIRPORT) AS air2 ON rout.DEPARTSFROM = air2.AIRPORTCODE//

DELIMITER ; 


/*
ASSUMPTIONS MADE: 
	* A reservation is always created first, then passengers are added to a reservation.
	
	* Using auto-increment instead of the Rand() function in some places since the rand function gave the same values sometimes.


8. 
a) How can you protect the credit card information in the database from hackers?

	A way to protect the credit card information in the database is by encrypting the information before inserting it into the table.

b) Give three advantages of using stored procedures in the database (and thereby execute them on the server) instead of writing the same functions in the front-end of the system (in for example java-script on a web-page)?

	One advantage is that procedures are easy to change. If you would call the same procedure from multiple sources, this would reduce the risk of incorrect behavior compared to having that function in the front-end. Another advantage is 		that it is faster, since you don’t have to send for example multiple queries to the database from the frontend, you only need to call a procedure. The third advantage is that you need a bit of a different syntax when constructing the 		queries in another language, compared to when writing pure SQL, which only requires you to know SQL.

9.

a) In session A, add a new reservation. 

b) Is this reservation visible in session B? Why? Why not?

	No it is not visible, since the transaction has not been committed yet. If you commit from session A then the reservation is visible in session B.  

c) What happens if you try to modify the reservation from A in B? Explain what happens and why this happens and how this relates to the concept of isolation of transactions.

	If we try to modify the reservation from A in B, then B will wait until A has committed the transaction. During a transaction that modifies a table, that table is locked for modification, this happens because otherwise you could get 		inconsistent data or errors. For example, two inserts with an auto-incremented key (without locks) would lead to very strange data. This directly relates to the default isolation level of InnoDB, which is Repeatable Read, since the 	transactions lock a table and you cannot read data that has not been committed yet by another transaction.

10.

Did overbooking occur when the scripts were executed? If so, why? If not, why not?

	No, overbooking did not occur. This is because the function addPayment is not executed exactly at the same time, and therefore the calculated free seats is still calculated correctly.
	
Can an overbooking theoretically occur? If an overbooking is possible, in what order must the lines of code in your procedures/functions be executed.
 
	Yes, an overbooking can theoretically occur. In order for it to happen, we need to make sure that checks for overbooking happens before we insert into the tables. So we must wait for the two sessions to calculate their free seats 		before inserting into the booking tables (which is used to calculate the amount of free seats). So after line 162 has been executed, we need to wait to make sure both functions has entered here, before executing the inserts into 		booking at line number 166 or 169.

Try to make the theoretical case occur in reality by simulating that multiple sessions call the procedure at the same time. To specify the order in which the lines of code are executed use the MySQL query SELECT sleep(5); which makes the session sleep for 5 seconds. Note that it is not always possible to make the theoretical case occur, if not, motivate why. 
In order to make this theoretical case occur we add a SELECT sleep(5) at line 164 in our code, which then makes the overbooking happen.
Modify the testscripts so that overbookings are no longer possible using (some of) the commands START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK TABLES, ROLLBACK, SAVEPOINT, and SELECT...FOR UPDATE. Motivate why your solution solves the issue, and test that this also is the case using the sleep implemented in 10c. Note that it is not ok that one of the sessions ends up in a deadlock scenario. Also, try to hold locks on the common resources for as short time as possible to allow multiple sessions to be active at the same time.

Identify one case where a secondary index would be useful. Design the index,
describe and motivate your design. (Do not implement this.)

It would be useful in the Ticket table in the case we want to use the passportnumber to search for a ticketnumber. For example, say we have 2 000 000 entries in the Ticket table.
Then the total amount of bytes for an entry would be 4 + 4 + 4 = 12. The default block size in MySQL is 16 000 bytes.
Therefore the number of blocks will be 2 000 000/(16 000/12) = 1500. Worst case to find the ticket number would be 1500 units of time. 

If we however use a secondary index with an entry being 8 bytes, then we would have 2 000 000/(16 000/8) = 1000 blocks.
Then the worst case search time would be log_2(1000) = 10 units of time.
This is an improvement by a factor 150, which is nice.	

*/

