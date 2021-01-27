from datetime import timedelta
from datetime import datetime

# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG

# Operators; we need this to operate!
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago

# These args will get passed on to each operator
# You can override them on a per-task basis during operator initialization
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2020, 11, 2, 12, 0, 0),
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

dag = DAG(
    "scheduled_dbt_daily",
    default_args=default_args,
    catchup=False,
    schedule_interval="0/15 * * * *",
)

dbt_snapshot = BashOperator(
    task_id="dbt_snapshot",
    bash_command="cd /task/dbt && dbt snapshot",
    dag=dag,
)

dbt_run = BashOperator(
    task_id="dbt_run_daily",
    bash_command="cd /task/dbt && dbt run",
    dag=dag,
)

dbt_test = BashOperator(
    task_id="dbt_test_daily",
    bash_command="cd /task/dbt && dbt test",
    dag=dag,
)

with dag:
    dbt_snapshot >> dbt_run >> dbt_test