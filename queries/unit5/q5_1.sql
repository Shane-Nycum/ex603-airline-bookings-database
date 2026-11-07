-- 5.1.1
-- Who are the passengers behind each booking, and which flight was each booking for?
-- Joins bookings (the events) to passengers (the actors) and flights (the producers).
-- Each row is one booking, with the passenger name, the flight number, and the date and time it was booked.
-- Requirement: three-table INNER JOIN
SELECT p.passenger_name,
       f.flight_number,
       b.booked_at
FROM bookings b
INNER JOIN passengers p ON p.passenger_id = b.passenger_id
INNER JOIN flights f ON f.flight_id = b.flight_id
ORDER BY p.passenger_name, f.flight_number;

-- 5.1.2
-- Which airports are linked to the flights I flagged in Assignment 4 (flights 2, 9 and 11)?
-- Are any airports shared between these three flights?
-- Requirement: join a producer table to a catalog table through the junction table
SELECT f.flight_id,
       f.flight_number,
       a.iata_code,
       a.airport_name,
       fr.effective_from
FROM flights f
INNER JOIN flight_routes fr ON fr.flight_id = f.flight_id
INNER JOIN airports a ON a.airport_id = fr.airport_id
WHERE f.flight_id IN (2, 9, 11)
ORDER BY f.flight_id, fr.effective_from;

-- 5.1.3
-- Do the flights I flagged in Assignment 4 look different from other flights from the same country?
-- Step 1: the CTE (flight_stats) counts the bookings and the cancellation rate for each flight.
-- Step 2: the self join matches each flagged flight (2, 9 and 11) with the other flights
-- in the flights table that share its origin country.
-- Then we can compare size (seat capacity), activity (bookings) and cancellation rate side by side.
-- Requirement: self join on the producer table
WITH flight_stats AS (
    SELECT flight_id,
           COUNT(*) AS total_bookings,
           ROUND(100.0 * SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
    FROM bookings
    GROUP BY flight_id
)
SELECT f.flight_id AS flagged_flight_id,
       o.flight_id AS other_flight_id,
       f.flight_number AS flagged_flight_number,
       o.flight_number AS other_flight_number,
       f.origin_country,
       f.is_active AS flagged_is_active,
       o.is_active AS other_is_active,
       f.seat_capacity AS flagged_seat_capacity,
       o.seat_capacity AS other_seat_capacity,
       fs1.total_bookings AS flagged_bookings,
       fs2.total_bookings AS other_bookings,
       fs1.cancellation_rate_pct AS flagged_cancellation_rate_pct,
       fs2.cancellation_rate_pct AS other_cancellation_rate_pct
FROM flights f
INNER JOIN flights o ON o.origin_country = f.origin_country
                     AND o.flight_id <> f.flight_id
INNER JOIN flight_stats fs1 ON fs1.flight_id = f.flight_id
INNER JOIN flight_stats fs2 ON fs2.flight_id = o.flight_id
WHERE f.flight_id IN (2, 9, 11)
ORDER BY f.flight_id, o.flight_id;
