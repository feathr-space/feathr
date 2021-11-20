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
  return ApiService();
}
