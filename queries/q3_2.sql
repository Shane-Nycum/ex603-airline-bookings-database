---------------------------------------------------------------
-- Part A
---------------------------------------------------------------

-- 3.2.A.1
-- Which bookings do not have a cancelled flight?
-- This is the broken version. It returns 27 rows.
-- Comparing NULL to a value gives UNKNOWN, so bookings with no
-- cancellation reason are dropped without any warning.
-- Requirement: != on a nullable column (cancellation_reason)
SELECT booking_id, booking_status, cancellation_reason
FROM bookings
WHERE cancellation_reason != 'Flight cancelled'
ORDER BY booking_id;

-- 3.2.A.2
-- How many bookings are there in total in the table?
-- We find that there are 200 bookings in total.
SELECT COUNT(*) AS total_bookings
FROM bookings;

-- 3.2.A.3
-- Which bookings did the first query silently leave out?
-- These are the 166 bookings where cancellation_reason is NULL.
-- 27 + 166 = 193, which is not the table total of 200.
-- There are still 7 rows unaccounted for.
-- Requirement: IS NULL
SELECT booking_id, booking_status, cancellation_reason
FROM bookings
WHERE cancellation_reason IS NULL
ORDER BY booking_id;

-- 3.2.A.4
-- Which bookings have a cancelled flight?
-- We find that there are 7 rows with cancelled flights. 
-- 27 + 166 + 7 = 200, so every booking is accounted for.
-- Requirement: = on a nullable column
SELECT booking_id, booking_status, cancellation_reason
FROM bookings
WHERE cancellation_reason = 'Flight cancelled'
ORDER BY booking_id;

-- 3.2.A.5
-- Repair: which bookings do not have a cancelled flight?
-- Includes the ones with a NULL cancellation reason.
-- Returns 193 rows (200 - 7), which is what the first query should have returned.
-- Requirement: IS NULL
SELECT booking_id, booking_status, cancellation_reason
FROM bookings
WHERE cancellation_reason != 'Flight cancelled'
   OR cancellation_reason IS NULL
ORDER BY booking_id;

---------------------------------------------------------------
-- Part B
---------------------------------------------------------------

-- 3.2.B.1
-- What happens when WHERE uses an alias defined in SELECT?
-- It fails. WHERE is evaluated before SELECT, so the alias does not exist yet.
-- The query is commented out so this file runs without editing.
-- Requirement: alias in WHERE
-- PostgreSQL error, verbatim:
--   ERROR:  column "adjusted_fare" does not exist
--   LINE 4: WHERE adjusted_fare > 40
--
SELECT booking_id,
      fare_paid * fare_multiplier AS adjusted_fare
FROM bookings
WHERE adjusted_fare > 40;

-- 3.2.B.2
-- Which bookings have an adjusted fare (fare paid times multiplier) over 40?
-- Fix 1: repeat the expression in WHERE.
-- Requirement: computed column, repeated expression in WHERE
SELECT booking_id,
       fare_paid * fare_multiplier AS adjusted_fare
FROM bookings
WHERE fare_paid * fare_multiplier > 40
ORDER BY booking_id;

-- 3.2.B.3
-- Which bookings have an adjusted fare (fare paid times multiplier) over 40?
-- Fix 2: wrap the alias in a CTE so it becomes a real column
-- Requirement: CTE
WITH adjusted_fares AS (
    SELECT booking_id,
           fare_paid * fare_multiplier AS adjusted_fare
    FROM bookings
)
SELECT booking_id, adjusted_fare
FROM adjusted_fares
WHERE adjusted_fare > 40
ORDER BY booking_id;