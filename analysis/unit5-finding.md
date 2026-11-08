## Recommendations

We have two groups of flights to bring to leadership's attention. Some flights are being booked but are cancelled a lot. Others have never been booked at all.

### Flights that are cancelled often: flights 2, 9 and 11

Across all flights, 17.0% of bookings are cancelled (q4_2.sql, 4.2.B grand total). These three are higher: flight 11 is at 31.3%, flight 9 is at 28.6%, and flight 2 is at 25.0% (q4_2.sql, 4.2.A).

What we found when we compared them to other flights (q5_1.sql, 5.1.3):
- Having fewer bookings doesn't explain it. Each has 14 to 16 bookings, which is in the middle of the range for other flights.
- Flights 2 and 11 both come from Japan, but another Japan flight (flight 6) has a lower rate of 19.0%, so the country doesn't explain it.
- Flight 9 is marked inactive, but the data doesn't say when it was marked inactive. It may have happened after the bookings were made, so this doesn't tell us much on its own.

**Recommendation:** Look into why people are cancelling these flights. Review the cancellations on all three with the operations team. For flight 9, also find out when it was marked inactive, and whether the cancellations happened after that.

### Flights that have never been booked: flights 14 and 15

These two flights exist and are marked active, but nobody has ever booked them (q5_2.sql, 5.2.A.1 and 5.2.C.1).

**Recommendation:** First find out why they have no bookings, since our data can't tell us. Ask the scheduling team if these flights are new or were set up by mistake, and ask the customer service and/or engineering team to check that customers can find them on the website. If they are new, open them for booking. If there is a problem in the booking system, get it fixed. If they were a mistake, mark them inactive.