-- 6.1.1.1
-- Is a booking unusual for its own flight? 
-- Shows every booking next to the average fare of its flight.
-- Returns 166 rows, one for each booking that was not cancelled.
-- I filtered out cancelled bookings because they have a fare of 0.
-- Including them would pull each flight's average down 
-- and make every other booking look high.
-- I kept disputed bookings, because they still have a fare.
-- Requirement: AVG(...) OVER (PARTITION BY ...)
SELECT booking_id,
       flight_id,
       fare_paid,
       ROUND(
           AVG(fare_paid) OVER (
               PARTITION BY flight_id
           ), 2
       ) AS flight_avg_fare,
       ROUND(
           fare_paid - AVG(fare_paid) OVER (
               PARTITION BY flight_id
           ), 2
       ) AS diff_from_flight_avg
FROM bookings
WHERE booking_status <> 'cancelled'
ORDER BY flight_id, booking_id;

-- 6.1.1.2
-- Same question as 6.1.1.1, but with GROUP BY.
-- Returns 13 rows, one for each flight. 6.1.1.1 returns 166 rows.
-- What is lost: the individual bookings. We get each flight's average,
-- but we can't see which bookings are above or below it.
-- Requirement: the equivalent GROUP BY version, with the row count compared
SELECT flight_id,
       COUNT(*) AS bookings,
       ROUND(AVG(fare_paid), 2) AS flight_avg_fare
FROM bookings
WHERE booking_status <> 'cancelled'
GROUP BY flight_id
ORDER BY flight_id;

-- 6.1.2
-- How do the flights rank by number of bookings that were not cancelled?
-- Returns 15 rows. Flights 5, 7 and 12 are tied with 15 bookings each.
-- ROW_NUMBER gives them 4, 5 and 6. It breaks the tie by flight_id.
-- RANK gives all three 4, and the next flight gets 7.
-- DENSE_RANK gives all three 3, and the next flight gets 4.
-- Requirement: ROW_NUMBER, RANK and DENSE_RANK side by side, with at least one tie
SELECT f.flight_id,
       f.flight_number,
       COUNT(b.booking_id) AS non_cancelled_bookings,
       ROW_NUMBER() OVER (
           ORDER BY COUNT(b.booking_id) DESC, f.flight_id
       ) AS leaderboard_row_number,
       RANK() OVER (
           ORDER BY COUNT(b.booking_id) DESC
       ) AS leaderboard_rank,
       DENSE_RANK() OVER (
           ORDER BY COUNT(b.booking_id) DESC
       ) AS leaderboard_dense_rank
FROM flights f
LEFT JOIN bookings b
       ON b.flight_id = f.flight_id
      AND b.booking_status <> 'cancelled'
GROUP BY f.flight_id, f.flight_number
ORDER BY non_cancelled_bookings DESC, f.flight_id;

-- 6.1.3
-- Which of four bands (1 = most bookings, 4 = fewest) does each flight belong to, counting only bookings that were not cancelled?
-- Returns 15 rows. The bands have 4, 4, 4 and 3 flights.
-- Flights 5, 7 and 12 are tied with 15 bookings each, but the line between band 1 and band 2 falls between them.
-- Flight 5 is in band 1. Flights 7 and 12 are in band 2.
-- NTILE does not look at ties. It only counts rows, so tied flights can land in different bands.
-- Requirement: NTILE(4), looking at tied flights on both sides of a boundary
SELECT f.flight_id,
       f.flight_number,
       COUNT(b.booking_id) AS non_cancelled_bookings,
       NTILE(4) OVER (
           ORDER BY COUNT(b.booking_id) DESC, f.flight_id
       ) AS band
FROM flights f
LEFT JOIN bookings b
       ON b.flight_id = f.flight_id
      AND b.booking_status <> 'cancelled'
GROUP BY f.flight_id, f.flight_number
ORDER BY band, non_cancelled_bookings DESC, f.flight_id;
