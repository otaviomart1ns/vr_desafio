FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod 755 wait-for-it.sh

EXPOSE 5000

CMD ["./wait-for-it.sh", "db:3306", "--", "flask", "run", "--host=0.0.0.0"]
