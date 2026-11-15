-- 6.3.A
-- What are the three highest fares on each flight, and how far below the flight's highest fare is each one?
-- FIRST_VALUE gets the flight's highest fare, which is used to calculate how much lower each fare is than the top fare.
-- Cancelled bookings are filtered out because their fare is 0 and it doesn't
-- make sense to include them in this report.
--
-- Ties at third place: I used ROW_NUMBER, not RANK, to cap each flight at exactly three rows.
-- This keeps the list bounded at three so it fits in a dashboard view that's expecting three rows.
-- With RANK, a tie for third would add more rows and the number of items would not be fixed at 3.
-- If two bookings tie for third, the one booked earlier is kept. This is the tie breaker.
-- No flight has a tie at third place in this data.
--
-- Requirement: ranking window function partitioned by flight, row number <= 3 filtered in a CTE, FIRST_VALUE
WITH ranked AS (
    SELECT flight_id,
           booking_id,
           booked_at,
           fare_paid,
           ROW_NUMBER() OVER (
               PARTITION BY flight_id
               ORDER BY fare_paid DESC, booked_at
           ) AS fare_rank_in_flight,
           FIRST_VALUE(fare_paid) OVER (
               PARTITION BY flight_id
               ORDER BY fare_paid DESC, booked_at
           ) AS flight_top_fare
    FROM bookings
    WHERE booking_status <> 'cancelled'
)
SELECT flight_id,
       fare_rank_in_flight,
       booking_id,
       booked_at,
       fare_paid,
       ROUND(100.0 * (fare_paid - flight_top_fare) / flight_top_fare, 1) AS pct_lower_than_top_fare
FROM ranked
WHERE fare_rank_in_flight <= 3
ORDER BY flight_id, fare_rank_in_flight;

-- 6.3.B.1
-- Is the cancellation rate getting better or worse each month?
--
-- Answer: there is no steady direction. The cancellation rate is higher than the month before in 7 of the 11 months,
-- and lower in 4. The rate in December 2023 (18.8%) ends below the rate in January 2023 (23.8%).
-- 
-- missing_month_check is the number of months since the prior row. It is 1 for every row, so no month is missing.
-- This matters because LAG(..., 1) looks back one row, not one month. A month with no bookings would have no row.
--
-- What the two change columns show, using February as an example (rate 19.0% vs 23.8% in January):
-- cancellation_rate_point_change_vs_prior_month is this month's cancellation rate minus last month's cancellation rate. February: -4.8 points.
-- cancellation_rate_pct_change_vs_prior_month is that change as a percent of last month's rate. February: -20.0%,
-- meaning February's cancellation rate is 20% lower than January's cancellation rate.
-- FYI: Both of these fields are calculated based on the unrounded rates, so doing the math by hand 
-- on the rounded rates can be off by a little.
--
-- Requirement: DATE_TRUNC to group by month, LAG, percent change with NULLIF, a check for missing months
WITH monthly_totals AS (
    -- Bookings per month (only months with at least one booking)
    SELECT DATE_TRUNC('month', booked_at)::date AS month,
           COUNT(*) AS total_bookings,
           SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings,
           100.0 * SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END)            / COUNT(*) AS cancellation_rate
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)
),
compared AS (
    SELECT month,
           total_bookings,
           cancelled_bookings,
           cancellation_rate,
           LAG(month, 1) OVER (
               ORDER BY month
           ) AS prior_month,
           LAG(cancellation_rate, 1) OVER (
               ORDER BY month
           ) AS prior_month_cancellation_rate
    FROM monthly_totals
)
SELECT TO_CHAR(month, 'YYYY-MM') AS month,
       total_bookings,
       cancelled_bookings,
       ROUND(cancellation_rate, 1) AS cancellation_rate_pct,
       ROUND(cancellation_rate - prior_month_cancellation_rate, 1) AS cancellation_rate_point_change_vs_prior_month,
       ROUND(100.0 * (cancellation_rate - prior_month_cancellation_rate) / NULLIF(prior_month_cancellation_rate, 0), 1) AS cancellation_rate_pct_change_vs_prior_month,
       (EXTRACT(YEAR FROM AGE(month, prior_month)) * 12
        + EXTRACT(MONTH FROM AGE(month, prior_month)))::int AS missing_month_check
FROM compared
ORDER BY month;

-- 6.3.B.2
-- What is the cancellation rate for each quarter?
--
-- I added this query to help answer the closing memo (Task 6.4). 
-- Months are too small to show a trend, so this groups them into quarters.
--
-- Requirement: group events by calendar period (quarter), LAG to compare with the prior quarter
WITH quarterly_totals AS (
    -- Bookings per quarter (only quarters with at least one booking)
    SELECT DATE_TRUNC('quarter', booked_at)::date AS quarter,
           COUNT(*) AS total_bookings,
           COUNT(*) FILTER (WHERE booking_status = 'cancelled') AS cancelled_bookings,
           100.0 * COUNT(*) FILTER (WHERE booking_status = 'cancelled') / COUNT(*) AS cancellation_rate
    FROM bookings
    GROUP BY DATE_TRUNC('quarter', booked_at)
)
SELECT TO_CHAR(quarter, 'YYYY-"Q"Q') AS quarter,
       total_bookings,
       cancelled_bookings,
       ROUND(cancellation_rate, 1) AS cancellation_rate_pct,
       ROUND(
           cancellation_rate - LAG(cancellation_rate, 1) OVER (
               ORDER BY quarter
           ), 1
       ) AS cancellation_rate_point_change_vs_prior_quarter
FROM quarterly_totals
ORDER BY quarter;
