{{ 
    config(
        materialized='table',
        unique_key='date'
    ) 
}}


{{ generate_date_dimension('2019-04-01', '2024-04-24') }}
