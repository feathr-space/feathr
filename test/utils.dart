import 'package:flutter_dotenv/flutter_dotenv.dart';

setUpTestEnvVars() {
  dotenv.testLoad(fileInput: """
    OAUTH_CLIENT_ID=invalid-client-id
    OAUTH_CLIENT_SECRET=invalid-client-secret
    """);
}
