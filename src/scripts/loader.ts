import { install } from 'source-map-support';
install();

import { IRobot } from 'hubot';
import HelloScript from '../lib/hello';
import BuildScript from '../lib/build';

module.exports = (robot: IRobot) => {
  HelloScript(robot);
  BuildScript(robot);
};