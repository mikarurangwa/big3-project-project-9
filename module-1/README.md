**Module 1 Challenge: Index choice**

We created a composite index on (site_city, start_date) because the common access pattern is WHERE site_city = ? and then ORDER BY start_date. Putting site_city first helps the database quickly filter to the city’s subset, and adding start_date next supports sorting within that subset with less work.
