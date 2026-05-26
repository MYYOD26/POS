## วิธีติดตั้ง POS-BACKEND

1. เปิดเทอร์มินัล
2. รันคำสั่ง:

```bash
cd POS/POS-BACKEND
npm install
npm run start:dev
```


## วิธีรัน POS-BACKEND ด้วย Docker

1. เปิดเทอร์มินัล
2. รันคำสั่ง:

```bash
cd POS
# รัน backend ด้วย docker-compose
docker-compose up --build 
```

- ไม่ต้องติดตั้ง Node.js หรือ npm ในเครื่อง
- ไม่ต้อง npm install
