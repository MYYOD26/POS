import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { describe, beforeEach, it } from 'node:test';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('should redirect to /api', () => {
      expect(appController.root()).toEqual({ url: '/api' });
    });
  });
});
