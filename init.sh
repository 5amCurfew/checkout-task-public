#!/usr/bin/env bash
export DBT_PROJECT_PATH=/dbt
export AIRFLOW_PROJECT_PATH=/airflow
mkdir /root/.dbt \
    && cp $DBT_PROJECT_PATH/.dbt/profiles.yml /root/.dbt/ \
    && cp $DBT_PROJECT_PATH/.dbt/dbt-user-credentials.json /root/.dbt/ \
    && cp $DBT_PROJECT_PATH/.dbt/.user.yml /root/.dbt/ \
    && cd $DBT_PROJECT_PATH \
    && dbt deps \
    && dbt debug \
    && dbt compile

mkdir /root/airflow \
    && cp $AIRFLOW_PROJECT_PATH/airflow.cfg /root/airflow/ \
    && mkdir /root/airflow/dags \
    && cp $AIRFLOW_PROJECT_PATH/dags/* /root/airflow/dags/ \
    && airflow initdb \
    && airflow scheduler & airflow webserver