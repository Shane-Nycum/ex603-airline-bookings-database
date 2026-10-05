---------------------------------------------------------------
-- 3.3 
-- Which passengers were involved in disputed bookings?
---------------------------------------------------------------

-- 3.3.1
-- Which passengers were involved in disputed bookings?
-- Form 1: A subquery that finds the disputed bookings, filtered with IN.
-- Returns 7 passengers.
-- Requirement: subquery using IN (or NOT IN)
SELECT passenger_id, passenger_name
FROM passengers
WHERE passenger_id IN (
    SELECT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
)
ORDER BY passenger_id;

-- 3.3.2
-- Which passengers were involved in disputed bookings?
-- Form 2: The disputed bookings are found in a CTE,
-- and the passengers are filtered using the CTE. 
-- Returns the same 7 passengers.
-- Requirement: Common Table Expression using WITH
WITH disputed_bookings AS (
    SELECT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
)
SELECT passenger_id, passenger_name
FROM passengers
WHERE passenger_id IN (SELECT passenger_id FROM disputed_bookings)
ORDER BY passenger_id;

-- 3.3.3
-- Which passengers were involved in disputed bookings?
-- Form 3: a CASE-based construction. 
-- The CASE statement returns the passenger_id for disputed bookings and NULL for every other booking.
-- The outer IN keeps the passengers found in that list. 
-- Returns the same 7 passengers.
-- Requirement: a third form distinct from IN and WITH (a CASE-based construction)
SELECT passenger_id, passenger_name
FROM passengers
WHERE passenger_id IN (
    SELECT CASE WHEN booking_status = 'disputed' THEN passenger_id END
    FROM bookings
)
ORDER BY passenger_id;

-- 3.3.4
-- Do the three forms return identical rows, not just the same number of rows?
-- Each check in the main query is TRUE when EXCEPT finds no rows on one side that are missing
-- from the other. All checks are TRUE, proving that the rows themselves match.
-- Requirement: show the rows match, not just the row counts (EXCEPT, NOT EXISTS)
WITH form1 AS (
    SELECT passenger_id, passenger_name
    FROM passengers
    WHERE passenger_id IN (
        SELECT passenger_id
        FROM bookings
        WHERE booking_status = 'disputed'
    )
),
disputed_bookings AS (
    SELECT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
),
form2 AS (
    SELECT passenger_id, passenger_name
    FROM passengers
    WHERE passenger_id IN (SELECT passenger_id FROM disputed_bookings)
),
form3 AS (
    SELECT passenger_id, passenger_name
    FROM passengers
    WHERE passenger_id IN (
        SELECT CASE WHEN booking_status = 'disputed' THEN passenger_id END
        FROM bookings
    )
)
SELECT
    NOT EXISTS (SELECT * FROM form1 EXCEPT SELECT * FROM form2) AS f1_has_nothing_extra_vs_f2,
    NOT EXISTS (SELECT * FROM form2 EXCEPT SELECT * FROM form1) AS f2_has_nothing_extra_vs_f1,
    NOT EXISTS (SELECT * FROM form1 EXCEPT SELECT * FROM form3) AS f1_has_nothing_extra_vs_f3,
    NOT EXISTS (SELECT * FROM form3 EXCEPT SELECT * FROM form1) AS f3_has_nothing_extra_vs_f1;

-- 3.3.5
-- When would the three forms NOT be equivalent?
-- For this question, none of the usual conditions break them. All three forms ask
-- the same thing: is the passenger's id in the list of disputed booking passenger ids?
-- They only build that list differently.
-- NULLs: do not break them. IN skips NULLs in its list, so a NULL passenger_id or
--   booking_status is ignored by all three. (passenger_id is NOT NULL in both tables
--   anyway, and it is the primary key in passengers.)
-- Duplicates: do not break them. IN only checks whether the id is in the list, so
--   repeats are harmless. The 10 disputed bookings belong to only 7 passengers, and
--   all three forms return those 7.
-- Empty result: does not break them. With no disputed bookings, the list is empty
--   (or only NULLs in Form 3), and all three return 0 rows.
-- Where it would break: If we were answering the inverse question (passengers with NO disputed booking)
--   and the queries were written with NOT IN. One NULL in the list makes NOT IN return no rows at all.
--   Form 3 would break, because its CASE statement puts a NULL in the list for every
--   booking that is not disputed. 
