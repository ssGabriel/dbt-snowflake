from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.hooks.base import BaseHook
from datetime import datetime
from cosmos import DbtTaskGroup, ProfileConfig, ProjectConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping
from cosmos.config import ExecutionConfig
from pathlib import Path


default_args = {
    "owner": "airflow",
    "start_date": datetime(2022, 1, 1),
    "retries": 1,
}

DBT_PATH = "/opt/airflow/dbt/snowflake_dbt"
DBT_PROFILE = "snowflake_dbt"
DBT_TARGETS = "dev"

# Configure the dbt profile
profile_config = ProfileConfig(
    profile_name=DBT_PROFILE,
    target_name=DBT_TARGETS,
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id='snowflake_conn',
    ),
)

# Configure the dbt project
project_config = ProjectConfig(
    dbt_project_path=DBT_PATH,
    models_relative_path="models"
)

# Configure the dbt execution path
execution_config = ExecutionConfig(
    dbt_executable_path=DBT_PATH,
)

dag = DAG(
    "snowflake_dbt",
    default_args=default_args,
    schedule_interval="@daily",
    catchup=False,
)

start_dag = DummyOperator(task_id="start_dag", dag=dag)

dbt_running_models = DbtTaskGroup(
    group_id="dbt_running_models",
    project_config=project_config,
    profile_config=profile_config,
    operator_args={"install_deps": True},  # Install dbt dependencies
    default_args={"retries": 2},
    dag=dag,
)

end_dag = DummyOperator(task_id="end_dag", dag=dag)

start_dag >> dbt_running_models >> end_dag