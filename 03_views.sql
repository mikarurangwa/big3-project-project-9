CREATE OR REPLACE VIEW v_project_worker_assignments AS
SELECT p.project_name, p.site_address, w.first_name, w.last_name, w.phone, pa.assignment_date
FROM projects p
JOIN project_assignments pa ON p.project_id = pa.project_id
JOIN workers w ON pa.worker_id = w.worker_id
ORDER BY p.project_name, w.last_name;

CREATE OR REPLACE VIEW v_project_financial_summary AS
SELECT p.project_id, p.project_name, c.client_name, p.budget AS project_budget,
       COALESCE(SUM(pm.total_cost), 0.00) AS total_materials_cost,
       (p.budget - COALESCE(SUM(pm.total_cost), 0.00)) AS remaining_budget
FROM projects p
LEFT JOIN clients c ON p.client_id = c.client_id
LEFT JOIN project_materials pm ON p.project_id = pm.project_id
GROUP BY p.project_id, p.project_name, c.client_name, p.budget;
