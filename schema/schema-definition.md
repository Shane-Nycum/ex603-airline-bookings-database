# Airline Bookings Database - Schema Definition

## passengers

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | BIGINT | PK | |
| first_name | VARCHAR(255) | | |
| last_name | VARCHAR(255) | | |
| phone_number | VARCHAR(20) | | |
| email | VARCHAR(255) | | |

## flights

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | BIGINT | PK | |
| flight_number | SMALLINT | | |
| is_cancelled | BOOLEAN | | |
| scheduled_departure_time | TIMESTAMP | | |
| scheduled_arrival_time | TIMESTAMP | | |
| rescheduled_departure_time | TIMESTAMP | | |
| rescheduled_arrival_time | TIMESTAMP | | |
| actual_departure_time | TIMESTAMP | | |
| actual_arrival_time | TIMESTAMP | | |

## bookings

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | BIGINT | PK | |
| passenger_id | BIGINT | FK | passengers.id |
| flight_id | BIGINT | FK | flights.id |
| is_cancelled | BOOLEAN | | |
| has_boarded | BOOLEAN | | |
| num_checked_bags | SMALLINT | | |
| booking_time | TIMESTAMP | | |

## airports

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | BIGINT | PK | |
| airport_code | VARCHAR(4) | | |
| address_line_1 | VARCHAR(500) | | |
| address_line_2 | VARCHAR(500) | | |
| locality | VARCHAR(255) | | |
| postal_code | VARCHAR(20) | | |
| country_code | VARCHAR(2) | | |
| name | VARCHAR(255) | | |

## flight_routes

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| flight_id | BIGINT | PK, FK | flights.id |
| destination_airport_id | INTEGER | PK, FK | airports.id |
| departure_airport_id | INTEGER | PK, FK | airports.id |

## fare_paid

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| booking_id | BIGINT | PK, FK | bookings.id |
| amount_paid | NUMERIC | | | |
| amount_refunded | NUMERIC | | | |
