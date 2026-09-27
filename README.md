# ex603-airline-bookings-database

## Name
Shane Nycum

## Summary
Flight booking system for an airline to manage customer bookings

## Domain
This system is a PostgreSQL database for manageing flight bookings for an airline. The system is designed for a single airline - NOT an airport servicing multiple airlines.

It allows customers or airline staff to book flights and query information related to the customer bookings and flight statuses. It can answer questions related to:

1. Passenger booking (i.e. which customers have booked a given flight?)

2. Flight schedule adherence (i.e. what is the time difference between the scheduled arrival time and actual arrival time?)

3. Revenue (i.e. how much revenue did a given flight generate?)

4. Flight routes (i.e. which airports have the most flight activity?)

## Entity Relationship Diagram
```mermaid
erDiagram
    passengers {
        INTEGER id PK
        VARCHAR_50 first_name "NOT NULL"
        VARCHAR_75 last_name "NOT NULL"
        VARCHAR_20 phone_number "NOT NULL"
        VARCHAR_254 email "NOT NULL"
    }

    flights {
        INTEGER id PK
        INTEGER flight_number "NOT NULL"
        BOOLEAN is_cancelled "NOT NULL DEFAULT FALSE"
        TIMESTAMP scheduled_departure_time "NOT NULL"
        TIMESTAMP scheduled_arrival_time "NOT NULL"
        TIMESTAMP rescheduled_departure_time
        TIMESTAMP rescheduled_arrival_time
        TIMESTAMP actual_departure_time
        TIMESTAMP actual_arrival_time
    }

    bookings {
        INTEGER id PK
        INTEGER passenger_id FK, UK "NOT NULL, UNIQUE (passenger_id, flight_id)"
        INTEGER flight_id FK, UK "NOT NULL, UNIQUE (passenger_id, flight_id)"
        BOOLEAN is_cancelled "NOT NULL DEFAULT FALSE"
        BOOLEAN has_boarded "NOT NULL DEFAULT FALSE"
        INTEGER num_checked_bags "NOT NULL, DEFAULT 0, CHECK >= 0"
        TIMESTAMP booking_time "NOT NULL"
        NUMERIC fare_paid "NOT NULL, DEFAULT 0, CHECK >= 0"
        NUMERIC fare_refunded "NOT NULL, DEFAULT 0, CHECK >= 0"
    }

    airports {
        INTEGER id PK
        VARCHAR_4 airport_code
        VARCHAR_500 address_line_1 "NOT NULL"
        VARCHAR_500 address_line_2
        VARCHAR_100 locality "NOT NULL"
        VARCHAR_20 postal_code
        VARCHAR_2 country_code "NOT NULL"
        VARCHAR_100 name "NOT NULL"
    }

    flight_routes {
        INTEGER id PK
        INTEGER flight_id FK, UK "NOT NULL, UNIQUE (flight_id, destination_airport_id, departure_airport_id)"
        INTEGER destination_airport_id FK, UK "NOT NULL, UNIQUE (flight_id, destination_airport_id, departure_airport_id)"
        INTEGER departure_airport_id FK, UK "NOT NULL, UNIQUE (flight_id, destination_airport_id, departure_airport_id)"
    }

    passengers ||--o{ bookings : "makes"
    flights ||--o{ bookings : "is booked on"
    flights ||--o{ flight_routes : "has route"
    airports ||--o{ flight_routes : "departs from"
    airports ||--o{ flight_routes : "arrives at"
```

## Schema

- **`passengers`** - One row per customer. Independent entity; referenced by `bookings`.
- **`flights`** - One row per flight. Tracks scheduled, rescheduled, and actual departure/arrival times. Independent entity; referenced by `bookings` and `flight_routes`.
- **`airports`** - One row per airport, with location and indentifying information (such as airport code). Independent entity; referenced twice by `flight_routes` (once as departure, once as destination).
- **`bookings`** - Junction table resolving the many-to-many relationship between `passengers` and `flights`, plus booking-specific facts (cancellation, boarding, bag count, fare paid/refunded).
- **`flight_routes`** - Junction table resolving the many-to-many relationship between `flights` and `airports`, recording each flight's departure and destination airport.

### Design decisions:

- **Surrogate keys.** All five tables use surrogate primary keys. `passengers`, `flights`, and `airports` need them because their natural key candidates (names, flight numbers, airport codes) are either mutable or not guaranteed unique. `bookings` and `flight_routes` would be good candidates to use a natural key for the sake of this project, since they are not referenced by any other tables. However, I opted to use a surrogate primary key in order to try and replicate the best decision for a real-life system. In the real world, these tables would be likely to be referenced or queried in many different places.
- **`ON DELETE NO ACTION`** everywhere. Every foreign key in the schema uses `NO ACTION` rather than `CASCADE`. `bookings` and `flight_routes` rows are historical/financial records that must not disappear just because a passenger, flight, or airport row is later deleted. 
- **`NUMERIC(10,2)` for money.** `fare_paid` and `fare_refunded` use `NUMERIC` rather than floating point, to avoid rounding errors accumulating across financial calculations.
- **CHECK constraints on non-negative values.** `num_checked_bags`, `fare_paid`, and `fare_refunded` all have `CHECK (... >= 0)` constraints, since negative values in any of these columns describe no real-world state.