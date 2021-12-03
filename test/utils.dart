import 'package:feathr/data/account.dart';
import 'package:feathr/services/api.dart';

/// Generates and returns a mocked API service instance for tests
ApiService getTestApiService() {
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
