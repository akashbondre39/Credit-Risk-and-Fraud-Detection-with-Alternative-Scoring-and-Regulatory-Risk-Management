-- 1. Customers
CREATE TABLE customers (
    customer_id         VARCHAR(10) PRIMARY KEY,   -- e.g., CUST000001
    first_name          VARCHAR(50) NOT NULL,
    last_name           VARCHAR(50) NOT NULL,
    date_of_birth       DATE NOT NULL,
    email               VARCHAR(100) UNIQUE NOT NULL,
    phone               VARCHAR(20),
    address             TEXT,
    employment_status   VARCHAR(50),
    occupation_industry VARCHAR(50),
    monthly_income      NUMERIC(12,2),
    credit_score        NUMERIC(3,0),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Customer Transactions
CREATE TABLE customer_transactions (
    transaction_id      VARCHAR(10) PRIMARY KEY,   -- e.g., TXN000001
    customer_id         VARCHAR(10) NOT NULL,
    transaction_date    TIMESTAMP NOT NULL,
    amount              NUMERIC(12,2),
    transaction_type    VARCHAR(20),
    category            VARCHAR(50),
    description         TEXT,
    CONSTRAINT fk_transactions_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 3. Alternative Credit Data
CREATE TABLE alternative_credit_data (
    alt_credit_id       VARCHAR(10) PRIMARY KEY,   -- e.g., ALT000001
    customer_id         VARCHAR(10) NOT NULL,
    source_type         VARCHAR(50),
    payment_date        DATE,
    amount_paid         NUMERIC(12,2),
    payment_status      VARCHAR(20),
    payment_frequency   VARCHAR(20),
    payment_due_date    DATE,
    days_delayed        INT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alt_credit_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Loans
CREATE TABLE loans (
    loan_id                VARCHAR(10) PRIMARY KEY,   -- e.g., LOAN000001
    customer_id            VARCHAR(10) NOT NULL,
    bank_id                VARCHAR(10) NOT NULL,
    loan_application_date  DATE,
    loan_amount            NUMERIC(12,2),
    interest_rate          NUMERIC(5,2),
    tenure_months          INT,
    loan_type              VARCHAR(50),
    purpose                VARCHAR(100),
    current_outstanding    NUMERIC(12,2),
    collateral_value       NUMERIC(12,2),
    repayment_start_date   DATE,
    repayment_end_date     DATE,
    default_flag           BOOLEAN DEFAULT FALSE,
    priority_sector        BOOLEAN DEFAULT FALSE,
    psl_category           VARCHAR(50),
    psl_sub_target         BOOLEAN DEFAULT FALSE,
    psl_special_terms      TEXT,
    created_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loans_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 5. Loan Applications
CREATE TABLE loan_applications (
    application_id     VARCHAR(10) PRIMARY KEY,   -- e.g., APP000001
    customer_id        VARCHAR(10) NOT NULL,
    application_date   DATE,
    requested_amount   NUMERIC(12,2),
    source_type        VARCHAR(50),
    status             VARCHAR(20),
    comments           TEXT,
    is_psl             BOOLEAN DEFAULT FALSE,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_applications_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 6. Bank Financials
CREATE TABLE bank_financials (
    bank_id                VARCHAR(10) NOT NULL,  -- e.g., BNK00077
    financial_year         VARCHAR(4) NOT NULL,
    bank_name              VARCHAR(100) NOT NULL,
    total_assets           NUMERIC(20,2),
    total_liabilities      NUMERIC(20,2),
    risk_weighted_assets   NUMERIC(20,2),
    tier_1_capital         NUMERIC(20,2),
    tier_2_capital         NUMERIC(20,2),
    total_exposures        NUMERIC(20,2),
    capital_adequacy_ratio NUMERIC(5,2),
    loan_deposit_ratio     NUMERIC(5,2),
    npa_ratio              NUMERIC(5,2),
    created_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bank_id, financial_year)
);

-- 7. Liquidity Metrics
CREATE TABLE liquidity_metrics (
    bank_id                        VARCHAR(10) NOT NULL,
    financial_year                 VARCHAR(4) NOT NULL,
    high_quality_liquid_assets     NUMERIC(20,2),
    cash_outflows_30d              NUMERIC(20,2),
    liquidity_coverage_ratio       NUMERIC(5,2),
    reporting_date                 DATE,
    PRIMARY KEY (bank_id, financial_year, reporting_date),
    CONSTRAINT fk_liquidity_bank
        FOREIGN KEY (bank_id, financial_year) REFERENCES bank_financials(bank_id, financial_year)
);

-- 8. Fraudulent Transactions
CREATE TABLE fraudulent_transactions (
    fraud_id            VARCHAR(10) PRIMARY KEY,
    transaction_id      VARCHAR(10),
    customer_id         VARCHAR(10) NOT NULL,
    bank_id             VARCHAR(10),
    amount              NUMERIC(12,2),
    location            VARCHAR(100),
    ip_address          INET,
    device_id           VARCHAR(50),
    timestamp           TIMESTAMP,
    fraud_type          VARCHAR(50),
    resolution_status   VARCHAR(20),
    fraud_flag          BOOLEAN DEFAULT TRUE,
    notes               TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fraud_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 9. Login Biometrics
CREATE TABLE login_biometrics (
    biometrics_id       VARCHAR(10) PRIMARY KEY,
    customer_id         VARCHAR(10) NOT NULL,
    login_timestamp     TIMESTAMP,
    biometric_hash      VARCHAR(256),
    device_id           VARCHAR(50),
    ip_address          INET,
    location            VARCHAR(100),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_biometrics_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 10. Credit Limit Recommendations
CREATE TABLE credit_limit_recommendations (
    recommendation_id   VARCHAR(10) PRIMARY KEY,
    customer_id         VARCHAR(10) NOT NULL,
    current_credit_limit NUMERIC(12,2),
    recommended_limit   NUMERIC(12,2),
    rationale           TEXT,
    calculated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recommendations_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 11. Risk Signals
CREATE TABLE risk_signals (
    signal_id           VARCHAR(10) PRIMARY KEY,
    customer_id         VARCHAR(10) NOT NULL,
    loan_id             VARCHAR(10) NOT NULL,
    signal_type         VARCHAR(50),
    severity            VARCHAR(20),
    description         TEXT,
    detected_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_risk_signals_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_risk_signals_loan
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- 12. Priority Sector Loans
CREATE TABLE priority_sector_loans (
    priority_loan_id    VARCHAR(10) PRIMARY KEY,
    loan_id             VARCHAR(10) NOT NULL,
    sector              VARCHAR(50),
    special_terms       TEXT,
    compliance_status   VARCHAR(20),
    reviewed_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_priority_loan
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- 13. PSL Metrics
CREATE TABLE psl_metrics (
    bank_id                VARCHAR(10) NOT NULL,
    financial_year         VARCHAR(4) NOT NULL,
    reporting_date         DATE NOT NULL,
    total_credit_exposure  NUMERIC(20,2),
    psl_exposure           NUMERIC(20,2),
    psl_target             NUMERIC(5,2),
    compliance_status      VARCHAR(20),
    created_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bank_id, financial_year, reporting_date),
    CONSTRAINT fk_psl_metrics_bank
        FOREIGN KEY (bank_id, financial_year) REFERENCES bank_financials(bank_id, financial_year)
);





--1. Alternative Credit Scoring for Thin-File Customers
WITH customer_base AS (
    SELECT c.customer_id,
           c.credit_score,
           c.monthly_income,
           c.employment_status,
           c.occupation_industry
    FROM customers c
    WHERE c.credit_score < 650 OR c.credit_score IS NULL
),

-- Transaction Behavior Analysis
transaction_metrics AS (
    SELECT 
        ct.customer_id,
        COUNT(*) as total_transactions,
        AVG(ct.amount) as avg_transaction_amount,
        STDDEV(ct.amount) as transaction_amount_volatility,
        SUM(CASE WHEN ct.amount < 0 THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) as negative_transaction_ratio,
        COUNT(DISTINCT DATE_TRUNC('month', ct.transaction_date)) as active_months,
        SUM(CASE WHEN ct.amount > 0 THEN ct.amount ELSE 0 END) as total_inflow,
        SUM(CASE WHEN ct.amount < 0 THEN ABS(ct.amount) ELSE 0 END) as total_outflow
    FROM customer_transactions ct
    WHERE ct.transaction_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY ct.customer_id
),

-- Alternative Credit Payment History
alt_credit_analysis AS (
    SELECT 
        customer_id,
        COUNT(*) as total_payments,
        AVG(CASE WHEN days_delayed > 0 THEN days_delayed ELSE 0 END) as avg_delay,
        SUM(CASE WHEN payment_status = 'On Time' THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) as on_time_payment_ratio,
        COUNT(DISTINCT source_type) as diverse_payment_sources,
        SUM(amount_paid) as total_amount_paid
    FROM alternative_credit_data
    WHERE payment_date >= CURRENT_DATE - INTERVAL '24 months'
    GROUP BY customer_id
),

-- Final Score Calculation with Rebalanced Weights
score_components AS (
    SELECT 
        cb.customer_id,
        
        -- Income Stability (0-300 points) - Increased weight
        CASE
            WHEN cb.employment_status = 'Employed' THEN LEAST(300, (COALESCE(cb.monthly_income, 0) / 1000) * 15)
            WHEN cb.employment_status = 'Self-Employed' THEN LEAST(270, (COALESCE(cb.monthly_income, 0) / 1000) * 13.5)
            WHEN cb.employment_status = 'Unemployed' THEN LEAST(150, (COALESCE(cb.monthly_income, 0) / 1000) * 7.5)
            ELSE LEAST(75, (COALESCE(cb.monthly_income, 0) / 1000) * 3.75)
        END as income_score,
        
        -- Transaction Pattern Score (0-250 points) - Increased weight
        LEAST(250, 
            COALESCE(tm.total_transactions * 2.5, 0) +
            COALESCE((tm.total_inflow / NULLIF(tm.total_outflow, 0)) * 62.5, 0) +
            COALESCE(tm.active_months * 12.5, 0)
        ) as transaction_score,
        
        -- Alternative Credit Score (0-250 points) - Maintained weight
        LEAST(250,
            COALESCE(ac.on_time_payment_ratio * 100, 0) +
            COALESCE(ac.diverse_payment_sources * 30, 0) +
            COALESCE((1 - LEAST(ac.avg_delay / 30, 1)) * 100, 0)
        ) as alt_credit_score
        
    FROM customer_base cb
    LEFT JOIN transaction_metrics tm ON cb.customer_id = tm.customer_id
    LEFT JOIN alt_credit_analysis ac ON cb.customer_id = ac.customer_id
)

-- Final Alternative Credit Score Calculation and Risk Category Assignment
SELECT 
    sc.customer_id,
    cb.employment_status,
    cb.occupation_industry,
    cb.monthly_income,
    cb.credit_score as traditional_credit_score,
    
    -- Component Scores
    sc.income_score,
    sc.transaction_score,
    sc.alt_credit_score,
    
    -- Total Alternative Score (0-800)
    GREATEST(0, 
        sc.income_score + 
        sc.transaction_score + 
        sc.alt_credit_score
    ) as Total_alternative_credit_score,
    
    -- Risk Category (Adjusted thresholds for 800 max score)
    CASE 
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 600 THEN 'Prime'
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 500 THEN 'Near Prime'
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 400 THEN 'Subprime'
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 350 THEN 'High Risk'
        ELSE 'Very High Risk'
    END as risk_category,
    
    -- Adjusted Credit Limit Based on New Score Range
    CASE 
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 600 
        THEN LEAST(COALESCE(cb.monthly_income, 0) * 3, 100000)
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 500 
        THEN LEAST(COALESCE(cb.monthly_income, 0) * 2, 50000)
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 400 
        THEN LEAST(COALESCE(cb.monthly_income, 0) * 1, 25000)
        WHEN (sc.income_score + sc.transaction_score + sc.alt_credit_score) >= 350 
        THEN LEAST(COALESCE(cb.monthly_income, 0) * 0.5, 10000)
        ELSE LEAST(COALESCE(cb.monthly_income, 0) * 0.25, 5000)
    END as recommended_credit_limit

FROM score_components sc
JOIN customer_base cb ON sc.customer_id = cb.customer_id
ORDER BY (sc.income_score + sc.transaction_score + sc.alt_credit_score) DESC;




--2.Loan Stacking Analysis

-- 1. Active Loan Summary Per Customer
WITH ActiveLoans AS (
    SELECT 
        customer_id,
        COUNT(*) as active_loan_count,
        SUM(current_outstanding) as total_outstanding_debt,
        SUM(loan_amount) as total_loan_amount,
        STRING_AGG(loan_type, ', ') as loan_types,
        MAX(loan_application_date) as most_recent_loan_date,
        MIN(loan_application_date) as first_loan_date
    FROM loans 
    WHERE current_outstanding > 0 
        AND default_flag = FALSE
    GROUP BY customer_id
),

-- 2. Monthly Debt Service Ratio
MonthlyObligations AS (
    SELECT 
        l.customer_id,
        SUM(l.loan_amount / l.tenure_months + (l.loan_amount * l.interest_rate / 1200)) as monthly_obligation
    FROM loans l
    WHERE l.current_outstanding > 0 
        AND l.default_flag = FALSE
    GROUP BY l.customer_id
),

-- 3. Recent Loan Applications (Last 30 Days)
RecentApplications AS (
    SELECT 
        customer_id,
        COUNT(*) as recent_applications,
        SUM(requested_amount) as total_requested_amount
    FROM loan_applications
    WHERE application_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY customer_id
),

-- 4. Risk Signals Analysis
RiskMetrics AS (
    SELECT 
        rs.customer_id,
        COUNT(*) as total_risk_signals,
        COUNT(CASE WHEN rs.severity = 'HIGH' THEN 1 END) as high_severity_signals,
        MAX(rs.detected_at) as latest_risk_signal
    FROM risk_signals rs
    WHERE rs.detected_at >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY rs.customer_id
),

-- 5. Alternative Credit Performance
AltCreditMetrics AS (
    SELECT 
        customer_id,
        AVG(CASE WHEN days_delayed > 0 THEN days_delayed ELSE 0 END) as avg_payment_delay,
        COUNT(CASE WHEN days_delayed > 30 THEN 1 END) as delayed_payments_30plus,
        SUM(amount_paid) as total_alt_credit_payments
    FROM alternative_credit_data
    WHERE payment_date >= CURRENT_DATE - INTERVAL '180 days'
    GROUP BY customer_id
),

-- 6. Transaction Behavior Analysis
TransactionMetrics AS (
    SELECT 
        customer_id,
        COUNT(*) as transaction_count,
        SUM(amount) as total_transaction_amount,
        AVG(amount) as avg_transaction_amount
    FROM customer_transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY customer_id
),

-- 7. Main Analysis CTE
MainAnalysis AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        c.credit_score,
        c.monthly_income,
        
        -- Loan Portfolio Metrics
        COALESCE(al.active_loan_count, 0) as active_loans,
        COALESCE(al.total_outstanding_debt, 0) as total_debt,
        COALESCE(al.total_loan_amount, 0) as total_borrowed,
        al.loan_types,
        
        -- Income and Debt Metrics
        ROUND(COALESCE(mo.monthly_obligation, 0), 2) as monthly_debt_obligation,
        CASE 
            WHEN c.monthly_income > 0 THEN 
                ROUND((COALESCE(mo.monthly_obligation, 0) / c.monthly_income * 100), 2)
            ELSE NULL 
        END as debt_to_income_ratio,
        
        -- Recent Activity
        COALESCE(ra.recent_applications, 0) as applications_last_30d,
        COALESCE(ra.total_requested_amount, 0) as amount_requested_30d,
        
        -- Risk Indicators
        COALESCE(rm.total_risk_signals, 0) as risk_signals_90d,
        COALESCE(rm.high_severity_signals, 0) as high_severity_signals,
        
        -- Alternative Credit Performance
        ROUND(COALESCE(acm.avg_payment_delay, 0), 1) as avg_payment_delay_days,
        COALESCE(acm.delayed_payments_30plus, 0) as payments_30plus_days_late,
        
        -- Transaction Behavior
        COALESCE(tm.transaction_count, 0) as transactions_90d,
        ROUND(COALESCE(tm.avg_transaction_amount, 0), 2) as avg_transaction_amount,
        
        -- Loan Velocity
        CASE 
            WHEN al.active_loan_count > 1 THEN 
                EXTRACT(EPOCH FROM (al.most_recent_loan_date::timestamp - al.first_loan_date::timestamp)) / 86400 / 
                (al.active_loan_count - 1)
            ELSE NULL 
        END as avg_days_between_loans,
        
        -- Risk Score Calculation
        ROUND((
            -- Base score from credit score (0-40 points)
            LEAST(c.credit_score / 850 * 40, 40) +
            
            -- Debt-to-income penalty (0-20 points)
            CASE 
                WHEN (mo.monthly_obligation / NULLIF(c.monthly_income, 0)) <= 0.3 THEN 20
                WHEN (mo.monthly_obligation / NULLIF(c.monthly_income, 0)) <= 0.4 THEN 15
                WHEN (mo.monthly_obligation / NULLIF(c.monthly_income, 0)) <= 0.5 THEN 10
                WHEN (mo.monthly_obligation / NULLIF(c.monthly_income, 0)) <= 0.6 THEN 5
                ELSE 0
            END -
            
            -- Loan stacking penalty (0-20 points)
            (LEAST(al.active_loan_count, 4) * 5) -
            
            -- Recent applications penalty (0-10 points)
            (LEAST(ra.recent_applications, 2) * 5) -
            
            -- Risk signals penalty (0-10 points)
            (LEAST(rm.high_severity_signals, 2) * 5)
        ), 2) as stacking_risk_score,
        
        -- Risk Classification
        CASE 
            WHEN al.active_loan_count >= 3 OR 
                 (mo.monthly_obligation / NULLIF(c.monthly_income, 0)) > 0.6 OR
                 rm.high_severity_signals >= 2 THEN 'HIGH_RISK'
            WHEN al.active_loan_count = 2 OR 
                 (mo.monthly_obligation / NULLIF(c.monthly_income, 0)) > 0.4 OR
                 rm.high_severity_signals = 1 THEN 'MEDIUM_RISK'
            ELSE 'LOW_RISK'
        END as risk_classification

    FROM customers c
    LEFT JOIN ActiveLoans al ON c.customer_id = al.customer_id
    LEFT JOIN MonthlyObligations mo ON c.customer_id = mo.customer_id
    LEFT JOIN RecentApplications ra ON c.customer_id = ra.customer_id
    LEFT JOIN RiskMetrics rm ON c.customer_id = rm.customer_id
    LEFT JOIN AltCreditMetrics acm ON c.customer_id = acm.customer_id
    LEFT JOIN TransactionMetrics tm ON c.customer_id = tm.customer_id

    WHERE COALESCE(al.active_loan_count, 0) > 0 
       OR COALESCE(ra.recent_applications, 0) > 0
)

-- Final Select with Ordering
SELECT *
FROM MainAnalysis
ORDER BY 
    CASE 
        WHEN risk_classification = 'HIGH_RISK' THEN 1
        WHEN risk_classification = 'MEDIUM_RISK' THEN 2
        ELSE 3
    END,
    active_loans DESC;





-- 3. Dynamic Credit Limit Analysis System


-- i. Create a comprehensive view of customer financial health
CREATE OR REPLACE VIEW customer_financial_health AS
WITH transaction_metrics AS (
    SELECT 
        customer_id,
        COUNT(*) as total_transactions,
        SUM(amount) as total_transaction_amount,
        AVG(amount) as avg_transaction_amount,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) as transaction_75th_percentile,
        STDDEV(amount) as transaction_volatility
    FROM customer_transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY customer_id
),
alternative_credit_metrics AS (
    SELECT 
        customer_id,
        COUNT(*) as total_alt_payments,
        AVG(amount_paid) as avg_payment_amount,
        AVG(CASE WHEN days_delayed > 0 THEN 1 ELSE 0 END) as delayed_payment_ratio,
        MAX(days_delayed) as max_delay
    FROM alternative_credit_data
    WHERE payment_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY customer_id
),
loan_performance AS (
    SELECT 
        customer_id,
        COUNT(*) as total_loans,
        SUM(CASE WHEN default_flag THEN 1 ELSE 0 END) as defaults,
        AVG(interest_rate) as avg_interest_rate,
        SUM(current_outstanding) as total_outstanding,
        SUM(loan_amount) as total_loan_amount
    FROM loans
    WHERE loan_application_date >= CURRENT_DATE - INTERVAL '24 months'
    GROUP BY customer_id
),
risk_assessment AS (
    SELECT 
        rs.customer_id,
        COUNT(*) as total_risk_signals,
        SUM(CASE WHEN severity = 'HIGH' THEN 1 ELSE 0 END) as high_severity_signals,
        MAX(detected_at) as latest_risk_signal
    FROM risk_signals rs
    WHERE detected_at >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY rs.customer_id
)
SELECT 
    c.customer_id,
    c.credit_score,
    c.monthly_income,
    tm.total_transactions,
    tm.total_transaction_amount,
    tm.avg_transaction_amount,
    tm.transaction_volatility,
    acm.total_alt_payments,
    acm.delayed_payment_ratio,
    acm.max_delay,
    lp.total_loans,
    lp.defaults,
    lp.avg_interest_rate,
    lp.total_outstanding,
    lp.total_loan_amount,
    ra.total_risk_signals,
    ra.high_severity_signals,
    CASE 
        WHEN ra.latest_risk_signal IS NOT NULL 
        THEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - ra.latest_risk_signal))
        ELSE NULL 
    END as days_since_last_risk_signal
FROM customers c
LEFT JOIN transaction_metrics tm ON c.customer_id = tm.customer_id
LEFT JOIN alternative_credit_metrics acm ON c.customer_id = acm.customer_id
LEFT JOIN loan_performance lp ON c.customer_id = lp.customer_id
LEFT JOIN risk_assessment ra ON c.customer_id = ra.customer_id;

-- ii. Create a credit limit scoring function
CREATE OR REPLACE FUNCTION calculate_credit_limit_score(
    credit_score numeric,
    monthly_income numeric,
    transaction_volume numeric,
    delayed_payment_ratio numeric,
    defaults numeric,
    risk_signals numeric,
    total_outstanding numeric
) RETURNS numeric AS $$
BEGIN
    RETURN (
        -- Base score from credit score (30% weight)
        (LEAST(credit_score, 850) / 850 * 30) +
        
        -- Income factor (25% weight)
        (LEAST(monthly_income / 10000, 1) * 25) +
        
        -- Transaction history (15% weight)
        (LEAST(transaction_volume / 50000, 1) * 15) +
        
        -- Payment behavior (10% weight)
        ((1 - COALESCE(delayed_payment_ratio, 0)) * 10) +
        
        -- Loan performance (10% weight)
        ((1 - LEAST(COALESCE(defaults, 0), 1)) * 10) +
        
        -- Risk assessment (10% weight)
        ((1 - LEAST(COALESCE(risk_signals, 0) / 5, 1)) * 10)
    ) * 
    -- Debt burden adjustment factor
    CASE 
        WHEN total_outstanding > monthly_income * 12 THEN 0.5
        WHEN total_outstanding > monthly_income * 6 THEN 0.7
        WHEN total_outstanding > monthly_income * 3 THEN 0.85
        ELSE 1
    END;
END;
$$ LANGUAGE plpgsql;

-- iii. Create dynamic credit limit recommendations
CREATE OR REPLACE PROCEDURE generate_credit_limit_recommendations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_record RECORD;
    v_credit_score numeric;
    v_base_multiplier numeric;
    v_risk_adjustment numeric;
    v_final_limit numeric;
    v_rationale text;
BEGIN
    -- Process each customer
    FOR v_customer_record IN 
        SELECT * FROM customer_financial_health
    LOOP
        -- Calculate credit score
        v_credit_score := calculate_credit_limit_score(
            v_customer_record.credit_score,
            v_customer_record.monthly_income,
            v_customer_record.total_transaction_amount,
            v_customer_record.delayed_payment_ratio,
            v_customer_record.defaults,
            v_customer_record.high_severity_signals,
            v_customer_record.total_outstanding
        );

        -- Calculate base multiplier (0.5 to 4 times monthly income)
        v_base_multiplier := GREATEST(0.5, LEAST(4, v_credit_score / 25));

        -- Apply risk adjustments
        v_risk_adjustment := CASE
            WHEN v_customer_record.high_severity_signals > 0 THEN 0.5
            WHEN v_customer_record.defaults > 0 THEN 0.7
            WHEN v_customer_record.delayed_payment_ratio > 0.1 THEN 0.85
            ELSE 1
        END;

        -- Calculate final recommended limit
        v_final_limit := ROUND(
            v_customer_record.monthly_income * 
            v_base_multiplier * 
            v_risk_adjustment, -2
        );

        -- Generate rationale
        v_rationale := FORMAT(
            'Credit score: %s. Base multiplier: %s. Risk adjustment: %s. ' ||
            'Factors considered: %s transactions, %s risk signals, ' ||
            'payment delay ratio: %s, outstanding debt ratio: %s',
            v_credit_score,
            v_base_multiplier,
            v_risk_adjustment,
            v_customer_record.total_transactions,
            v_customer_record.high_severity_signals,
            v_customer_record.delayed_payment_ratio,
            ROUND(v_customer_record.total_outstanding / 
                  NULLIF(v_customer_record.monthly_income, 0), 2)
        );

        -- Insert or update recommendation
        INSERT INTO credit_limit_recommendations (
            recommendation_id,
            customer_id,
            current_credit_limit,
            recommended_limit,
            rationale,
            calculated_at
        )
        VALUES (
            'REC' || LPAD(NEXTVAL('recommendation_seq')::TEXT, 6, '0'),
            v_customer_record.customer_id,
            v_customer_record.total_outstanding,
            v_final_limit,
            v_rationale,
            CURRENT_TIMESTAMP
        )
        ON CONFLICT (recommendation_id) 
        DO UPDATE SET
            recommended_limit = EXCLUDED.recommended_limit,
            rationale = EXCLUDED.rationale,
            calculated_at = CURRENT_TIMESTAMP;
    END LOOP;
END;
$$;

-- iv. Create monitoring triggers for real-time updates
CREATE OR REPLACE FUNCTION trigger_credit_limit_review()
RETURNS TRIGGER AS $$
BEGIN
    -- Queue customer for credit limit review based on significant events
    IF (TG_TABLE_NAME = 'risk_signals' AND NEW.severity = 'HIGH') OR
       (TG_TABLE_NAME = 'loans' AND NEW.default_flag = TRUE) OR
       (TG_TABLE_NAME = 'alternative_credit_data' AND NEW.days_delayed > 30)
    THEN
        -- Insert into a queue table for batch processing
        INSERT INTO credit_limit_review_queue (
            customer_id,
            trigger_source,
            trigger_reason,
            created_at
        )
        VALUES (
            NEW.customer_id,
            TG_TABLE_NAME,
            CASE 
                WHEN TG_TABLE_NAME = 'risk_signals' THEN 'High severity risk signal detected'
                WHEN TG_TABLE_NAME = 'loans' THEN 'Loan default recorded'
                WHEN TG_TABLE_NAME = 'alternative_credit_data' THEN 'Significant payment delay'
            END,
            CURRENT_TIMESTAMP
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for real-time monitoring
CREATE TRIGGER monitor_risk_signals
AFTER INSERT ON risk_signals
FOR EACH ROW
EXECUTE FUNCTION trigger_credit_limit_review();

CREATE TRIGGER monitor_loan_defaults
AFTER UPDATE OF default_flag ON loans
FOR EACH ROW
WHEN (OLD.default_flag = FALSE AND NEW.default_flag = TRUE)
EXECUTE FUNCTION trigger_credit_limit_review();

CREATE TRIGGER monitor_payment_delays
AFTER INSERT OR UPDATE OF days_delayed ON alternative_credit_data
FOR EACH ROW
WHEN (NEW.days_delayed > 30)
EXECUTE FUNCTION trigger_credit_limit_review();

-- v. Analysis and Reporting Views
CREATE OR REPLACE VIEW credit_limit_analysis_summary AS
SELECT 
    c.occupation_industry,
    COUNT(*) as customer_count,
    AVG(clr.recommended_limit) as avg_recommended_limit,
    STDDEV(clr.recommended_limit) as limit_stddev,
    AVG(clr.recommended_limit - clr.current_credit_limit) as avg_limit_change,
    SUM(CASE WHEN clr.recommended_limit < clr.current_credit_limit THEN 1 ELSE 0 END) as downgrades,
    SUM(CASE WHEN clr.recommended_limit > clr.current_credit_limit THEN 1 ELSE 0 END) as upgrades
FROM customers c
JOIN credit_limit_recommendations clr ON c.customer_id = clr.customer_id
GROUP BY c.occupation_industry;

SELECT * 
FROM customer_financial_health;





-- 4. Early Warning System for Loan Defaults

-- More lenient Early Warning System for Loan Defaults
-- Early Warning System for Loan Defaults
WITH 

-- i. Payment Behavior Analysis
payment_behavior AS (
    SELECT 
        l.loan_id,
        l.customer_id,
        l.loan_amount,
        l.current_outstanding,
        acd.days_delayed,
        COUNT(DISTINCT CASE WHEN acd.days_delayed > 30 THEN acd.alt_credit_id END) as delayed_payments_30d,
        COUNT(DISTINCT CASE WHEN acd.days_delayed > 90 THEN acd.alt_credit_id END) as delayed_payments_90d,
        AVG(acd.days_delayed) as avg_delay,
        MAX(acd.days_delayed) as max_delay
    FROM loans l
    LEFT JOIN alternative_credit_data acd ON l.customer_id = acd.customer_id
    WHERE l.default_flag = FALSE
    GROUP BY l.loan_id, l.customer_id, l.loan_amount, l.current_outstanding, acd.days_delayed
),

-- ii. Transaction Pattern Analysis
transaction_patterns AS (
    SELECT 
        l.loan_id,
        l.customer_id,
        COUNT(DISTINCT ct.transaction_id) as monthly_transactions,
        SUM(CASE WHEN ct.amount < 0 THEN ABS(ct.amount) ELSE 0 END) as total_outflows,
        SUM(CASE WHEN ct.amount > 0 THEN amount ELSE 0 END) as total_inflows,
        STDDEV(ct.amount) as transaction_volatility
    FROM loans l
    JOIN customer_transactions ct ON l.customer_id = ct.customer_id
    WHERE ct.transaction_date >= CURRENT_DATE - INTERVAL '3 months'
    GROUP BY l.loan_id, l.customer_id
),

-- iii. Fraud Risk Assessment
fraud_risk AS (
    SELECT 
        l.loan_id,
        l.customer_id,
        COUNT(DISTINCT ft.fraud_id) as fraud_attempts,
        MAX(ft.timestamp) as last_fraud_attempt,
        STRING_AGG(DISTINCT ft.fraud_type, ', ') as fraud_types
    FROM loans l
    LEFT JOIN fraudulent_transactions ft ON l.customer_id = ft.customer_id
    WHERE ft.timestamp >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY l.loan_id, l.customer_id
),

-- iv. Customer Profile Risk
profile_risk AS (
    SELECT 
        l.loan_id,
        c.customer_id,
        c.credit_score,
        c.monthly_income,
        l.current_outstanding / c.monthly_income as debt_to_income_ratio,
        CASE 
            WHEN c.employment_status = 'Unemployed' THEN 3
            WHEN c.employment_status = 'Self-employed' THEN 2
            WHEN c.employment_status = 'Employed' THEN 1
        END as employment_risk_score
    FROM loans l
    JOIN customers c ON l.customer_id = c.customer_id
),

-- v. Industry Risk Assessment
industry_risk AS (
    SELECT 
        l.loan_id,
        c.customer_id,
        c.occupation_industry,
        COUNT(DISTINCT rl.loan_id) as industry_defaults,
        AVG(rl.current_outstanding) as avg_industry_exposure
    FROM loans l
    JOIN customers c ON l.customer_id = c.customer_id
    LEFT JOIN loans rl ON c.occupation_industry = (
        SELECT occupation_industry 
        FROM customers 
        WHERE customer_id = rl.customer_id
    )
    AND rl.default_flag = TRUE
    GROUP BY l.loan_id, c.customer_id, c.occupation_industry
),

-- vi. Bank Exposure Analysis
bank_exposure AS (
    SELECT 
        l.loan_id,
        l.bank_id,
        bf.npa_ratio,
        bf.capital_adequacy_ratio,
        lm.liquidity_coverage_ratio,
        CASE 
            WHEN bf.npa_ratio > 5 THEN 'High'
            WHEN bf.npa_ratio > 3 THEN 'Medium'
            ELSE 'Low'
        END as bank_risk_level
    FROM loans l
    JOIN bank_financials bf ON l.bank_id = bf.bank_id
    JOIN liquidity_metrics lm ON bf.bank_id = lm.bank_id
    WHERE bf.financial_year = EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR
),

-- vii. Historical Risk Signals
historical_signals AS (
    SELECT 
        l.loan_id,
        COUNT(DISTINCT rs.signal_id) as risk_signals_count,
        STRING_AGG(DISTINCT rs.signal_type, ', ') as risk_types,
        MAX(rs.severity) as max_severity
    FROM loans l
    LEFT JOIN risk_signals rs ON l.loan_id = rs.loan_id
    WHERE rs.detected_at >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY l.loan_id
),

-- viii. Composite Risk Score Calculation
risk_scoring AS (
    SELECT 
        pb.loan_id,
        pb.customer_id,
        -- Payment behavior score (30%)
        (CASE 
            WHEN pb.delayed_payments_90d > 0 THEN 100
            WHEN pb.delayed_payments_30d > 2 THEN 80
            WHEN pb.avg_delay > 15 THEN 60
            WHEN pb.delayed_payments_30d > 0 THEN 40
            ELSE 0
        END * 0.30) as payment_risk_score,
        
        -- Transaction pattern score (15%)
        (CASE 
            WHEN tp.total_inflows < tp.total_outflows THEN 100
            WHEN tp.transaction_volatility > 1000 THEN 80
            WHEN tp.monthly_transactions < 5 THEN 60
            ELSE 0
        END * 0.15) as transaction_risk_score,
        
        -- Fraud risk score (10%)
        (CASE 
            WHEN fr.fraud_attempts > 0 THEN 100
            ELSE 0
        END * 0.10) as fraud_risk_score,
        
        -- Profile risk score (20%)
        (CASE 
            WHEN pr.debt_to_income_ratio > 0.5 THEN 100
            WHEN pr.credit_score < 600 THEN 80
            WHEN pr.employment_risk_score = 3 THEN 60
            ELSE 0
        END * 0.20) as profile_risk_score,
        
        -- Industry risk score (10%)
        (CASE 
            WHEN ir.industry_defaults > 10 THEN 100
            WHEN ir.industry_defaults > 5 THEN 60
            ELSE 0
        END * 0.10) as industry_risk_score,
        
        -- Bank exposure score (15%)
        (CASE 
            WHEN be.bank_risk_level = 'High' THEN 100
            WHEN be.bank_risk_level = 'Medium' THEN 50
            ELSE 0
        END * 0.15) as bank_risk_score
    FROM payment_behavior pb
    JOIN transaction_patterns tp ON pb.loan_id = tp.loan_id
    LEFT JOIN fraud_risk fr ON pb.loan_id = fr.loan_id
    JOIN profile_risk pr ON pb.loan_id = pr.loan_id
    JOIN industry_risk ir ON pb.loan_id = ir.loan_id
    JOIN bank_exposure be ON pb.loan_id = be.loan_id
)

-- Final EWS Output
SELECT 
    rs.loan_id,
    rs.customer_id,
    (rs.payment_risk_score + rs.transaction_risk_score + rs.fraud_risk_score + 
     rs.profile_risk_score + rs.industry_risk_score + rs.bank_risk_score) as total_risk_score,
    CASE 
        WHEN (rs.payment_risk_score + rs.transaction_risk_score + rs.fraud_risk_score + 
              rs.profile_risk_score + rs.industry_risk_score + rs.bank_risk_score) >= 80 THEN 'Critical'
        WHEN (rs.payment_risk_score + rs.transaction_risk_score + rs.fraud_risk_score + 
              rs.profile_risk_score + rs.industry_risk_score + rs.bank_risk_score) >= 60 THEN 'High'
        WHEN (rs.payment_risk_score + rs.transaction_risk_score + rs.fraud_risk_score + 
              rs.profile_risk_score + rs.industry_risk_score + rs.bank_risk_score) >= 40 THEN 'Medium'
        ELSE 'Low'
    END as risk_level,
    rs.payment_risk_score,
    rs.transaction_risk_score,
    rs.fraud_risk_score,
    rs.profile_risk_score,
    rs.industry_risk_score,
    rs.bank_risk_score,
    hs.risk_signals_count,
    hs.risk_types,
    hs.max_severity,
    CURRENT_TIMESTAMP as assessment_timestamp
FROM risk_scoring rs
LEFT JOIN historical_signals hs ON rs.loan_id = hs.loan_id
ORDER BY total_risk_score DESC;


-- More Simplified View of EWS for Loans

WITH risk_indicators AS (
    SELECT 
        l.customer_id,
        l.loan_id,
        COUNT(DISTINCT rs.signal_id) as risk_signals_count,
        STRING_AGG(DISTINCT rs.signal_type, ', ') as risk_types,
        MAX(rs.severity) as max_severity
    FROM loans l
    LEFT JOIN risk_signals rs ON l.loan_id = rs.loan_id
    WHERE l.default_flag = FALSE
    GROUP BY l.customer_id, l.loan_id
),
transaction_anomalies AS (
    SELECT 
        ct.customer_id,
        COUNT(*) as suspicious_transactions,
        SUM(ct.amount) as suspicious_amount
    FROM customer_transactions ct
    JOIN fraudulent_transactions ft ON ct.transaction_id = ft.transaction_id
    WHERE ft.timestamp >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY ct.customer_id
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    l.loan_id,
    l.loan_amount,
	l.loan_type,
	l.purpose,
    l.current_outstanding,
    ri.risk_signals_count,
    ri.risk_types,
    ta.suspicious_transactions,
    -- Default probability score (0-100)
    ROUND(
        (
            CASE WHEN ri.max_severity = 'HIGH' THEN 40
                 WHEN ri.max_severity = 'MEDIUM' THEN 20
                 WHEN ri.max_severity = 'LOW' THEN 10
                 ELSE 0 
            END +
            LEAST(ri.risk_signals_count * 5, 30) +
            CASE WHEN ta.suspicious_transactions > 0 THEN 30 ELSE 0 END
        )::numeric,
        2
    ) as default_probability,
    -- Risk classification
    CASE 
        WHEN ri.risk_signals_count >= 3 OR ri.max_severity = 'HIGH' THEN 'High Risk'
        WHEN ri.risk_signals_count >= 1 OR ta.suspicious_transactions > 0 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_classification
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
LEFT JOIN risk_indicators ri ON l.loan_id = ri.loan_id
LEFT JOIN transaction_anomalies ta ON c.customer_id = ta.customer_id
WHERE l.default_flag = FALSE;






-- 5. Basel-III Compliance Analysis

-- i. Capital Adequacy Analysis
WITH capital_metrics AS (
    SELECT 
        bank_id,
        financial_year,
        tier_1_capital,
        tier_2_capital,
        (tier_1_capital + tier_2_capital) as total_capital,
        risk_weighted_assets,
        total_exposures,
        ROUND((tier_1_capital / risk_weighted_assets * 100)::numeric, 2) as tier1_ratio,
        ROUND(((tier_1_capital + tier_2_capital) / risk_weighted_assets * 100)::numeric, 2) as total_capital_ratio,
        ROUND((tier_1_capital / total_exposures * 100)::numeric, 2) as leverage_ratio
    FROM bank_financials
)
SELECT 
    cm.*,
    CASE 
        WHEN tier1_ratio >= 6.0 AND total_capital_ratio >= 8.0 AND leverage_ratio >= 3.0 
        THEN 'Compliant'
        ELSE 'Non-Compliant'
    END as basel_capital_status,
    JSONB_BUILD_OBJECT(
        'tier1_gap', GREATEST(6.0 - tier1_ratio, 0),
        'total_capital_gap', GREATEST(8.0 - total_capital_ratio, 0),
        'leverage_gap', GREATEST(3.0 - leverage_ratio, 0)
    ) as compliance_gaps
FROM capital_metrics cm;

-- ii. Liquidity Coverage Ratio (LCR) Analysis
WITH monthly_lcr AS (
    SELECT 
        lm.bank_id,
        lm.financial_year,
        DATE_TRUNC('month', lm.reporting_date) as month,
        AVG(lm.high_quality_liquid_assets) as avg_hqla,
        AVG(lm.cash_outflows_30d) as avg_outflows,
        AVG(lm.liquidity_coverage_ratio) as avg_lcr,
        MIN(lm.liquidity_coverage_ratio) as min_lcr,
        MAX(lm.liquidity_coverage_ratio) as max_lcr,
        COUNT(*) as data_points
    FROM liquidity_metrics lm
    GROUP BY lm.bank_id, lm.financial_year, DATE_TRUNC('month', lm.reporting_date)
)
SELECT 
    ml.*,
    CASE 
        WHEN avg_lcr >= 100 THEN 'Compliant'
        WHEN avg_lcr >= 80 THEN 'Transitional'
        ELSE 'Non-Compliant'
    END as lcr_status,
    JSONB_BUILD_OBJECT(
        'lcr_gap', GREATEST(100 - avg_lcr, 0),
        'volatility', (max_lcr - min_lcr),
        'trend', LAG(avg_lcr) OVER (PARTITION BY bank_id ORDER BY month) - avg_lcr
    ) as lcr_metrics
FROM monthly_lcr ml;

-- iii. Risk-Weighted Assets (RWA) Analysis with Credit Risk Focus
WITH loan_risk_profile AS (
    SELECT 
        l.bank_id,
        DATE_TRUNC('month', l.loan_application_date) as month,
        l.loan_type,
        COUNT(*) as total_loans,
        SUM(l.loan_amount) as total_exposure,
        SUM(CASE WHEN l.default_flag THEN l.current_outstanding ELSE 0 END) as defaulted_amount,
        SUM(CASE 
            WHEN l.loan_type = 'mortgage' THEN l.loan_amount * 0.35  -- Basel III standardized risk weight for residential mortgages
            WHEN l.loan_type = 'corporate' AND l.current_outstanding > 1000000 THEN l.loan_amount * 1.00
            WHEN l.loan_type = 'retail' THEN l.loan_amount * 0.75
            ELSE l.loan_amount * 1.00
        END) as risk_weighted_exposure,
        ROUND((SUM(CASE WHEN l.default_flag THEN l.current_outstanding ELSE 0 END) / 
               NULLIF(SUM(l.loan_amount), 0) * 100)::numeric, 2) as default_rate
    FROM loans l
    GROUP BY l.bank_id, DATE_TRUNC('month', l.loan_application_date), l.loan_type
)
SELECT 
    lrp.*,
    ROUND((risk_weighted_exposure / total_exposure * 100)::numeric, 2) as avg_risk_weight,
    DENSE_RANK() OVER (PARTITION BY bank_id ORDER BY default_rate DESC) as risk_rank
FROM loan_risk_profile lrp;

-- iv. Stress Testing and Scenario Analysis
WITH stress_scenarios AS (
    SELECT 
        bf.bank_id,
        bf.financial_year,
        bf.tier_1_capital,
        bf.tier_2_capital,
        bf.risk_weighted_assets,
        -- Severe stress scenario (20% RWA increase, 10% capital decrease)
        ROUND((((bf.tier_1_capital * 0.9) + (bf.tier_2_capital * 0.9)) / (bf.risk_weighted_assets * 1.2) * 100)::numeric, 2) as severe_stress_car,
        -- Moderate stress scenario (10% RWA increase, 5% capital decrease)
        ROUND((((bf.tier_1_capital * 0.95) + (bf.tier_2_capital * 0.95)) / (bf.risk_weighted_assets * 1.1) * 100)::numeric, 2) as moderate_stress_car,
        -- Mild stress scenario (5% RWA increase, 2% capital decrease)
        ROUND((((bf.tier_1_capital * 0.98) + (bf.tier_2_capital * 0.98)) / (bf.risk_weighted_assets * 1.05) * 100)::numeric, 2) as mild_stress_car
    FROM bank_financials bf
)
SELECT 
    ss.*,
    JSONB_BUILD_OBJECT(
        'severe_impact', ROUND((capital_adequacy_ratio - severe_stress_car)::numeric, 2),
        'moderate_impact', ROUND((capital_adequacy_ratio - moderate_stress_car)::numeric, 2),
        'mild_impact', ROUND((capital_adequacy_ratio - mild_stress_car)::numeric, 2)
    ) as stress_impact,
    CASE 
        WHEN severe_stress_car >= 8.0 THEN 'Highly Resilient'
        WHEN moderate_stress_car >= 8.0 THEN 'Moderately Resilient'
        WHEN mild_stress_car >= 8.0 THEN 'Marginally Resilient'
        ELSE 'Vulnerable'
    END as stress_resilience
FROM stress_scenarios ss
JOIN bank_financials bf USING (bank_id, financial_year);

-- v. Concentration Risk Analysis
WITH exposure_concentration AS (
    SELECT 
        l.bank_id,
        c.occupation_industry,
        COUNT(DISTINCT l.customer_id) as num_customers,
        SUM(l.loan_amount) as total_exposure,
        MAX(l.loan_amount) as largest_exposure,
        AVG(l.loan_amount) as avg_exposure,
        STDDEV(l.loan_amount) as exposure_stddev
    FROM loans l
    JOIN customers c USING (customer_id)
    GROUP BY l.bank_id, c.occupation_industry
)
SELECT 
    ec.*,
    ROUND((largest_exposure / NULLIF(total_exposure, 0) * 100)::numeric, 2) as concentration_ratio,
    ROUND((exposure_stddev / NULLIF(avg_exposure, 0) * 100)::numeric, 2) as coefficient_of_variation,
    NTILE(4) OVER (PARTITION BY bank_id ORDER BY total_exposure DESC) as exposure_quartile
FROM exposure_concentration ec;

-- vi. Regulatory Reporting Dashboard
WITH compliance_summary AS (
    SELECT       
        bf.financial_year,
        bf.capital_adequacy_ratio,
        lm.liquidity_coverage_ratio,
        bf.npa_ratio,
        ROUND((bf.tier_1_capital / bf.risk_weighted_assets * 100)::numeric, 2) as tier1_ratio,
        ROUND(((bf.tier_1_capital + bf.tier_2_capital) / bf.total_exposures * 100)::numeric, 2) as leverage_ratio,
        pm.psl_exposure / NULLIF(pm.total_credit_exposure, 0) * 100 as psl_achievement
    FROM bank_financials bf
    LEFT JOIN liquidity_metrics lm USING (bank_id, financial_year)
    LEFT JOIN psl_metrics pm USING (bank_id, financial_year)
    WHERE lm.reporting_date = (
        SELECT MAX(reporting_date)
        FROM liquidity_metrics
        WHERE bank_id = bf.bank_id AND financial_year = bf.financial_year
    )
)
SELECT 
    cs.*,
    JSONB_BUILD_OBJECT(
        'capital_status', CASE 
            WHEN capital_adequacy_ratio >= 10.5 THEN 'Compliant'
            ELSE 'Non-Compliant'
        END,
        'liquidity_status', CASE 
            WHEN liquidity_coverage_ratio >= 100 THEN 'Compliant'
            ELSE 'Non-Compliant'
        END,
        'asset_quality_status', CASE 
            WHEN npa_ratio <= 5.0 THEN 'Healthy'
            WHEN npa_ratio <= 10.0 THEN 'Watch'
            ELSE 'Critical'
        END,
        'psl_status', CASE 
            WHEN psl_achievement >= 40.0 THEN 'Target Achieved'
            ELSE 'Below Target'
        END
    ) as compliance_status,
    ARRAY[
        GREATEST(10.5 - capital_adequacy_ratio, 0),
        GREATEST(100 - liquidity_coverage_ratio, 0),
        GREATEST(npa_ratio - 5.0, 0),
        GREATEST(40.0 - psl_achievement, 0)
    ] as compliance_gaps
FROM compliance_summary cs;






-- Priority Sector Lending Analysis

WITH bank_psl_summary AS (
    -- Calculate total PSL metrics for each bank and financial year
    SELECT 
        pm.bank_id,
        pm.financial_year,
        bf.bank_name,
        MAX(pm.total_credit_exposure) as total_credit_exposure,
        MAX(pm.psl_exposure) as psl_exposure,
        MAX(pm.psl_target) as target_percentage,
        (MAX(pm.psl_exposure) / NULLIF(MAX(pm.total_credit_exposure), 0) * 100) as achieved_percentage
    FROM psl_metrics pm
    JOIN bank_financials bf ON pm.bank_id = bf.bank_id AND pm.financial_year = bf.financial_year
    GROUP BY pm.bank_id, pm.financial_year, bf.bank_name
),
psl_compliance_detail AS (
    -- Analyze compliance and calculate shortfall
    SELECT 
        bank_id,
        financial_year,
        bank_name,
        total_credit_exposure,
        psl_exposure,
        target_percentage,
        achieved_percentage,
        CASE 
            WHEN achieved_percentage >= target_percentage THEN 'Compliant'
            ELSE 'Non-Compliant'
        END as compliance_status,
        CASE 
            WHEN achieved_percentage < target_percentage 
            THEN (target_percentage - achieved_percentage) 
            ELSE 0 
        END as percentage_shortfall,
        CASE 
            WHEN achieved_percentage < target_percentage 
            THEN (target_percentage/100 * total_credit_exposure) - psl_exposure
            ELSE 0 
        END as amount_shortfall
    FROM bank_psl_summary
)
SELECT 
    bank_id,
    financial_year,
    bank_name,
    ROUND(total_credit_exposure/10000000, 2) as total_exposure_cr,
    ROUND(psl_exposure/10000000, 2) as psl_exposure_cr,
    ROUND(target_percentage, 2) as target_pct,
    ROUND(achieved_percentage, 2) as achieved_pct,
    compliance_status,
    ROUND(percentage_shortfall, 2) as shortfall_pct
FROM psl_compliance_detail
ORDER BY 
    financial_year DESC,
    compliance_status DESC,
    percentage_shortfall DESC;