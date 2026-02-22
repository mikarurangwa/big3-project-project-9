-- =============================================
-- Module 2A
-- =============================================

-- Using nested subqueries
SELECT first_name, last_name, phone
FROM workers
WHERE worker_id IN (
    SELECT worker_id
    FROM worker_skills
    WHERE skill_id = (
        SELECT skill_id FROM skills WHERE skill_name = 'Heavy Equipment Operation'
    )
);

-- using JOINs
SELECT w.first_name, w.last_name, w.phone
FROM workers w
JOIN worker_skills ws ON w.worker_id = ws.worker_id
JOIN skills s ON ws.skill_id = s.skill_id
WHERE s.skill_name = 'Heavy Equipment Operation';


-- =============================================
-- Module 2B
-- =============================================

SELECT p.project_name, worker_counts.worker_count
FROM projects p
JOIN (
    SELECT project_id, COUNT(worker_id) AS worker_count
    FROM project_assignments
    GROUP BY project_id
) AS worker_counts ON p.project_id = worker_counts.project_id
WHERE worker_counts.worker_count = (
    SELECT MAX(worker_count)
    FROM (
        SELECT COUNT(worker_id) AS worker_count
        FROM project_assignments
        GROUP BY project_id
    ) AS totals
);
