FROM python:3.7

RUN pip install dbt==0.18.1 \
    && pip install apache-airflow==1.10.12 \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-1.10.12/constraints-3.7.txt"

RUN mkdir /task
RUN mkdir /task/dbt
RUN mkdir /task/airflow/

COPY init.sh /task/
COPY dbt/ /task/dbt/
COPY airflow/ /task/airflow/

EXPOSE 8080
RUN export AIRFLOW_HOME=/user/airflow

RUN chmod +x /task/init.sh
ENTRYPOINT [ "/task/init.sh" ]