-- Which equipment types have the highest failure rates? --

SELECT e.equipment_type, 
		COUNT(*)  AS total_event,
		COUNT(CASE WHEN m.event_type = 'Failure' THEN 1 END) AS failure,
		ROUND(
			100.0 * COUNT(CASE WHEN m.event_type = 'Failure' THEN 1 END) /
			COUNT(*),1) AS failure_rate_pct,
		ROUND(
			AVG(
				CASE WHEN m.event_type = 'Failure' THEN repair_cost_usd ELSE 0 END)
					,2) AS avg_repair_cost
FROM maintenance_logs m
JOIN equipment e ON m.equipment_id = e.equipment_id
GROUP BY e.equipment_type
ORDER BY failure_rate_pct DESC;

-- What is the average job duration by service type and region? --

SELECT 
	r.region_name,
	s.service_type,
	COUNT(s.job_id) AS total_job,
	ROUND(AVG(s.job_duration_days),1)    AS avg_job_duration,
	SUM(s.revenue_usd)                   AS total_rev,
	ROUND(AVG(s.revenue_usd),0)          AS avg_rev_usd
FROM service_jobs s
JOIN wells w ON s.well_id = w.well_id 
JOIN regions r ON r.region_id = w.region_id
GROUP BY r.region_name, s.service_type
ORDER BY r.region_name, total_rev DESC;

-- Which clients generate the most total revenue? --

SELECT 
	c.client_name,
	COUNT(s.job_id)                AS total_job,
	SUM(s.revenue_usd)             AS total_rev,
	ROUND(AVG(s.revenue_usd),0)    AS avg_revenue_usd,
	ROUND(AVG(job_rating),1)       AS avg_job_rating
FROM clients c 
JOIN wells w ON c.client_id = w.client_id
JOIN service_jobs s ON w.well_id = s.well_id
GROUP BY c.client_name
ORDER BY total_rev DESC;

-- What is the mean time between failures per equipment type? --

WITH failure_log AS (
	SELECT 
		m.equipment_id, 
		e.equipment_type,
		m.log_date,
		LEAD(m.log_date) OVER(
							PARTITION BY m.equipment_id ORDER BY m.log_date
							) AS next_failure_date
	FROM maintenance_logs m
	JOIN equipment e ON m.equipment_id = e.equipment_id
	WHERE m.event_type = 'Failure'
	ORDER BY m.equipment_id, m.log_date
),

date_difference AS (
	SELECT *, 
	(next_failure_date - log_date)  AS days_between_failure
	FROM failure_log
	WHERE next_failure_date IS NOT NULL
)

SELECT 
	equipment_id,
	equipment_type,
	ROUND(
		AVG(days_between_failure),1) AS avg_days_between_failure
FROM date_difference
GROUP BY equipment_id, equipment_type
ORDER BY avg_days_between_failure;

-- What is the monthly running total revenue? --

WITH monthly_rev AS (
	SELECT 
		DATE_TRUNC('Month',start_date) AS month,
		SUM(revenue_usd) AS monthly_rev
	FROM service_jobs
	GROUP BY month
	ORDER BY month
),

cum_rev AS (
	SELECT 
		TO_CHAR(month,'Mon YYYY') AS month,
		monthly_rev,
		SUM(monthly_rev) OVER (
						ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
						) AS running_total
	FROM monthly_rev
)

SELECT *
FROM cum_rev;

-- Which technicians have the best performance metrics? --

SELECT 
	s.technician_id,
	t.full_name,
	t.role,
	COUNT(s.job_id) AS total_job,
	ROUND(
		AVG(s.job_duration_days),1) AS avg_job_duration,
	ROUND(
		AVG(s.revenue_usd),1) AS avg_rev,
	ROUND(
		AVG(s.job_rating),1) AS avg_job_rating	
FROM service_jobs s
JOIN technicians t ON s.technician_id = t.technician_id
GROUP BY s.technician_id, t.full_name, t.role
ORDER BY avg_rev DESC;

-- What is equipment utilization rate by region? --

WITH total_equipment AS (
	SELECT 
		COUNT(*) AS total_fleet
	FROM equipment 
	WHERE status != 'Retired'
),

regional_equipment AS (
	SELECT 
		r.region_id,
		r.region_name,
		COUNT(s.job_id) AS total_job,
		COUNT(DISTINCT s.equipment_id) AS equipment_deployed
	FROM regions r
	INNER JOIN wells w
	ON r.region_id = w.region_id
	INNER JOIN service_jobs s
	ON w.well_id = s.well_id
	GROUP BY r.region_id, r.region_name
	ORDER BY region_id
)
	
SELECT 
	*,
	ROUND(
		100.0 * equipment_deployed / total_fleet
	,1) AS utilization_pct
FROM regional_equipment
CROSS JOIN total_equipment 
ORDER BY utilization_pct DESC;

-- What is the month-over-month revenue growth? --

WITH monthly_revenue AS (
	SELECT
		DATE_TRUNC('Month',start_date) As month,
		SUM(revenue_usd) AS monthly_rev
	FROM service_jobs
	GROUP BY month
	ORDER BY month
),
lag AS(
	SELECT 
		*,
		LAG(monthly_rev) OVER(ORDER BY month ASC) AS prev_month_rev
	FROM monthly_revenue
)

SELECT 
	TO_CHAR(month,'Mon YYYY') AS month,
	monthly_rev,
	prev_month_rev,
	CASE 
		WHEN prev_month_rev IS NULL THEN 0
		ELSE monthly_rev - prev_month_rev END AS monthly_growth
FROM lag

-- What are top 3 failure reasons per equipment type? --
SELECT
	*
FROM
	(SELECT 
		e.equipment_type,
		m.failure_reason,
		COUNT(*) AS occurrences,
		RANK() OVER(PARTITION BY equipment_type ORDER BY COUNT(*) DESC) AS reason_rank
	FROM maintenance_logs m
	JOIN equipment e
	ON m.equipment_id = e.equipment_id
	WHERE failure_reason IS NOT NULL
	GROUP BY e.equipment_type, m.failure_reason 
	ORDER BY e.equipment_type) AS sub
WHERE reason_rank <=3;




	