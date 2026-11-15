## Is the cancellation problem getting better or worse?

This memo is written from the lens of being delivered in early 2024. It covers all of our booking data, which runs from January to December 2023.

**The cancellation problem is better than at the start of 2023, but it has not improved since the second quarter.**

| Quarter | Bookings | Cancelled | Cancellation rate |
|---------|----------|-----------|--------------|
| Jan to Mar | 53 | 12 | 22.6% |
| Apr to Jun | 48 | 7 | 14.6% |
| Jul to Sep | 51 | 8 | 15.7% |
| Oct to Dec | 48 | 7 | 14.6% |
| **Grand total, 2023** | **200** | **34** | **17.0%** |

(Quarters: q6_3.sql, 6.3.B.2. Grand total: q4_2.sql, 4.2.B grand total.)

The first quarter was the worst, at 22.6%. Each quarter thereafter, the rate consistently hovered at around 15%.

**Month by month, there is no clear trend.** Each month has only 11 to 21 bookings, so one or two cancellations change the rate a lot. The rate is higher than the month before in 7 of the 11 changes and lower in 4 (q6_3.sql, 6.3.B.1). The year ended with two rises in a row: 11.1% in October, 14.3% in November and 18.8% in December (q6_3.sql, 6.3.B.1). That is worth watching.

**Flights 2, 9 and 11 are the main problem.** Their cancellation rates are 25.0% (flight 2), 28.6% (flight 9) and 31.3% (flight 11), compared with 17.0% for the whole platform (q4_2.sql, 4.2.A and 4.2.B grand total).

## What should the team do next quarter?

The next quarter is the first quarter of 2024.

1. **Review the cancellations on flights 2, 9 and 11 with the operations team.** Start with the cancellation reasons recorded on those bookings. See if they can identify why these flights are contributing an outsized number of cancellations.
2. **Track the cancellation rate every month, and act when it rises two months in a row.** Use about 15% as the starting point, since that is where the rate has been since April (q6_3.sql, 6.3.B.2). The year ended with two rises in a row, so check whether the rate keeps rising in the first months of 2024. If it does, review the cancellations by flight for those months (q4_2.sql, 4.2.A). 
