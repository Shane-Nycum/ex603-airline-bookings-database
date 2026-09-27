# Constraints and CHECK Rationale

## Constraints Table

| Foreign key | ON DELETE | Reason |
|---|---|---|
| bookings.passenger_id → passengers.id | NO ACTION | We don't want to lose a passenger's booking history just because the passenger record is deleted. |
| bookings.flight_id → flights.id | NO ACTION | We don't want to lose a flight's booking history just because the flight record is deleted. |
| flight_routes.flight_id → flights.id | NO ACTION | We don't want to lose a flight's route record just because the flight is deleted. |
| flight_routes.departure_airport_id → airports.id | NO ACTION | We don't want to lose a route's departure airport just because the airport is deleted. |
| flight_routes.destination_airport_id → airports.id | NO ACTION | We don't want to lose a route's destination airport just because the airport is deleted. |

### bookings.passenger_id → passengers.id

Deleting a passenger shouldn't delete their booking history. I don't believe we would ever want to delete a passenger, but if for some reason we did, we don't want to lose their booking data too. That historical booking data is important for reporting and analysis and we don't want to lose it for any reason.

### bookings.flight_id → flights.id

Same idea for flights: I can't think of a scenario where we would want to delete a flight record. There's an is_cancelled field on it that is set to filter out cancelled flights, if needed. If a flight record is deleted for some reason, we don't want to lose even more data by cascading to its booking history.

### flight_routes.flight_id → flights.id
Similar rationale: There isn't a scenario I can think of where we would want to delete a flight record. It's more likely to happen by mistake than it is to happen on purpose. We don't want to lose even more data if a mistake happens. If there is a legitimate reason to purge flights, this would happen on a one-off basis and can be dealth with in the DELETE query, rather than automatically cascading deletes.


### flight_routes.departure_airport_id → airports.id and flight_routes.destination_airport_id → airports.id

Deleting an airport shouldn't delete every route that used it. CASCADE here could wipe out a lot of unrelated flight history just because one airport record was removed.

## CHECK Constraints

**`chk_bookings_num_checked_bags_nonneg`** — There is no real-world concept of a negative bag count.

**`chk_bookings_fare_paid_nonneg`** — A booking can't have a negative fare paid. A negative value would mean the airline paid the passenger, which isn't what this column means. Refunds are tracked separately in `fare_refunded`.

**`chk_bookings_fare_refunded_nonneg`** — A booking can't have a negative refund amount. That could only happen as a result of a mistake. We will prevent this type of mistake from taking root at the database level.

## Design Notes

A few things changed from the original Unit 1 design while writing the DDL:

- Surrogate keys narrowed from `BIGINT` to `INTEGER`, since `INTEGER`'s range is more than enough for this system.
- `flight_number` and `num_checked_bags` widened from `SMALLINT` to `INTEGER`, to match the course project's type-mapping guidance.
- `bookings` and `flight_routes` each got a surrogate `id` primary key instead of a composite key, since either could be referenced elsewhere later. `UNIQUE` constraints preserve the original one-booking-per-flight and one-route-per-flight rules.
- `VARCHAR(255)` on `first_name`, `last_name`, `email`, `airports.locality`, and `airports.name` were replaced with real bounds instead of an arbitrary default.
- `schema-definition.md`, `erd.md`, and the README's ERD were updated to match.
