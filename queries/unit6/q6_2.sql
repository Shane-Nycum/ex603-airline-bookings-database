-- 6.2.A
-- Is the fare on flight 6 going up or down from one booking to the next?
-- Shows the previous fare, the next fare, and the change (delta) for each booking, in time order.
-- Cancelled bookings are left out because their fare of 0 
-- skews the results and makes the delta look bigger than it really is.
-- There is no clear trend in the deltas. The fare goes up in 9 of the 16 changes and down in 7.
-- It ends 10.29 above where it started (18.77 to 29.06), but it swings up and down along the way.
-- Requirement: LAG and LEAD partitioned by flight and ordered by booking time, 
-- a delta column, filtered to one flight
SELECT flight_id,
       booking_id,
       booked_at,
       fare_paid,
       LAG(fare_paid) OVER (
           PARTITION BY flight_id
           ORDER BY booked_at
       ) AS prev_fare,
       LEAD(fare_paid) OVER (
           PARTITION BY flight_id
           ORDER BY booked_at
       ) AS next_fare,
       fare_paid - LAG(fare_paid) OVER (
           PARTITION BY flight_id
           ORDER BY booked_at
       ) AS fare_delta_from_prev_booking
FROM bookings
WHERE flight_id = 6
  AND booking_status <> 'cancelled'
ORDER BY booked_at;

-- 6.2.B
-- How much fare has the platform collected so far in Q4 2023 (Oct to Dec), and what is the recent daily average?
-- Target: $1,000 in total fare_paid for Q4 2023. This is about the same as Q3 ($1,004.11).
-- Cancelled bookings are left out. They have a fare of 0, and a day with only cancelled bookings would show up as a 0 day.
-- The running total ends at 857.31 on 2023-12-28, which is 85.7% of the target ($142.69 short).
--
-- The moving average covers the current day and the 6 days before it that have bookings (7 rows in total).
-- ROWS counts rows, not calendar days. Some calendar days have no bookings, so they have no row.
-- That means 7 rows can cover more than 7 calendar days.
-- On the first 6 rows there are fewer than 7 rows to use, so the average uses the rows that exist.
--
-- ROWS vs RANGE: ROWS counts physical rows. RANGE includes every row with the same ORDER BY value as the current row.
-- When no frame is given, the default is RANGE, so rows with the same ORDER BY value get the same running total.
-- This query has one row for each day, so booking_date has no ties and ROWS and RANGE would give the same result.
-- Requirement: running total with ROWS UNBOUNDED PRECEDING, moving average with ROWS n PRECEDING, a stated target
WITH daily_fare_totals AS (
    -- Fare per day (only days with at least one non-cancelled booking)
    SELECT booked_at::date AS booking_date,
           SUM(fare_paid) AS daily_fare
    FROM bookings
    WHERE booked_at >= DATE '2023-10-01'
      AND booked_at < DATE '2024-01-01'
      AND booking_status <> 'cancelled'
    GROUP BY booked_at::date
)
SELECT booking_date,
       daily_fare,
       ROUND(
           AVG(daily_fare) OVER (
               ORDER BY booking_date
               ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ), 2
       ) AS daily_fare_moving_avg_last_7_rows,
       SUM(daily_fare) OVER (
           ORDER BY booking_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total,
       1000 AS target,
       ROUND(
           100.0 * SUM(daily_fare) OVER (
               ORDER BY booking_date
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) / 1000, 1
       ) AS pct_of_target
FROM daily_fare_totals
ORDER BY booking_date;

-- 6.2.C
-- Which flights went more than 60 days between two bookings?
-- Returns 11 gaps. The longest is flight 9, with no bookings from 2023-01-05 to 2023-04-28 (113 days).
-- Requirement: LAG in a CTE, with the gap filter in the outer WHERE
WITH booking_gaps AS (
    SELECT flight_id,
           booked_at,
           LAG(booked_at) OVER (
               PARTITION BY flight_id
               ORDER BY booked_at
           ) AS prev_booked_at,
           booked_at::date - LAG(booked_at::date) OVER (
               PARTITION BY flight_id
               ORDER BY booked_at
           ) AS gap_days
    FROM bookings
)
SELECT flight_id,
       prev_booked_at,
       booked_at AS next_booked_at,
       gap_days
FROM booking_gaps
WHERE gap_days > 60
ORDER BY gap_days DESC, flight_id;
