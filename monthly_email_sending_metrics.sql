-- Step 1: Select the month, account ID, email percentage,
-- first sent date, and last sent date
SELECT DISTINCT
    sent_month,
    id_account,
    account_month_count / total_month_count * 100
        AS sent_msg_percent_from_this_month,
    first_sent_date,
    last_sent_date

FROM (

    -- Step 2: Calculate monthly email metrics using window functions
    SELECT
        DATE_TRUNC(date_new, MONTH) AS sent_month,
        id_account,

        -- Step 3: Find the first email sent by the account in each month
        MIN(date_new) OVER (
            PARTITION BY id_account, DATE_TRUNC(date_new, MONTH)
        ) AS first_sent_date,

        -- Step 4: Count emails sent by each account in each month
        COUNT(id_message) OVER (
            PARTITION BY id_account, DATE_TRUNC(date_new, MONTH)
        ) AS account_month_count,

        -- Step 5: Count all emails sent in each month
        COUNT(id_message) OVER (
            PARTITION BY DATE_TRUNC(date_new, MONTH)
        ) AS total_month_count,

        -- Step 6: Find the last email sent by the account in each month
        MAX(date_new) OVER (
            PARTITION BY id_account, DATE_TRUNC(date_new, MONTH)
        ) AS last_sent_date

    FROM (

        -- Step 7: Calculate the actual email sending date
        -- and connect account, email, session, and account-session data
        SELECT
            a.id AS id_account,
            id_message,
            DATE_ADD(
                s.date,
                INTERVAL es.sent_date DAY
            ) AS date_new

        FROM `data-analytics-mate.DA.account` AS a

        -- Step 8: Join accounts with sent emails
        JOIN `data-analytics-mate.DA.email_sent` AS es
            ON a.id = es.id_account

        -- Step 9: Connect accounts with their sessions
        JOIN `data-analytics-mate.DA.account_session` AS acs
            ON a.id = acs.account_id

        -- Step 10: Connect account sessions with session dates
        JOIN `data-analytics-mate.DA.session` AS s
            ON acs.ga_session_id = s.ga_session_id

    ) AS riw1

) AS riw2;
