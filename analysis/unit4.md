## Task 4.1: Measure the platform

**Who would act on the per-producer breakdown?**
A pricing analyst (or a different job title that performs a similar function). The pricing analyst uses historical trends to build predictive models to forecast how many seats will sell at different price points for each flight.

**What the aggregates hide**

The average fare of 18.14 hides that 34 bookings have a fare of 0.00. These are the cancelled bookings, and they pull the average down.  

**What I would need to see next**

Filtering out cancelled bookings would give you a better idea of the average for bookings that have actually paid a fare.

## Task 4.2: Build the breakdown leadership asked for

### Part A: Two numbers in one pass

This query answers to questions in one pass:

1. How many bookings does each flight have? 
2. How many of those bookings where cancelled? 

### Part B: Subtotals and a grand total

Regional directors/managers need subtotals by region instead of detailed rows. The grand total lets leadership compare one region to the totals for ALL regions, to compare one region against metrics across all regions. This is useful for analyzing performance of each region in comparison to others.

### Part C: A two-step pipeline

The pipeline answers the question: What is the cancellation rate for the busiest flights?

## Reflection

Conditional aggregation answers several questions in one pass over the data. For example, my Part A query counts all bookings and counts the cancelled bookings in the same scan. The other way to get the same answer is to run two filtered queries: one that counts everything, and one with a WHERE clause that counts only the failures. The two queries give the same numbers, but the database has to read the whole table twice.

On a table with 200 rows, the difference in performance is negligible. But at a million rows, it matters a lot. Reading the table from disk is usually the slowest part of a query, so two scans cost about twice as much time and I/O. In some cloud-hosted systems with an on-demand pricing model, such as Google BigQuery (which we use at my workplace), you are billed based on the total amount of bytes read. So the difference is measurable in dollars and cents on every single query. 
