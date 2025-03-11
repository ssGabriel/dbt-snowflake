# Data Orchestration Project with Airflow, dbt, Snowflake, and Slack

This project was developed to orchestrate data pipelines using Apache Airflow, dbt (Data Build Tool), Snowflake, and Slack. The main goal is to automate data transformations in Snowflake using dbt and send daily notifications with the results to a Slack channel.

## Project Architecture

The project was set up in a Docker environment using a base Airflow image. To simplify the management of dbt profiles and configuration files, the `astronomer-cosmos` library was used, which facilitates the dynamic creation of DAGs in Airflow.

### Key Components

1. **Airflow**: Task orchestrator responsible for scheduling and executing DAGs.
2. **dbt**: Data transformation tool used to build models in Snowflake.
3. **Snowflake**: Data warehouse where data is stored and transformed.
4. **Slack**: Communication platform for sending daily notifications.

## Workflow

1. **Data Reading and Transformation**:
   - Data is read directly from Snowflake.
   - Using dbt, the data is transformed into `star schema` models, where:
     - In the **dimension** layer, possible dimensions are created.
     - In the **fact** layer, joins between tables are performed to create fact tables.
   - An auxiliary calendar model was created to ensure daily granularity for transactions per organization.

2. **Slack Notifications**:
   - A DAG was created to send daily notifications to a Slack channel using a webhook.
   - The notification is based on a specific fact table that consolidates daily transactions.

## Environment Setup

### Prerequisites

- Docker and Docker Compose installed.
- Snowflake account with appropriate permissions.
- Slack API token for webhook configuration.

### Steps to Run

1. **Docker Configuration**:
   - The environment was configured in a Dockerfile based on Airflow, with dbt and the necessary libraries installed.

2. **Installing `astronomer-cosmos`**:
   - The `astronomer-cosmos` library was used to simplify the creation of dynamic DAGs from dbt models.

3. **Configuring Airflow Connections**:
   - Set up the Snowflake connection (`snowflake_default`).
   - Set up the Slack connection (`slack_default`).

4. **Running the DAGs**:
   - The DAGs run daily, performing data transformations in Snowflake and sending notifications to Slack.

## Project Structure

- **dbt**: Contains dbt models and macros.
  - `models/dimension`: Dimension models.
  - `models/fact`: Fact models.
  - `macros`: Custom macros, such as the calendar model.
- **airflow/dags**: Contains Airflow DAGs.
  - `dbt_daily_run.py`: DAG for daily dbt execution.
  - `snowflake_to_slack.py`: DAG for sending notifications to Slack.

## Final Considerations

This project was simplified to focus on data transformation and notifications, without considering data ingestion or dashboard creation. The use of the `star schema` and the calendar model ensures an organized structure and daily granularity for transaction analysis.

For questions or suggestions, feel free to open an issue or reach out.

## Running the Project

To start the project, run the following command in the root directory:

```bash
docker-compose up
