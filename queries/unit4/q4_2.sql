-- 4.2.A
-- For each flight, how many bookings are there, and how many of them were cancelled?
-- Also computes a cancellation rate percentage for each flight.
-- Requirement: CASE inside an aggregate, both totals as separate columns
SELECT flight_id,
       COUNT(*) AS total_bookings,
       SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings,
       ROUND(100.0 * SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM bookings
GROUP BY flight_id
ORDER BY cancellation_rate_pct DESC, flight_id;

-- 4.2.B
-- What are the total bookings, cancelled bookings, cancellation rate, and total fare for each region?
-- 
-- Requirement: ROLLUP, subtotals and grand total
SELECT CASE WHEN GROUPING(booking_country) = 1 THEN 'GRAND TOTAL'
            ELSE booking_country END AS region,
       CASE WHEN GROUPING(booking_country) = 1 THEN 'Grand total'
            ELSE 'Regional subtotal' END AS row_type,
       COUNT(*) AS total_bookings,
       SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings,
       ROUND(100.0 * SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct,
       SUM(fare_paid) AS total_fare
FROM bookings
GROUP BY ROLLUP (booking_country)
ORDER BY GROUPING(booking_country), booking_country;

-- 4.2.C
-- What is the cancellation rate for the busiest flights?
-- Step 1: the CTE (flight_summary) counts the bookings and cancelled bookings for each flight.
-- Step 2: the main query keeps only flights with at least 15 bookings (high volume)
-- and adds up the aggregations from the CTE for those flights. 
-- The result is the baseline for high-volume flights.
-- Why 15?: The average flight has about 15 bookings, so this keeps the busier flights.
-- Requirement: WITH clause, second aggregation on the intermediate result
WITH flight_summary AS (
    SELECT flight_id,
           COUNT(*) AS total_bookings,
           SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings
    FROM bookings
    GROUP BY flight_id
)
SELECT COUNT(*) AS high_volume_flights,
       SUM(total_bookings) AS high_volume_bookings,
       SUM(cancelled_bookings) AS high_volume_cancelled_bookings,
       ROUND(100.0 * SUM(cancelled_bookings) / SUM(total_bookings), 1) AS high_volume_cancellation_rate_pct
FROM flight_summary
WHERE total_bookings >= 15;