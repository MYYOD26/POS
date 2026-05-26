import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as fs from 'node:fs';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle('POS Backend API')
    .setDescription('RESTful API สำหรับระบบ Point of Sale (POS)  ')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  const port = Number(process.env.PORT ?? 3000);
  const host = process.env.HOST ?? '0.0.0.0';

  await app.listen(port, host);

  const swaggerUrl = `http://localhost:${port}/api#/`;
  console.log(`Swagger UI: ${swaggerUrl}`);

  const runningInDocker =
    process.env.DOCKER === 'true' || fs.existsSync('/.dockerenv');
  const shouldOpenBrowser =
    !runningInDocker &&
    (process.env.OPEN_BROWSER === 'true' ||
      (process.env.OPEN_BROWSER !== 'false' &&
        process.env.NODE_ENV !== 'production'));

  if (shouldOpenBrowser) {
    const open = (await import('open')).default;
    await open(swaggerUrl);
  }
}
bootstrap();