# Airline Bookings Database - Constraints

## passengers

| Attribute | Key | FK Reference | Constraints | Rationale for constraints |
|---|---|---|---|---|
| id | PK |  | Default PK constraints | Default constraints for primary key, such as uniqueness and non-null, are sufficient |
| first_name |  |  | NOT NULL; Character limit: VARCHAR(255) | Required customer information. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| last_name |  |  | NOT NULL; Character limit: VARCHAR(255) | Required customer information. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| phone_number |  |  | NOT NULL; Character limit: VARCHAR(20) | Required customer information. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| email |  |  | NOT NULL; Character limit: VARCHAR(255) | Required customer information. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |

## flights

| Attribute | Key | FK Reference | Constraints | Rationale for constraints |
|---|---|---|---|---|
| id | PK |  | Default PK constraints | Default constraints for primary key, such as uniqueness and non-null, are sufficient |
| flight_number |  |  | NOT NULL | All flights should have a flight number |
| is_cancelled |  |  | NOT NULL DEFAULT FALSE | Flight is not cancelled by default when it's created |
| scheduled_departure_time |  |  | NOT NULL | All flights require an originally scheduled departure time |
| scheduled_arrival_time |  |  | NOT NULL | All flights require an originally scheduled arrival time |
| rescheduled_departure_time |  |  | No constraints | Not all flights have a rescheduled departure time |
| rescheduled_arrival_time |  |  | No constraints | Not all flights have a rescheduled arrival time |
| actual_departure_time |  |  | No constraints | Filled in after the flight has departed |
| actual_arrival_time |  |  | No constraints | Filled in after the flight has landed |


## bookings

| Attribute | Key | FK Reference | Constraints | Rationale for constraints | FK ON DELETE behavior | Rationale for ON DELETE behavior |
|---|---|---|---|---|---|---|
| passenger_id | PK, FK | passengers.id | | | NO ACTION | If a passenger is deleted (I don't think we would ever want to delete a passenger record), we still want to keep a record of the booking |
| flight_id | PK, FK | flights.id | | | NO ACTION | If a flight is deleted (I don't think we would ever want to delete a flight record), we still want to keep a record of the booking |
| is_cancelled |  |  | NOT NULL DEFAULT FALSE | Cancellation happens after a booking is made | | |
| has_boarded |  |  | NOT NULL DEFAULT FALSE | Booking happens before a passenger boards the flight | | |
| num_checked_bags |  |  | NOT NULL, DEFAULT 0, CHECK (num_checked_bags >= 0) | Prevents math errors and enforces consistency by ensuring that each entry is non-null and greater than or equal to 0. If the application was allowed to start putting negative numbers in one day and positive the next, it would be problematic for any calculations using this attribute. | | |
| booking_time |  |  | NOT NULL | Timestamp of when the booking was made. Required for auditing and for aggregating/reporting on booking activity over time. | | |
| fare_paid |  |  | NOT NULL, DEFAULT 0, CHECK (fare_paid >= 0) | Prevents math errors and enforces consistency by ensuring that each entry is non-null and greater than or equal to 0. If the application was allowed to start putting negative numbers in one day and positive the next, it would be problematic for any calculations using this attribute. | | |
| fare_refunded |  |  | NOT NULL, DEFAULT 0, CHECK (fare_refunded >= 0) | Prevents math errors and enforces consistency by ensuring that each entry is non-null and greater than or equal to 0. If the application was allowed to start putting negative numbers in one day and positive the next, it would be problematic for any calculations using this attribute. | | |

## airports

| Attribute | Key | FK Reference | Constraints | Rationale for constraints |
|---|---|---|---|---|
| id | PK |  | Default PK constraints | Default constraints for primary key, such as uniqueness and non-null, are sufficient |
| airport_code |  |  | Character limit: VARCHAR(4) | Example: the 3-character codes used in the US, such as CLT. Not all airports have one, especially small or private airports. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| address_line_1 |  |  | NOT NULL; Character limit: VARCHAR(500) | All airports globally have an address. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| address_line_2 |  |  | Character limit: VARCHAR(500) | Not required for all addresses. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| locality |  |  | NOT NULL; Character limit: VARCHAR(255) | All airports globally have a town, city name, etc. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| postal_code |  |  | Character limit: VARCHAR(20) | Not all airports globally have a postal code. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| country_code |  |  | NOT NULL; Character limit: VARCHAR(2) | All countries have a country code. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |
| name |  |  | NOT NULL; Character limit: VARCHAR(255) | Human-readable long name of the airport, distinct from the airport_code. Character limit enforced to prevent applications accidentally inserting a large amount of bad data and causing the database to balloon in size. |

## flight_routes

| Attribute | Key | FK Reference | Constraints | Rationale for constraints | FK ON DELETE behavior | Rationale for ON DELETE behavior |
|---|---|---|---|---|---|---|
| flight_id | PK, FK | flights.id | | | NO ACTION | If a flight record is deleted for some reason, we don't want to lose a record of the route, for auditability purposes |
| destination_airport_id | PK, FK | airports.id | | | NO ACTION | If an airport is deleted for some reason, we still want to maintain a record of the flight |
| departure_airport_id | PK, FK | airports.id | | | NO ACTION | If an airport is deleted for some reason, we still want to maintain a record of the flight |


