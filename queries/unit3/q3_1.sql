-- 3.1.1 Active flights with large seat capacity
-- the producers whose records anchor the audit. 
-- Requirement: SELECT, WHERE, ORDER BY, LIMIT.
SELECT *
FROM flights
WHERE is_active = TRUE AND seat_capacity >= 180
ORDER BY seat_capacity DESC, flight_id
LIMIT 10;

-- 3.1.2 
-- What are all the possible statuses a booking can have?
-- Observations: I don't notice anything too surprising here.
-- Just three: cancelled, confirmed, and disputed.
-- All of these are legitimate booking statuses.
-- Requirement: DISTINCT
SELECT DISTINCT booking_status
FROM bookings
ORDER BY booking_status;

-- 3.1.3a 
-- Which bookings have a fare paid between $20 and $30?
--    Requirement: BETWEEN
SELECT *
FROM bookings
WHERE fare_paid BETWEEN 20 AND 30
ORDER BY fare_paid DESC, booking_id;

-- 3.1.3b 
-- Which bookings are cancelled or disputed?
-- Requirement: IN 
SELECT *
FROM bookings
WHERE booking_status IN ('cancelled', 'disputed')
ORDER BY booking_id;

-- 3.1.4a 
-- Which flights have a flight number that starts with VN20?
-- Requirement: LIKE
SELECT flight_id, flight_number, origin_country, seat_capacity
FROM flights
WHERE flight_number LIKE 'VN20%'
ORDER BY flight_number;

-- 3.1.4b 
-- Which bookings have no cancellation reason?
-- Requirement: IS NULL, COALESCE
SELECT booking_id, booking_status, COALESCE(cancellation_reason, 'No reason provided') AS cancellation_reason
FROM bookings
WHERE cancellation_reason IS NULL
ORDER BY booking_id;

-- 3.1.5 
-- How big is each flight?
-- Labels every flight as Small, Medium or Large based on its seat capacity.
-- Less than 150 seats is considered Small, 150 to 249 is Medium, 250 or greater is Large.
-- Requirement: CASE, AS
SELECT flight_id,
       flight_number,
       CASE
           WHEN seat_capacity < 150 THEN 'Small'
           WHEN seat_capacity < 250 THEN 'Medium'
           ELSE 'Large'
       END AS flight_size
FROM flights
ORDER BY seat_capacity DESC, flight_id;