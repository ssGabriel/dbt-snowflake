{{ 
    config(
    materialized='incremental',
    unique_id=['DATE_ID','ORGANIZATION_ID'],
) 
}}


SELECT  
    dd.DATE_ID,
    do.ORGANIZATION_ID,
    SUM(VALUE_USD) AS VALUE_BY_DATE
FROM
    {{ ref('dim_date') }} dd
LEFT JOIN 
    {{ ref('dim_invoices')}} di 
        ON  dd.date_id = di.date_id
LEFT JOIN {{ ref('dim_organizations') }} do
        ON  di.ORGANIZATION_ID = do.ORGANIZATION_ID
WHERE 
    STATUS = 'paid'
GROUP BY ALL
