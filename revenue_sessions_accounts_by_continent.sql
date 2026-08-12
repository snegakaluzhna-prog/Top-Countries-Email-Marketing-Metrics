-- Step 1: Calculate total revenue and revenue by device for each continent
WITH revenue_cte AS (
  SELECT
    sp.continent,
    SUM(p.price) AS revenue,
    SUM(CASE WHEN sp.device = 'mobile' THEN p.price END) AS revenue_from_mobile,
    SUM(CASE WHEN sp.device = 'desktop' THEN p.price END) AS revenue_from_desktop
  FROM
    `DA.order` o
  JOIN
    `DA.product` p
    ON o.item_id = p.item_id
  JOIN
    `DA.session_params` sp
    ON o.ga_session_id = sp.ga_session_id
  GROUP BY
    sp.continent
),

-- Step 2: Calculate each continent's percentage of total revenue
revenue_with_percentages AS (
  SELECT
    continent,
    revenue,
    revenue_from_mobile,
    revenue_from_desktop,
    revenue / SUM(revenue) OVER () * 100 AS percent_revenue_from_total
  FROM
    revenue_cte
),

-- Step 3: Calculate the number of unique sessions for each continent
sessions_cte AS (
  SELECT
    continent,
    COUNT(DISTINCT ga_session_id) AS session_count
  FROM
    `DA.session_params`
  GROUP BY
    continent
),

-- Step 4: Calculate total and verified accounts for each continent
accounts_cte AS (
  SELECT
    sp.continent,
    COUNT(DISTINCT acs.account_id) AS account_count,
    COUNT(CASE WHEN a.is_verified = 1 THEN acs.account_id END) AS verified_account_count
  FROM
    `data-analytics-mate.DA.account` a
  JOIN
    `data-analytics-mate.DA.account_session` acs
    ON a.id = acs.account_id
  JOIN
    `DA.session_params` sp
    ON acs.ga_session_id = sp.ga_session_id
  GROUP BY
    sp.continent
)

-- Step 5: Combine revenue, session, and account metrics by continent
SELECT
  rwp.continent,
  rwp.revenue,
  rwp.revenue_from_mobile,
  rwp.revenue_from_desktop,
  rwp.percent_revenue_from_total,
  sc.session_count,
  acc.account_count,
  acc.verified_account_count
FROM
  revenue_with_percentages rwp
LEFT JOIN
  sessions_cte sc
  ON rwp.continent = sc.continent
LEFT JOIN
  accounts_cte acc
  ON rwp.continent = acc.continent;
