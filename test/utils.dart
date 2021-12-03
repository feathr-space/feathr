import 'package:feathr/data/account.dart';
import 'package:feathr/services/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

setUpTestEnvVars() {
  dotenv.testLoad(fileInput: """
    OAUTH_CLIENT_ID=invalid-client-id
    OAUTH_CLIENT_SECRET=invalid-client-secret
    """);
}

getTestApiService() {
  setUpTestEnvVars();

  // TODO: mock for further tests
  final testService = ApiService();
  testService.currentAccount = Account(
    id: "123456",
    username: "username",
    displayName: "display name",
    acct: "username",
    isLocked: false,
    isBot: false,
  );
  return testService;
}
