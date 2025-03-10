FROM apache/airflow:latest

COPY requirements.txt  ./

USER airflow
RUN pip install --upgrade pip
RUN python -m virtualenv env && source env/bin/activate
# Install Apache Airflow and other dependencies
RUN pip install apache-airflow==${AIRFLOW_VERSION} && \
    pip install -r requirements.txt