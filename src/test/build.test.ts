import { test } from 'ava';
import * as sinon from 'sinon';

import { MockRobot, MockRobotBrain, MockResponse, MockScopedHttpClient, MockSlackAdapter } from './helpers/mocks';
import { IHttpClientHandler } from 'hubot';
import * as express from 'express';
import { Config } from '../lib/config';
import BuildScript from '../lib/build';

test('finbot > starts a build', (t) => {
  // arrange
  Config.appveyor.token = '12345';
  Config.appveyor.account = 'some account';

  const projectSlug = 'a project slug';

  const robot = new MockRobot();
  const respondStub = sinon.stub(robot, 'respond');

  const robotBrain = new MockRobotBrain();
  robot.brain = robotBrain;
  const brainSetSpy = sinon.spy(robotBrain, 'set');

  const robotRouter = express();
  robot.router = robotRouter;
  
  const response = new MockResponse();
  const replyStub = sinon.stub(response, 'reply');

  response.match = [null, projectSlug];
  response.message = {
    room: 'a room',
    user: {
      name: 'a name'
    }
  };

  const slackAdapter = new MockSlackAdapter();
  const customMessageSpy = sinon.spy(slackAdapter, 'customMessage');
  
  robot.adapter = slackAdapter;

  const httpClient = new MockScopedHttpClient();
  const headerSpy = sinon.spy(httpClient, 'header');
  const httpStub = sinon.stub(robot, 'http');

  httpStub.returns(httpClient);

  const postStub = sinon.stub(httpClient, 'post');

  postStub.returns((handler: IHttpClientHandler) => {
    handler(null, { statusCode: 200 }, '{"version":"this is a version"}');
  });

  respondStub.callsArgWith(1, response);

  // act
  BuildScript(robot);

  // assert
  t.true(respondStub.calledWith(/start build (.*)/i, sinon.match.func));
  t.true(replyStub.calledWith('One moment please...'));
  t.true(httpStub.calledWith('https://ci.appveyor.com/api/builds'));
  t.true(headerSpy.calledWith('Authorization', `Bearer ${Config.appveyor.token}`));
  t.true(headerSpy.calledWith('Content-Type', 'application/json'));
  t.true(headerSpy.calledWith('Accept', 'application/json'));
  t.true(postStub.calledWith(`{"accountName":"${Config.appveyor.account}","projectSlug":"${projectSlug}"}`));
});