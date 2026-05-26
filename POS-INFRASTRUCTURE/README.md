# POS-INFRASTRUCTURE

## โครงสร้าง Infrastructure

```
POS-INFRASTRUCTURE/
├── nginx/                 # Reverse proxy configurations
├── docker-compose.yml     # Local orchestration environment
├── prometheus/            # Metrics collection configurations
└── grafana/               # Visualization dashboards
```

### คำอธิบาย

- **nginx/**: ไฟล์ตั้งค่า Reverse Proxy (Nginx)
- **docker-compose.yml**: สำหรับรันระบบแบบ local orchestration
- **prometheus/**: ตั้งค่า Metrics collection (Prometheus)
- **grafana/**: Dashboard สำหรับ Visualization (Grafana)

> หมายเหตุ: โฟลเดอร์ย่อยบางส่วนอาจยังว่างเปล่า ขึ้นอยู่กับการพัฒนา
