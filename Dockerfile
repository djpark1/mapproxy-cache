FROM python:3.12-slim

WORKDIR /app

RUN apt-get update \
	&& apt-get install -y --no-install-recommends proj-bin libproj-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY mapproxy.yaml /app/mapproxy.yaml
COPY seed.yaml /app/seed.yaml
RUN mkdir -p /app/cache_data/locks

EXPOSE 8080

CMD ["mapproxy-util", "serve-develop", "-b", "0.0.0.0:8080", "/app/mapproxy.yaml"]
