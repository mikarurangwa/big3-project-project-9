-- Before index
EXPLAIN SELECT * FROM workers WHERE last_name = 'Johnson';

CREATE INDEX idx_worker_lastname ON workers(last_name);

-- After index
EXPLAIN SELECT * FROM workers WHERE last_name = 'Johnson';

-- Composite index for city filter + start_date sort
CREATE INDEX idx_projects_city_startdate ON projects(site_city, start_date);
