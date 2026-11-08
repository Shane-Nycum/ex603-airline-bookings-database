## Task 5.1: Connect producers to their data

**1. What feature or report on your platform could use the three-table join from Question 1? What information would it display?**
A list of bookings for airline customer service staff. When a passenger calls about a booking, the representative needs to see the passenger's name, the flight number, and when the booking was made, all in one place.

**2. Why is the junction table important for answering Question 2? What would make this analysis more difficult without it?**
One flight can use many airports, and one airport is used by many flights. The `flight_routes` table is the only place that bridges their many-to-many relationship. Without it, I would have to store a list of airports inside each flight row, which is painful to parse and search.

## Task 5.2: Find records that joins may exclude

**1. Which producers were excluded by the inner join? Report their identifiers.**
Flights 14 (VN214) and 15 (VN215).

**2. What does it mean when a producer has no events? What are some possible explanations?**
The data shows that nobody has ever booked flights 14 and 15, even though both are marked active. The data alone does not show why. Some possible reasons:
- The flight is new and has not opened for booking yet.
- Some bug in the flight booking system is causing customers not to be able to find the flight.
- The flight was created in the flight booking system by mistake.

Each of these would require investigations beyond of what this database can provide.

**3. How could a report based only on an inner join give leadership an incomplete picture of the platform?**
It would leave out flights 14 and 15. Leadership would see 13 flights instead of 15, and an average like "bookings per flight" would look higher than it really is.

**4. Why might leadership want to identify producers who have never been active?**
Both flights are marked active, but no one has ever booked them. Leadership would want to know why that is, since right now they look available but earn nothing.

**5. What action could leadership take based on these findings?**
First, leadership would need to find out why there are no bookings, by asking the scheduling team and checking the booking system. After that, the action depends on the answer. If the flights are new, open them for booking. If there is a bug in the booking system, have it fixed. If they were created by mistake, mark them inactive or remove them from the database.

## Task 5.3: Understand join performance and execution plans

**1. Give an example of when a Cartesian product could be useful on your platform, or explain why you would not need one.**
Listing every possible flight and airport pairing, to find routes that do not exist yet. This could be used to see which airports a flight could be added to.

**2. Which join algorithms did PostgreSQL choose for your query?**
A hash join (`bookings` with `passengers`) and a nested loop (that result with `flights`).

**3. What information in the execution plan helps explain those choices?**
The plan shows the table sizes and the indexes that were available:
- `Hash Join`: the plan builds a `Hash` of `passengers`, the smaller table, and does a full scan of `bookings` to match against it. This works because a hash join does not need an index, and `bookings` has none on `passenger_id`.
- `Nested Loop`: for each row coming out of the hash join (the outer table), PostgreSQL has to find the matching row in `flights` (the inner table). `Index Scan using flights_pkey` means it does this with an index lookup. `flights_pkey` is the index on `flights.flight_id`, the primary key. So for each booking, it looks up that booking's flight in the index, instead of doing a full scan of `flights`. That makes the Nested Loop a good fit here.

**4. Why is it useful to understand the selected join algorithms?**
If a query is slow, it can be useful in diagnosing why. It can also be useful to understand how a query will scale as more data is added.

**5. What changes to the data or database might make another join algorithm more appropriate?**
If `passengers` grew too big to fit in memory, the hash table would spill to disk and slow down. A merge join could work better then, if both `bookings` and `passengers` had an index on `passenger_id`. Right now `bookings` has none, and the plan does a full scan of it.

## Reflection

The main things that would make PostgreSQL choose a different join algorithm are the size of the tables, the indexes on them, and how many rows a query needs.

Today the tables are small (200 bookings, 30 passengers, 15 flights), so the hash table for `passengers` easily fits in memory. If `passengers` grew to millions of rows, the hash table could spill to disk and slow down, and Postgres might switch to a merge join.

A merge join is cheapest when both sides can be read in order from an index on the join column. Right now `bookings` has no index on `passenger_id` or `flight_id`, so the plan does a full scan of it. `bookings` will grow the fastest and joins to both other tables, so those are the first fields I would index. 

The number of rows a query needs matters too. My query returns every booking, so reading the whole table makes sense. If a query only needed one passenger's bookings, an index on `bookings.passenger_id`  would let PostgreSQL use a nested loop with index lookups instead.

Indexes take up space and slow down inserts, so I would only add the ones that joins actually use.
