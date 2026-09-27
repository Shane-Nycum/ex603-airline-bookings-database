# Airline Bookings Database - Schema Definition

## passengers

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | INTEGER | PK | |
| first_name | VARCHAR(50) | | |
| last_name | VARCHAR(75) | | |
| phone_number | VARCHAR(20) | | |
| email | VARCHAR(254) | | |

## flights

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | INTEGER | PK | |
| flight_number | INTEGER | | |
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
| id | INTEGER | PK | |
| passenger_id | INTEGER | FK | passengers.id |
| flight_id | INTEGER | FK | flights.id |
| is_cancelled | BOOLEAN | | |
| has_boarded | BOOLEAN | | |
| num_checked_bags | INTEGER | | |
| booking_time | TIMESTAMP | | |
| fare_paid | NUMERIC | | |
| fare_refunded | NUMERIC | | |

## airports

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | INTEGER | PK | |
| airport_code | VARCHAR(4) | | |
| address_line_1 | VARCHAR(500) | | |
| address_line_2 | VARCHAR(500) | | |
| locality | VARCHAR(100) | | |
| postal_code | VARCHAR(20) | | |
| country_code | VARCHAR(2) | | |
| name | VARCHAR(100) | | |

## flight_routes

| Attribute | Type | Key | FK Reference |
|---|---|---|---|
| id | INTEGER | PK | |
| flight_id | INTEGER | FK | flights.id |
| destination_airport_id | INTEGER | FK | airports.id |
| departure_airport_id | INTEGER | FK | airports.id |


