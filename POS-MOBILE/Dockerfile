# Dockerfile for POS-MOBILE (placeholder)
# ปรับแต่งตาม framework ที่ใช้ เช่น React Native, Flutter, Ionic
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
# RUN build-command-here
CMD ["npm", "start"]