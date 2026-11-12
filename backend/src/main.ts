import 'reflect-metadata';
import * as path from 'path';
import * as dotenv from 'dotenv';
dotenv.config({ path: path.resolve(__dirname, '../.env') });

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.setGlobalPrefix('api/v1');

  const port = Number(process.env.PORT || 4100);
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 FreightIntel AI Backend berjalan di http://localhost:${port}/api/v1`);
}

bootstrap();
