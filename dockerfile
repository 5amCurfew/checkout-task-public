FROM python:3.7

RUN pip install dbt==0.18.1 \
    && pip install apache-airflow==1.10.12 \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-1.10.12/constraints-3.7.txt"

RUN mkdir /dbt
RUN mkdir /airflow/

COPY init.sh /
COPY dbt/ /dbt/
COPY airflow/ /airflow/

EXPOSE 8080
RUN export AIRFLOW_HOME=/user/airflow

RUN chmod +x /task/init.sh
ENTRYPOINT [ "/task/init.sh" ]