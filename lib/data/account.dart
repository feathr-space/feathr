/// The [Account] class represents the information for a
/// given account.
// TODO: complete fields
class Account {
  /// ID of the account in the Mastodon instance.
  final String id;

  /// Username associated to the account.
  final String username;

  /// Display name associated to the account.
  final String displayName;

  /// Whether or not the account is locked.
  final bool isLocked;

  /// Whether or not the account is a bot
  final bool isBot;

  /// URL to the user's set avatar
  final String? avatarUrl;

  /// URL to the user's set header
  final String? headerUrl;

  Account(
      {required this.id,
      required this.username,
      required this.displayName,
      required this.isLocked,
      required this.isBot,
      this.avatarUrl,
      this.headerUrl});

  /// Given a Json-like [Map] with information for an account,
  /// build and return the respective [Account] instance.
  factory Account.fromJson(Map<String, dynamic> data) {
    return Account(
      id: data["id"]!,
      username: data["username"]!,
      displayName: data["display_name"]!,
      isLocked: data["locked"]!,
      isBot: data["bot"]!,
      avatarUrl: data["avatarUrl"],
      headerUrl: data["headerUrl"],
    );
  }
}
