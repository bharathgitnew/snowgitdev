from airflow.decorators import dag, task
from datetime import datetime

@dag(
    dag_id="test_smtp_connectivity",
    start_date=datetime(2026, 1, 1),
    schedule=None,          
    catchup=False,
    tags=["diagnostic"]
)
def test_smtp_dag():

    @task
    def test_smtp():
        import smtplib
        import os

        smtp_server = os.getenv("SMTP_SERVER")
        smtp_port = int(os.getenv("SMTP_PORT"))

        print(f"Attempting to connect to {smtp_server}:{smtp_port}...")

        with smtplib.SMTP(smtp_server, smtp_port) as server:
            code, message = server.ehlo()
            print(f"EHLO response: {code} - {message.decode()}")

            if code == 250:
                print("SMTP connection successful port is open and reachable")
            else:
                raise Exception(f"Unexpected EHLO response: {code}")

    test_smtp()

test_smtp_dag()