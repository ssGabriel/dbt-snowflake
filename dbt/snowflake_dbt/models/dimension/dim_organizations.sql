{{
    config(
        materialized='incremental',
        unique_id=['ORGANIZATION_ID'],
        tags=['bronze'],
    )
}}

WITH  aux_amount AS (
    SELECT  
        ORGANIZATION_ID,
        COUNT(CASE WHEN di.CREATED_AT > CURRENT_TIMESTAMP - INTERVAL '30 DAYS' THEN 1 END)       AS COUNT_TRANSACTIONS_LAST_30_DAYS,
        COUNT(CASE WHEN di.CREATED_AT > CURRENT_TIMESTAMP - INTERVAL '90 DAYS' THEN 1 END)       AS COUNT_TRANSACTIONS_LAST_90_DAYS,
        COUNT(1)                                                                               AS COUNT_TRANSACTIONS,
        SUM(CASE WHEN di.CREATED_AT > CURRENT_TIMESTAMP - INTERVAL '30 DAYS' THEN VALUE_USD END) AS SUM_TRANSACTIONS_LAST_30_DAYS,
        SUM(CASE WHEN di.CREATED_AT > CURRENT_TIMESTAMP - INTERVAL '90 DAYS' THEN VALUE_USD END) AS SUM_TRANSACTIONS_LAST_90_DAYS,
        SUM(VALUE_USD)                                                                         AS TOTAL_TRANSACTIONS,
    FROM
        {{ref('dim_invoices')}} di
    WHERE 
        STATUS = 'paid'        
    GROUP BY 1
)    
    

SELECT
	CAST(do.ORGANIZATION_ID AS BIGINT)        AS ORGANIZATION_ID,
	CAST(FIRST_PAYMENT_DATE AS DATE)          AS FIRST_PAYMENT_DATE,
    CAST(LAST_PAYMENT_DATE AS DATE)           AS LAST_PAYMENT_DATE,
    CAST(LEGAL_ENTITY_COUNTRY_CODE AS BIGINT) AS LEGAL_ENTITY_COUNTRY_CODE,
    CAST(COUNT_TOTAL_CONTRACTS_ACTIVE AS INT) AS COUNT_TOTAL_CONTRACTS_ACTIVE,
    CAST(CREATED_DATE AS TIMESTAMP)           AS CREATED_DATE,
    COUNT_TRANSACTIONS_LAST_30_DAYS,
    COUNT_TRANSACTIONS_LAST_90_DAYS,
    COUNT_TRANSACTIONS,
    SUM_TRANSACTIONS_LAST_30_DAYS,
    SUM_TRANSACTIONS_LAST_90_DAYS,
    TOTAL_TRANSACTIONS,
    CURRENT_TIMESTAMP()                       AS _incremental_sequence,

FROM 
    {{source('RAW_PROD','ORGANIZATIONS')}} do
        LEFT JOIN  aux_amount aa ON do.ORGANIZATION_ID = aa.ORGANIZATION_ID

{% if is_incremental() %}
    WHERE _incremental_sequence > CURRENT_TIMESTAMP()
{% endif %}