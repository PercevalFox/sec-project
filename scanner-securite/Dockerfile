FROM python:3.9

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY scanner.py /app/scanner.py

WORKDIR /app

CMD ["python", "scanner.py"]
