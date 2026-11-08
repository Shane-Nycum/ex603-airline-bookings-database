-- 5.3.A
-- What does every possible flight and airport pairing look like?
-- There are 5 rows in the airports table and 15 rows in the flights table.
-- Cross joining them returns 75 rows (5 airports x 15 flights).
-- When a Cartesian product is useful: when we want every possible combination.
-- For example, this list could be used as part of a larger query to find routes that don't exist yet.
-- When it could be a mistake: when used on two large tables without a filter, it can create an enormous number of rows unexpectedly.
-- Requirement: CROSS JOIN between two small tables
SELECT f.flight_id,
       f.flight_number,
       a.airport_id,
       a.iata_code
FROM airports a
CROSS JOIN flights f
ORDER BY f.flight_id, a.airport_id;

-- 5.3.B
-- How does PostgreSQL plan to run the three-table join from 5.1.1?
-- The full plan is in the screenshot.
-- Join algorithms used: PostgreSQL joins bookings to passengers with a Hash Join,
-- then joins that result to flights with a Nested Loop.
-- Why it likely chose these:
-- Hash Join for passengers: a hash join builds an in-memory hash table from the smaller table,
-- then reads the larger table and looks each row up in it. passengers is the smaller table,
-- and bookings has no index on passenger_id, so there is no index to use. A hash join doesn't need one.
-- Nested Loop for flights: a nested loop works well when the outer side is small and the inner table
-- has an index on the join column. flights has an index on flight_id (the primary key),
-- so for each booking it can look up the flight directly instead of scanning the whole table.
-- Merge Join was probably not chosen because it works best when both sides are already sorted
-- or indexed on the join column, and bookings isn't.
-- What could get less efficient as the data grows: the Hash Join. The hash table for passengers has to fit in memory.
-- If passengers grew very large, it would spill to disk and slow down.
-- The Nested Loop would also slow down, since it does one flight lookup for every booking row.
-- Reading every row of bookings and sorting the results by passenger_name and flight_number would also take longer.
-- Requirement: EXPLAIN on the three-table join
EXPLAIN
SELECT p.passenger_name,
       f.flight_number,
       b.booked_at
FROM bookings b
INNER JOIN passengers p ON p.passenger_id = b.passenger_id
INNER JOIN flights f ON f.flight_id = b.flight_id
ORDER BY p.passenger_name, f.flight_number;
