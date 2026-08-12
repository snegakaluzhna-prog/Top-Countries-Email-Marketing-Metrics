-- =====================================================
-- STEP 1. Data Structure Analysis and Source Preparation
-- Tables used:
-- account, account_session, session, session_params,
-- email_sent, email_open, email_visit.
-- Identified join keys:
-- account_id, ga_session_id, id_message.
-- =====================================================

-- =====================================================
-- STEP 2. Account Data Collection
-- Calculate the number of unique accounts by:
-- date, country, send interval,
-- verification status, and unsubscribe status.

-- =====================================================

-- =====================================================
-- STEP 3. Email Metrics Calculation
-- Calculate:
-- sent_msg  - sent emails
-- open_msg  - opened emails
-- visit_msg - emails that resulted in visits
-- COUNT(DISTINCT id_message) is used
-- to prevent duplicate counting.
-- =====================================================

-- =====================================================
-- STEP 4. Combine Account Data
-- and Email Metrics Using UNION ALL
-- =====================================================

-- =====================================================
-- STEP 5. Aggregate Metrics After Combining Data
-- Create a unified dataset with all metrics
-- =====================================================

-- =====================================================
-- STEP 6. Calculate Country-Level Totals
-- Using Window Functions
-- =====================================================

-- =====================================================
-- STEP 7. Rank Countries
-- Identify Top Countries by Account Count
-- and Number of Sent Emails
-- =====================================================

-- =====================================================
-- STEP 8. Generate Final Dataset
-- Select Top 10 Countries by Account Count
-- or by Number of Sent Emails
-- =====================================================
