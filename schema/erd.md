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