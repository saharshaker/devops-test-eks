FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .

EXPOSE 5000
RUN useradd -m deploy && chown -R deploy /app
USER deploy

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]