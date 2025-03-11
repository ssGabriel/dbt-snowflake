from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.providers.slack.operators.slack_webhook import SlackWebhookOperator
from airflow.utils.dates import days_ago

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'retries': 1,
}

# Define the DAG
with DAG(
    dag_id='snowflake_to_slack_example',
    default_args=default_args,
    schedule_interval='@daily',  # Run daily
    catchup=False,
) as dag:

    # Step 1: Run a query in Snowflake
    run_query = SnowflakeOperator(
        task_id='run_query_in_snowflake',
        sql=""" 
            SELECT 
                DISTINCT
                tb1.DATE_ID,
                tb1.ORGANIZATION_ID,
                tb1.TRANSACTION_VALUE_BY_DATE AS TODAY_VALUE,
                tb2.TRANSACTION_VALUE_BY_DATE AS LAST_VALUE,
                DIV0(LAST_VALUE,TODAY_VALUE) AS result
            FROM 
                PROD.FACT_INVOICE_ORGANIZATION tb1
                    INNER JOIN PROD.FACT_INVOICE_ORGANIZATION tb2 
                        ON tb1.DATE_ID=(tb2.DATE_ID+1) AND tb1.ORGANIZATION_ID=tb2.ORGANIZATION_ID
            WHERE 
            tb1.DATE_ID >= CURRENT_DATE AND
                DIV0(LAST_VALUE,TODAY_VALUE) >=0.5""",  # Replace with your query
        snowflake_conn_id='snowflake_conn',  # Snowflake connection ID
        do_xcom_push=True,  # Save results for next task
    )

    # Step 2: Send results to Slack
    send_to_slack = SlackWebhookOperator(
        task_id='send_results_to_slack',
        slack_webhook_conn_id='slack_conn',
        channel='#tests-for-webhook-from-snowflake',
        message="{{ task_instance.xcom_pull(task_ids='run_query_in_snowflake') }}"
    )

    # Define task dependencies
    run_query >> send_to_slack