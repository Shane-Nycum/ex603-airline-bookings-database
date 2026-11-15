## Task 6.1: Compute across a window without collapsing

**1. Write a question that needs each row shown next to its group’s average. Explain why the group average alone (GROUP BY) cannot answer it.**
Which bookings have checked bags heavier than the average for their flight? To answer this question, each booking's `bags_kg` has to sit next to the average `bags_kg` for its flight in the query output, so the two can be compared row by row. GROUP BY gives only one average per flight. The individual bookings are gone, so we can't tell which ones are above average.

**2. Ranking is never neutral: someone is being ordered, and tie handling decides who counts as equal. Name a platform feature that would use your ranking, and explain which of the three functions it should use and why.**
A "most popular flights" list on the airline's website or app, ranked by number of bookings. It should use RANK. Flights with the same number of bookings should share the same place, because neither is more popular than the other. ROW_NUMBER would put one tied flight above the other for no real reason. DENSE_RANK does not skip a place after a tie, so the flight right after the tied flights would show a higher place than it deserves.

## Task 6.2: Compare each row to its neighbors

**1. What would a large delta tell someone about your platform, and what should they do about it?**
A large delta means the fare changed a lot from one booking to the next on the same flight. The data in this database alone will not necessarily show why. The pricing analyst should first check for reasons the change could be expected, like a sale or promotion, a different fare class, a booking made close to departure, or a different booking country. If none of these explains it, the change might be an error, such as a data entry mistake or a pricing bug, and should be investigated further.

**2. Why does a running total answer a question that a plain SUM cannot?**
A plain SUM gives one number for all the rows. A running total gives the total up to each row, in the order you choose, so you can see how it built up. This shows how each row adds to the total, and where the total grew quickly or slowly.

**3. Why did you pick your moving-average window size? A different size tells a different story.**
I used 7 rows: the current row and the 6 before it. That is small enough to show recent changes, but big enough that one large fare does not move the average too much. Some calendar days have no bookings, so they have no row. This means 7 rows might cover more than 7 days. For example, the timespan covered by the 7-row moving average might be up as much as two to three weeks (q6_2.sql, 6.2.B). 

**4. What does a gap mean in your platform: a data quality problem, a real stop in activity, or a side effect of how events were recorded? Each needs a different response. Say which one yours is and how you know.**
A gap means that a flight ostensibly went a long time without a booking. I think this is most likely a real stop in booking activity for that flight, but this database alone cannot fully prove it. At first glance, it does not look like a data quality problem, because the rest of the platform kept getting bookings during the same time (q6_3.sql, 6.3.B.1). Long gaps also show up on several flights, so they seem to be normal for this airline (q6_2.sql, 6.2.C).

I would start by confirming whether it's a real gap in bookings, and no customers were on those flights. An operations team who is close to the flight should be able to confirm. 

If it is a real gap in bookings, then ask the sales, operations, engineering, or other appropriate team to investigate why nobody booked. For example, are customers able to find the flight on the company's website? Is there truly just very little demand for the flight?

If it does turn out to be a data quality problem, then fix the applications responsible for writing data. If it is a side effect of how events are recorded, check where the bookings are being recorded (if anywhere), and potentially make changes to make sure we are capturing all the bookings in this database.

## Task 6.3: Build the reporting patterns

**1. Name the feature in your platform that top-N would power. Explain why three is the right number, rather than one or ten.**
A dashboard for the pricing analysts showing the three highest fares on each flight. One fare could be a one-off, so one is too few. Three shows whether high fares are a pattern, and is short enough to read at a glance. Ten is too many: some flights have fewer than ten bookings, and it's too many to be digestible at a glance.

**2. What would a large month-over-month change mean in your domain, and what should someone do about it? A number nobody acts on is not a metric.**
It means the share of bookings that were cancelled moved a lot from one month to the next. Cancelled bookings are detrimental to the business, and a big change alerts us of something that we need to investigate. 

First, we should determine whether the change is real, or if some bug in the booking system has resulted in bad data. If there's a bug, then fix it. If the change is real, then the business may want to investigate what is driving the change in customer behavior, and act on it.
