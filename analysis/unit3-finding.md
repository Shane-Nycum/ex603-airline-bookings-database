The dashboard that is meant to show bookings without a cancelled flight is showing only 27 bookings. There are 200 total bookings (including cancelled flights), of which only 7 have a cancelled flight, so the dashboard should be showing 193 bookings. 

The cause is a broken query that does not properly handle bookings with a blank cancellation reason in the database. Most bookings (166 out of 200) were never cancelled. All of those non-cancelled bookings are omitted from the query's results. 

We fixed the issue by telling the query to keep the bookings with a blank cancellation reason. The corrected query now returns 193 bookings, which is the 200 total minus the 7 cancelled flights. We recommend that the team update the dashboard with our corrected query.
