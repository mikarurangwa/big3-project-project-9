# Module 4: Stored Procedures — One-Click Tasks

**Module 4 Challenge: Procedure choice**

- `sp_add_worker_with_skill`: Inserts a new worker and links an existing skill inside a transaction. Simplifies HR onboarding to a single call and ensures atomicity.

- `sp_assign_worker_to_project`: Checks for an existing assignment and either returns an error message or inserts a new assignment with `CURDATE()`. Prevents duplicate assignments and provides clear feedback via an OUT parameter.

These procedures centralize multi-step business logic, reduce client-side errors, and make common tasks one-click operations.
