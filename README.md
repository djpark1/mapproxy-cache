# MapProxy Cache Server

Docker 기반 MapProxy 캐시 서버입니다. geolab-app 프로젝트의 GSS WMS를 프록시/캐싱하고 WMS/WMTS/TMS로 제공합니다.

기본 업스트림 WMS 엔드포인트:

- `http://59.6.153:8090/gssogc`

필요하면 `mapproxy.yaml`의 `sources.gss_wms.req.url` 및 `sources.gss_wms.req.layers`를 실제 geolab-app 설정에 맞게 변경하세요.

## 빠른 시작

1. 서버 실행

```powershell
./scripts/run.ps1
```

2. 캐시 시드(선택)

```powershell
./scripts/seed.ps1
```

3. 접속

- 데모 뷰어: `http://localhost:8091/demo/`
- WMTS Capabilities: `http://localhost:8091/service?REQUEST=GetCapabilities&SERVICE=WMTS`
- WMS Capabilities: `http://localhost:8091/service?REQUEST=GetCapabilities&SERVICE=WMS`

## geolab-app 연동(nginx 프록시 + WMS 호출)

MapProxy를 VirtualBox 도커에서 띄우는 경우, geolab-app 프론트는 원본 WMS(`59.6.153:8090/gssogc`) 대신 nginx를 통해 MapProxy를 호출하도록 바꾸면 됩니다.

1. nginx 리버스 프록시 설정 예시

```nginx
location /mapproxy/ {
    proxy_pass http://localhost:8091/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

2. geolab-app WMS 소스 URL 교체

- 기존: `http://59.6.153:8090/gssogc`
- 변경: `/mapproxy/service`

3. WMS 레이어명 교체

- 기존 레이어: `gss`
- 변경 레이어: `gss_cache`

GetCapabilities 확인 URL:

- 외부 nginx 경유: `/mapproxy/service?SERVICE=WMS&REQUEST=GetCapabilities`
- MapProxy 직접 확인: `http://localhost:8091/service?SERVICE=WMS&REQUEST=GetCapabilities`

## 로컬 Python 실행(선택)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
mapproxy-util serve-develop -b 0.0.0.0:8080 mapproxy.yaml
```

## 캐시/시드 설정

- 서비스/레이어 설정: `mapproxy.yaml`
- 시드 범위/레벨 설정: `seed.yaml`
- 캐시 저장 위치: `cache_data/`

## 트러블슈팅

- 증상: `ImportError: could not find pyproj (Python library) or libproj`
- 조치: 이미지를 재빌드해서 의존성을 다시 설치

```bash
docker compose build --no-cache mapproxy
docker compose up -d mapproxy
docker compose logs -f mapproxy
```
