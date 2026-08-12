-- =====================================================
-- STEP 1. Extract Marketing Cost Data
-- Retrieve paid search costs and aggregate
-- them by year and month.
-- =====================================================
SELECT
    EXTRACT(YEAR FROM sc.date) AS year,
    EXTRACT(MONTH FROM sc.date) AS month,
    SUM(cost) AS cost,
    0 AS revenue
FROM data-analytics-mate.DA.paid_search_cost sc
GROUP BY
    EXTRACT(YEAR FROM sc.date),
    EXTRACT(MONTH FROM sc.date)

UNION ALL

-- =====================================================
-- STEP 2. Extract Revenue Forecast Data
-- Retrieve predicted revenue values and
-- aggregate them by year and month.
-- =====================================================
SELECT
    EXTRACT(YEAR FROM rp.date) AS year,
    EXTRACT(MONTH FROM rp.date) AS month,
    0 AS cost,
    SUM(predict) AS revenue
FROM data-analytics-mate.DA.revenue_predict rp
GROUP BY
    EXTRACT(YEAR FROM rp.date),
    EXTRACT(MONTH FROM rp.date)
