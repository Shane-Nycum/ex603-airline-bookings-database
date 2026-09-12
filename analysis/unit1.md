# Modeling Justification

I designed this database schema to meet the most basic reporting requirements that would be expected from a flight booking system for a commercial airline: on-time performance, cancellation rate, revenue reporting, route traffic analysis, and passenger reachability. A real-life flight booking system would be much more complex, with a much broader scope of requirements than what we could realistically accommodate in this class. This system represents my best effort to balance real-world business expectations with the practical constraints of a classroom setting.

The system considers four types of entities: passengers, flights, bookings and airports. Five tables are used to model the entities and their relationships, described below. 

## Passengers

Passenger information, including name, phone number, and email address, are required. All passenger information fields enforce a non-null constraint, because the airline needs to know the passenger’s name and how to contact them. A unique integer primary key is used for each customer row, rather than a natural key on any of the customer information, due to immutability of an integer key.

## Flights

This table maintains information about a flight: the flight number, cancellation status, and timestamp fields tracking the scheduled departure/arrival times, rescheduled departure/arrival times, and actual departure/arrival times. 

Flight number is the human-readable identifier for a flight, as used by most commercial airlines today. It’s a small int and has a NOT NULL constraint, since human users will typically use this identifier when referring to a flight.

Scheduled arrival and departure have a NOT NULL constraint, since all flights should have a scheduled arrival and departure time upon creation. The other timestamp fields that track the flight are allowed to be null, since a) not all flights will have a rescheduled time and b) actual departure/arrival time will not be known at the time a record is created in the database – only after the flight has happened.

## Bookings

Passengers create bookings (a one-to-many relationship between passengers and bookings). A flight has many bookings (one-to-many relationship between flights and bookings). 

As such, the bookings table has a foreign key attribute for both passenger id and flight id. This pairing (passenger + flight) uniquely identifies a booking, so the primary key can be represented as a composite of the flight ID + passenger ID. Even if a flight or passenger is deleted, we don’t want to cascade the delete to either of these foreign key fields, for auditability and to preserve uniqueness of the composite key. 

Booking-specific information is tracked in this table:

- is_cancelled
- has_boarded
- num_checked_bags
- booking_time
- fare_paid
- fare_refunded

Each of these fields enforces a NOT NULL constraint. Booking time should always be recorded, and a null value would be meaningless and should never be inserted into the remainder of the fields. 

The Boolean fields default to false, as the booking is neither cancelled nor has the customer boarded at the time of booking. 

The numeric fields default to 0 and must be greater than or equal to 0. If an application was allowed to start putting negative numbers in these one day and positive the next, it would be problematic for any metric reporting on these attributes.

## Airports

This table tracks locale information related to each airport. Airport name, address line 1, locality, and country code have a NOT NULL constraint, as all airports globally should have these. 

## Flight-Routes

Junction table supporting the many-to-many relationship between flights and airports. Its only columns are foreign key columns, which form a composite primary key: flight ID, departing airport ID, and destination airport ID.

# Reflection
I've developed applications and queries for relational databases consistently throughout my career. But don’t have a huge amount of experience designing the schema entirely from scratch. I’ve mostly used and extended large, existing system. That said, the basic database mechanics that this unit introduced are nothing new for me. But designing a schema from scratch was a good exercise for me in how to think about modeling relationships. 

I found myself thinking about all the nouns and events and how they relate to each other. I had to understand which noun’s existence depends on another, and which are independent. For example, a booking can’t exist without a passenger and a flight. The bookings table’s mandatory foreign keys for passenger ID and flight ID express that dependency. 

I also had to think about the things that must always be true about those nouns and events, and how to express them as constraints. When constraints are well-grounded in business rules and requirements, they can be critical to prevent bad data and invalid states. When they are not well-grounded in business rules, they can block something that the business may actually need. 
