**Module 2 Challenge: Query Explanation**

**Goal**: Find the project(s) with the highest number of assigned workers.

This problem has two steps, first count the workers per project, then find which count is the highest. We used two subqueries to handle this: one in the FROM clause to get the worker count per project, and one in the WHERE clause to pull the max of those counts. We then joined back to projects to get the actual project name.

We also liked that this approach handles ties, if two projects have the same number of workers, both show up in the results.
