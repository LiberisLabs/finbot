import { IRobot } from 'hubot';
import HelloScript from '../lib/hello';

module.exports = (robot: IRobot) => {
  HelloScript(robot);
};