export * from './base';
export * from './organization/orgApi';
export * from './user/userApi';
export * from './topic/topicApi';

import { unwrap, toPage } from './base';
import * as org from './organization/orgApi';
import * as user from './user/userApi';
import * as topic from './topic/topicApi';

const assistantService = {
  unwrap, toPage,
  ...org,
  ...user,
  ...topic,
};

export default assistantService;