{{ 
    config(
    materialized='incremental',
    unique_id=['DATE_ID','ORGANIZATION_ID', 'INVOICE_ID'],
) 
}}


SELECT  
    dd.DATE_ID,
    dd.DAY_OF_WEEK,
    dd.DAY_NAME,
    dd.QUARTER,
    dd.MONTH,
    dd.YEAR,
    dd.QUARTER_END_DATE,
    dd.MONTH_END_DATE,
    do.ORGANIZATION_ID,
    do.FIRST_PAYMENT_DATE,
    do.LAST_PAYMENT_DATE,
    do.LEGAL_ENTITY_COUNTRY_CODE,
    do.COUNT_TOTAL_CONTRACTS_ACTIVE,
    do.CREATED_DATE,
    do.COUNT_TRANSACTIONS_LAST_30_DAYS,
    do.COUNT_TRANSACTIONS_LAST_90_DAYS,
    do.COUNT_TRANSACTIONS,
    do.SUM_TRANSACTIONS_LAST_30_DAYS,
    do.SUM_TRANSACTIONS_LAST_90_DAYS,
    do.TOTAL_TRANSACTIONS,
    di.INVOICE_ID,
    di.PARENT_INVOICE_ID,
    di.TRANSACTION_ID,
    di.TYPE,
    di.STATUS,
    di.CURRENCY,
    di.PAYMENT_CURRENCY,
    di.PAYMENT_METHOD,
    di.AMOUNT,
    di.PAYMENT_AMOUNT,
    di.FX_RATE,
    di.FX_RATE_PAYMENT,
    di.CREATED_AT,
    di.VALUE_USD,
    SUM(VALUE_USD) OVER (PARTITION BY di.DATE_ID, di.ORGANIZATION_ID) AS TRANSACTION_VALUE_BY_DATE,
    di._incremental_sequence AS _sequence,
    CURRENT_TIMESTAMP()      AS _incremental_sequence
FROM
    {{ ref('dim_invoices')}} di 
    LEFT JOIN  {{ ref('dim_date')}} dd
        ON  di.date_id = dd.date_id
    LEFT JOIN {{ ref('dim_organizations') }} do
        ON  di.ORGANIZATION_ID = do.ORGANIZATION_ID
{% if is_incremental() %}
    WHERE 
        _sequence >= SELECT MAX(_incremental_sequence) FROM {{this}}
{% endif %}
