FROM python:3.9

RUN apt update && apt install -y git \
    && git clone https://github.com/CTFd/CTFd.git /app

WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 8000

CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"]
