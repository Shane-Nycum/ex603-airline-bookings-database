-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: Airline Bookings
-- Author: Shane Nycum
-- Target: PostgreSQL 14+
-- =================================================================

-- -----------------------------------------------------------------
-- Reset. Reverse creation order, so no dependency blocks a drop.
-- -----------------------------------------------------------------
DROP TABLE IF EXISTS flight_routes CASCADE;
DROP TABLE IF EXISTS bookings      CASCADE;
DROP TABLE IF EXISTS airports      CASCADE;
DROP TABLE IF EXISTS flights       CASCADE;
DROP TABLE IF EXISTS passengers    CASCADE;

-- ----------------------------------------------------------------
-- 1. passengers — first, because it references nothing.
-- ----------------------------------------------------------------
CREATE TABLE passengers (
    id            INTEGER GENERATED ALWAYS AS IDENTITY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(75)  NOT NULL,
    phone_number  VARCHAR(20)  NOT NULL,
    email         VARCHAR(254) NOT NULL,
    CONSTRAINT pk_passengers PRIMARY KEY (id)
);

-- ----------------------------------------------------------------
-- 2. flights — references nothing; independent of passengers/airports.
-- ----------------------------------------------------------------
CREATE TABLE flights (
    id                          INTEGER GENERATED ALWAYS AS IDENTITY,
    flight_number               INTEGER   NOT NULL,
    is_cancelled                BOOLEAN   NOT NULL DEFAULT FALSE,
    scheduled_departure_time    TIMESTAMP NOT NULL,
    scheduled_arrival_time      TIMESTAMP NOT NULL,
    rescheduled_departure_time  TIMESTAMP,
    rescheduled_arrival_time    TIMESTAMP,
    actual_departure_time       TIMESTAMP,
    actual_arrival_time         TIMESTAMP,
    CONSTRAINT pk_flights PRIMARY KEY (id)
);

-- ----------------------------------------------------------------
-- 3. airports — references nothing; independent of passengers/flights.
-- ----------------------------------------------------------------
CREATE TABLE airports (
    id              INTEGER GENERATED ALWAYS AS IDENTITY,
    airport_code    VARCHAR(4),
    address_line_1  VARCHAR(500) NOT NULL,
    address_line_2  VARCHAR(500),
    locality        VARCHAR(100) NOT NULL,
    postal_code     VARCHAR(20),
    country_code    VARCHAR(2)   NOT NULL,
    name            VARCHAR(100) NOT NULL,
    CONSTRAINT pk_airports PRIMARY KEY (id)
);

-- ----------------------------------------------------------------
-- 4. bookings — resolves the M:N between passengers and flights.
--    In a real life flight system, this would likely be referenced in
--    multiple other places, so I opted to use a surrogate primary key.
--    The UNIQUE constraint on (passenger_id, flight_id)
--    enforces the one-booking-per-passenger-per-flight rule
-- ----------------------------------------------------------------
CREATE TABLE bookings (
    id                INTEGER GENERATED ALWAYS AS IDENTITY,
    passenger_id      INTEGER   NOT NULL,
    flight_id         INTEGER   NOT NULL,
    is_cancelled      BOOLEAN   NOT NULL DEFAULT FALSE,
    has_boarded       BOOLEAN   NOT NULL DEFAULT FALSE,
    num_checked_bags  INTEGER   NOT NULL DEFAULT 0,
    booking_time      TIMESTAMP NOT NULL,
    fare_paid         NUMERIC(10,2) NOT NULL DEFAULT 0,
    fare_refunded     NUMERIC(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT pk_bookings PRIMARY KEY (id),
    CONSTRAINT uq_bookings_passenger_flight UNIQUE (passenger_id, flight_id),
    CONSTRAINT fk_bookings_passenger
        FOREIGN KEY (passenger_id) REFERENCES passengers (id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_bookings_flight
        FOREIGN KEY (flight_id) REFERENCES flights (id)
        ON DELETE NO ACTION,
    CONSTRAINT chk_bookings_num_checked_bags_nonneg CHECK (num_checked_bags >= 0),
    CONSTRAINT chk_bookings_fare_paid_nonneg CHECK (fare_paid >= 0),
    CONSTRAINT chk_bookings_fare_refunded_nonneg CHECK (fare_refunded >= 0)
);

-- ----------------------------------------------------------------
-- 5. flight_routes — resolves the M:N between flights and airports.
--    In a real life flight system, this would likely be referenced in
--    multiple other places, so I opted to use a surrogate primary key.
--    The UNIQUE constraint on (flight_id, destination_airport_id, departure_airport_id)
--    enforces the one-route-per-flight rule.
-- ----------------------------------------------------------------
CREATE TABLE flight_routes (
    id                       INTEGER GENERATED ALWAYS AS IDENTITY,
    flight_id                INTEGER NOT NULL,
    destination_airport_id   INTEGER NOT NULL,
    departure_airport_id     INTEGER NOT NULL,
    CONSTRAINT pk_flight_routes PRIMARY KEY (id),
    CONSTRAINT uq_flight_routes_flight_route UNIQUE (flight_id, destination_airport_id, departure_airport_id),
    CONSTRAINT fk_flight_routes_flight
        FOREIGN KEY (flight_id) REFERENCES flights (id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_flight_routes_destination_airport
        FOREIGN KEY (destination_airport_id) REFERENCES airports (id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_flight_routes_departure_airport
        FOREIGN KEY (departure_airport_id) REFERENCES airports (id)
        ON DELETE NO ACTION
);
