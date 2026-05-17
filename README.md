This project solves the "Hidden Churn" problem by architecting a three-state subscription model.

The Problem: Standard reporting failed to account for "Pending" revenue and "Future-Dated" churn, leading to inaccurate MRR projections.

The Solution: - 
- Engineered a PostgreSQL View to handle temporal status logic at the source.
- Developed a Defensive DAX Layer to protect against "Divide by Zero" errors.
Created an interactive dashboard for real-time MRR and Churn tracking.

Technical Impact: - 
-Source-Side Logic: Moved complex subscription state classification (Active/Pending/Churned) into a SQL View to ensure a "Single Source of Truth" and reduce BI-layer overhead.
-Defensive DAX Architecture: Implemented fail-safe measures using the DIVIDE function and strict data-type enforcement to prevent NaN/Infinity errors during period-over-period calculations.
