FROM python:3.11-slim

WORKDIR /app
COPY elm327_server.py /app/elm327_server.py

EXPOSE 35000

ENV PYTHONUNBUFFERED=1
CMD ["python", "/app/elm327_server.py"]
