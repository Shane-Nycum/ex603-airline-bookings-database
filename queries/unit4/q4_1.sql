-- 4.1.1
-- What do the bookings look like overall?
-- Counts the bookings, adds up the fares, and finds the average, lowest and highest fare.
-- Also counts how many different passengers appear.
-- Observations: 200 bookings from 30 different passengers. 
-- The lowest fare is 0.00, which raise a red flag for investigation.
-- The last column shows 34 bookings with a $0 fare. 
-- Requirement: COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT)
SELECT COUNT(*) AS total_bookings,
       SUM(fare_paid) AS total_fare,
       ROUND(AVG(fare_paid), 2) AS avg_fare,
       MIN(fare_paid) AS min_fare,
       MAX(fare_paid) AS max_fare,
       COUNT(DISTINCT passenger_id) AS distinct_passengers,
       SUM(CASE WHEN fare_paid = 0 THEN 1 ELSE 0 END) AS zero_fare_bookings
FROM bookings;

-- 4.1.2
-- How many bookings does each flight have, and what is the average fare for each flight?
-- Sorted from the most bookings to the fewest.
-- Observations: There are 13 different flights.
-- Flight 6 is the most in-demand with 21 bookings and flight 4 has the least demand with 6.
-- Average fares range from $11.94 (flight 11) to $23.06 (flight 5).
-- Requirement: GROUP BY, COUNT, AVG, ORDER BY
SELECT flight_id,
       COUNT(*) AS booking_count,
       ROUND(AVG(fare_paid), 2) AS avg_fare
FROM bookings
GROUP BY flight_id
ORDER BY booking_count DESC, flight_id;

-- 4.1.3
-- Which flights have enough bookings for their numbers to mean something?
-- Only keeps flights with at least 10 bookings.
-- Why 10: with fewer than 10 bookings, a single outlier can shift 
-- the average fare by a large amount. 
-- The average flight has about 15 bookings, so 10 is
-- low enough to keep most flights but high enough to drop the tiny ones.
-- Requirement: HAVING
SELECT flight_id,
       COUNT(*) AS booking_count,
       ROUND(AVG(fare_paid), 2) AS avg_fare
FROM bookings
GROUP BY flight_id
HAVING COUNT(*) >= 10
ORDER BY booking_count DESC, flight_id;

-- 4.1.4
-- How do fares vary by region and booking status together?
-- The region is the country the booking was made in (booking_country).
-- Returns one row per country and status combination, with the count and fare statistics.
-- Returns 14 rows. Thailand has no disputed bookings, so it only has 2 rows
-- and the other 4 countries have 3 each.
-- Cancelled bookings always have a fare of 0.
-- Requirement: GROUP BY two columns
SELECT booking_country,
       booking_status,
       COUNT(*) AS booking_count,
       SUM(fare_paid) AS total_fare,
       ROUND(AVG(fare_paid), 2) AS avg_fare,
       MIN(fare_paid) AS min_fare,
       MAX(fare_paid) AS max_fare
FROM bookings
GROUP BY booking_country, booking_status
ORDER BY booking_country, booking_status;
