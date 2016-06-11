import { IRobot, IRobotBrain, IListener, IResponse, IMessageDetail } from 'hubot';
import { Application } from 'express';

export class MockRobot implements IRobot {
  public adapter: any;
  public brain: IRobotBrain;
  public router: Application;

  public respond(matcher: RegExp, listener: IListener) {}
  public http(url: string) { return null; }
  public messageRoom(room: string, msg: string) {}
}

export class MockResponse implements IResponse {
  public match: string[];
  public message: IMessageDetail;

  public reply(msg: string) {}
}