# POS

## โครงสร้างระบบ (Project Structure)

```
POS/
├── POS-BACKEND/           # โค้ดฝั่ง Backend (API, Service, ฐานข้อมูล)
│   └── src/
│       ├── common/        # โค้ดที่ใช้ร่วมกัน
│       ├── config/        # ไฟล์ตั้งค่าระบบ
│       ├── database/      # โค้ดที่เกี่ยวกับฐานข้อมูล
│       └── modules/       # โมดูลฟีเจอร์ต่าง ๆ
├── POS-INFRASTRUCTURE/    # Orchestration & Infrastructure-as-code
│   ├── nginx/             # Reverse proxy configurations
│   ├── docker-compose.yml # Local orchestration environment
│   ├── prometheus/        # Metrics collection configurations
│   └── grafana/           # Visualization dashboards
├── POS-MOBILE/            # โค้ดฝั่ง Mobile Application
│   └── lib/               # โค้ดหลักของแอปมือถือ
└── README.md              # ไฟล์อธิบายโปรเจกต์
```
