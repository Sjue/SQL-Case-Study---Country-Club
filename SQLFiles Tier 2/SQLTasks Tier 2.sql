/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
 
 SELECT name, membercost
        FROM FACILITIES
        WHERE membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) AS no_fee
        FROM FACILITIES
        WHERE membercost = 0
There are 4 facilities that do not charge a fee to members

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
        FROM Facilities
        WHERE membercost <> 0 AND membercost < (.2*monthlymaintenance)


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
ELSE 'cheap' END AS expense
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT  (Members.firstname || Members.surname) as name, Facilities.name as court
FROM Bookings
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
INNER JOIN Members
ON Bookings.memid = Members.memid
Where Facilities.facid = 0 OR Facilities.facid = 1
ORDER BY name


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name as facility, (Members.firstname || ' ' || Members.surname) as fullname,
CASE WHEN Bookings.memid = 0 THEN Bookings.slots * Facilities.guestcost
ELSE Bookings.slots * Facilities.membercost
END AS cost
FROM Bookings
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
LEFT JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.starttime LIKE '2012-09-14%' and cost>30
Order BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT facility, fullname, cost, starttime
FROM (Select f.name AS facility, 
(m.firstname || ' ' || m.surname) as fullname, 
b.starttime AS starttime,
CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
ELSE b.slots * f.membercost
END AS cost
FROM Bookings AS b
Inner Join Facilities AS f
ON b.facid = f.facid
Inner Join Members AS m
ON b.memid = m.memid
WHERE cost > 30 and starttime LIKE '2012-09-14%'
ORDER BY cost DESC) as subquery

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name as facility,
(SELECT SUM(CASE WHEN Bookings.memid = 0 THEN Bookings.slots * Facilities.guestcost
ELSE Bookings.slots * Facilities.membercost
END)) AS revenue
FROM Bookings
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
LEFT JOIN Members
ON Bookings.memid = Members.memid
GROUP BY Facilities.name
HAVING revenue < 1000
ORDER BY revenue

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m.surname AS Member_surname, m.firstname AS Member_Firstname, recommended.surname AS Recommended_surname, recommended.firstname AS Recommended_firstname
FROM Members AS m 
INNER JOIN Members AS recommended
ON m.memid = recommended.recommendedby
ORDER BY Member_surname, Member_firstname

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT (m.firstname || ' ' || m.surname) as fullname, f.name AS facility, sum(b.slots) AS usage
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN Members AS m
ON b.memid = m.memid
WHERE b.memid <> 0
GROUP by fullname
ORDER BY usage, fullname

/* Q13: Find the facilities usage by month, but not guests */

SELECT SUBSTRING(b.starttime, 1, 7) AS months, SUM(b.slots) as usage, f.name AS facility
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN Members AS m
ON b.memid = m.memid
GROUP by facility, months
ORDER BY months;