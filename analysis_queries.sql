/*
====================================================================
Project: B2B SaaS Revenue & Funnel Analysis
Author: Rahul Patel
Background: Transitioned from B2B SaaS Sales to Revenue Analytics
Objective: Evaluate funnel efficiency, rep performance, and revenue drivers
Database: PostgreSQL
====================================================================
*/


/*
Business Question 1:
Out of total leads generated, how many move into the deal pipeline?
This measures top-of-funnel efficiency.
*/

SELECT 
    COUNT(DISTINCT d.deal_id) * 100.0 
    / COUNT(DISTINCT l.lead_id) AS lead_to_deal_conversion_pct
FROM leads l
LEFT JOIN deals d 
    ON l.lead_id = d.lead_id;



/*
Business Question 2:
What percentage of active deals are successfully closed?
This measures closing efficiency of the sales team.
*/

SELECT 
    COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END) * 100.0
        / NULLIF(COUNT(*),0) AS deal_to_win_rate
FROM deals;



/*
Business Question 3:
What is the true revenue efficiency from total lead generation?
This reflects overall acquisition effectiveness.
*/

SELECT 
    COUNT(CASE WHEN d.deal_stage = 'Won' THEN 1 END) * 100.0
        / NULLIF(COUNT(DISTINCT l.lead_id),0) AS lead_to_win_rate
FROM leads l
LEFT JOIN deals d
    ON l.lead_id = d.lead_id;



/*
Business Question 4:
Which sales representatives are most efficient vs most impactful?
Efficiency = Win Rate
Impact = Revenue Contribution
*/

SELECT 
    r.rep_name,
    COUNT(CASE WHEN d.deal_stage = 'Won' THEN 1 END) AS wins,
    COUNT(d.deal_id) AS total_deals,
    ROUND(
        COUNT(CASE WHEN d.deal_stage = 'Won' THEN 1 END) * 100.0
        / NULLIF(COUNT(d.deal_id),0),2
    ) AS win_rate
FROM sales_reps r
LEFT JOIN deals d
    ON r.rep_id = d.rep_id
GROUP BY r.rep_name
ORDER BY win_rate DESC;



/*
Business Question 5:
Who drives the highest revenue contribution?
Ranking reps based on total won revenue.
*/

SELECT 
    r.rep_name,
    SUM(CASE WHEN d.deal_stage = 'Won' THEN d.deal_value ELSE 0 END) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(CASE WHEN d.deal_stage = 'Won' THEN d.deal_value ELSE 0 END) DESC
    ) AS revenue_rank
FROM sales_reps r
LEFT JOIN deals d
    ON r.rep_id = d.rep_id
GROUP BY r.rep_name;



/*
Business Question 6:
Which acquisition channel delivers the highest revenue impact?
*/

SELECT 
    l.lead_source,
    COUNT(DISTINCT d.deal_id) AS total_deals,
    COUNT(CASE WHEN d.deal_stage = 'Won' THEN 1 END) AS total_wins,
    ROUND(
        COUNT(CASE WHEN d.deal_stage = 'Won' THEN 1 END) * 100.0
        / NULLIF(COUNT(DISTINCT l.lead_id),0),2
    ) AS lead_to_win_pct
FROM leads l
LEFT JOIN deals d
    ON l.lead_id = d.lead_id
GROUP BY l.lead_source
ORDER BY lead_to_win_pct DESC;



/*
Business Question 7:
What is the average time taken to close a successful deal?
This helps understand sales cycle velocity.
*/

SELECT 
    ROUND(AVG(closed_date - created_date),2) AS avg_sales_cycle_days
FROM deals
WHERE deal_stage = 'Won'
AND closed_date IS NOT NULL;
