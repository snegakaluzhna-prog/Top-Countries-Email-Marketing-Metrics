
CREATE VIEW `data-analytics-mate.Students.top_countries_email_metrics` AS (

WITH

-- =====================================================
-- ЕТАП 1. Аналіз структури даних та підготовка джерел
-- Використано таблиці:
-- account, account_session, session, session_params,
-- email_sent, email_open, email_visit.
-- Визначено ключі для об'єднання:
-- account_id, ga_session_id, id_message.
-- =====================================================

-- =====================================================
-- ЕТАП 2. Отримання даних про акаунти
-- Розрахунок кількості унікальних акаунтів за:
-- датою, країною, інтервалом розсилки,
-- статусом верифікації та відписки.
-- =====================================================
account AS (
  SELECT
    s.date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed,
    COUNT(DISTINCT account_id) AS account_cnt
  FROM DA.account ac
  JOIN DA.account_session acs
    ON ac.id = acs.account_id
  JOIN DA.session s
    ON acs.ga_session_id = s.ga_session_id
  JOIN DA.session_params sp
    ON s.ga_session_id = sp.ga_session_id
  GROUP BY
    s.date,
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed
),

-- =====================================================
-- ЕТАП 3. Розрахунок email-метрик
-- Підрахунок:
-- sent_msg  - відправлених листів
-- open_msg  - відкритих листів
-- visit_msg - листів із подальшим переходом
-- Для уникнення дублювання використано
-- COUNT(DISTINCT id_message).
-- =====================================================
email_metrics AS (
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    ac.send_interval,
    sp.country,
    ac.is_verified,
    ac.is_unsubscribed,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM DA.email_sent es
  LEFT JOIN DA.email_open eo
    ON es.id_message = eo.id_message
  LEFT JOIN DA.email_visit ev
    ON es.id_message = ev.id_message
  JOIN DA.account_session acs
    ON acs.account_id = es.id_account
  JOIN DA.session s
    ON acs.ga_session_id = s.ga_session_id
  JOIN DA.session_params sp
    ON acs.ga_session_id = sp.ga_session_id
  JOIN DA.account ac
    ON acs.account_id = ac.id
  GROUP BY
    DATE_ADD(s.date, INTERVAL es.sent_date DAY),
    sp.country,
    ac.send_interval,
    ac.is_verified,
    ac.is_unsubscribed
),

-- =====================================================
-- ЕТАП 4. Об'єднання даних про акаунти
-- та email-метрики через UNION ALL
-- =====================================================
unioned AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM account

  UNION ALL

  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    0 AS account_cnt,
    sent_msg,
    open_msg,
    visit_msg
  FROM email_metrics
),

-- =====================================================
-- ЕТАП 5. Агрегація показників після об'єднання
-- Отримання єдиної таблиці з усіма метриками
-- =====================================================
group_union AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM unioned
  GROUP BY
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed
),

-- =====================================================
-- ЕТАП 6. Розрахунок загальних показників по країнах
-- Використання віконних функцій
-- =====================================================
with_ranks AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    SUM(account_cnt) OVER(PARTITION BY country)
      AS total_country_account_cnt,
    SUM(sent_msg) OVER(PARTITION BY country)
      AS total_country_sent_cnt
  FROM group_union
),

-- =====================================================
-- ЕТАП 7. Ранжування країн
-- Визначення ТОП країн за акаунтами
-- та відправленими листами
-- =====================================================
with_ranks_final AS (
  SELECT
    *,
    DENSE_RANK() OVER(
      ORDER BY total_country_account_cnt DESC
    ) AS rank_total_country_account_cnt,

    DENSE_RANK() OVER(
      ORDER BY total_country_sent_cnt DESC
    ) AS rank_total_country_sent_cnt
  FROM with_ranks
)

-- =====================================================
-- ЕТАП 8. Формування фінальної вибірки
-- Відбір ТОП-10 країн за акаунтами
-- або за кількістю відправлених листів
-- =====================================================
SELECT *
FROM with_ranks_final
WHERE rank_total_country_account_cnt <= 10
   OR rank_total_country_sent_cnt <= 10

);





