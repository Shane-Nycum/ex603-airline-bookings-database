-- 5.2.A.1
-- Which flights exist, and how many bookings does each one have, including flights with no bookings?
-- Returns 15 flights, two of which have no bookings.
-- Requirement: LEFT JOIN
SELECT f.flight_id,
       f.flight_number,
       COUNT(b.booking_id) AS total_bookings
FROM flights f
LEFT JOIN bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;

-- 5.2.A.2
-- Same question as 5.2.A.1, but with an INNER JOIN.
-- Returns 13 flights. The two flights with no bookings are excluded.
-- An INNER JOIN only includes results where there is a match
-- between the both tables on the join condition.
-- Requirement: equivalent INNER JOIN
SELECT f.flight_id,
       f.flight_number,
       COUNT(b.booking_id) AS total_bookings
FROM flights f
INNER JOIN bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;

-- 5.2.B.1
-- Do we get the same flight list if we start from the bookings table and use a RIGHT JOIN?
-- A RIGHT JOIN keeps every row from the table on the right.
-- So this is the same as 5.2.A.1, with the table order swapped.
-- Returns the same 15 flights as 5.2.A.1, with the same booking counts. The two flights with no bookings are still there.
-- Requirement: RIGHT JOIN that returns the same records as the earlier query that uses LEFT JOIN
SELECT f.flight_id,
       f.flight_number,
       COUNT(b.booking_id) AS total_bookings
FROM bookings b
RIGHT JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;

-- 5.2.B.2
-- How many bookings does each flight have, if we keep unmatched rows from BOTH tables?
-- The FULL OUTER JOIN answers this question in one query, which can be helpful to analyze orphaned records on both side of the join.
-- Returns 15 rows, the same as the LEFT JOIN in 5.2.A.1. Flights 14 and 15 show up with 0 bookings.
-- There are no extra rows beyond the ones listed in 5.2.A.1, so every booking record has a matching flight in the flights table.
-- If a booking had no matching flight, it would show up as a row with a null flight_id and flight_number.
-- Requirement: FULL OUTER JOIN
SELECT f.flight_id,
       f.flight_number,
       COUNT(b.booking_id) AS total_bookings
FROM flights f
FULL OUTER JOIN bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;

-- 5.2.C.1
-- Which flights have never had a booking? (using NOT EXISTS)
-- For each flight, NOT EXISTS checks whether any booking points to it. If none do, the flight is returned.
-- Returns flights 14 and 15.
-- Requirement: NOT EXISTS
SELECT f.flight_id,
       f.flight_number
FROM flights f
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.flight_id = f.flight_id
)
ORDER BY f.flight_id;

-- 5.2.C.2
-- Which flights have never had a booking? (using EXCEPT)
-- Takes the list of all flight IDs and removes the ones that appear in bookings.
-- What is left is the flights with no bookings.
-- Returns flights 14 and 15, the same as 5.2.C.1.
-- How the two differ (NOT EXISTS vs EXCEPT):
-- NOT EXISTS lets you select any column from the flights table, like flight_number, in the main query.
-- EXCEPT only gives back the columns it compares (here, just flight_id).
-- To also show flight_number, I had to put the EXCEPT inside a subquery.
-- Both find the same two flights (14 and 15).
-- Requirement: EXCEPT
SELECT f.flight_id,
       f.flight_number
FROM flights f
WHERE f.flight_id IN (SELECT flight_id FROM flights
                      EXCEPT
                      SELECT flight_id FROM bookings)
ORDER BY f.flight_id;
