import 'package:feathr/data/account.dart';

/// The [Status] class represents information for a given status (toot)
/// made in a Mastodon instance.
///
/// reference: https://docs.joinmastodon.org/entities/status/
/// TODO: fill in all necessary fields
class Status {
  /// ID of the status in the Mastodon instance it belongs to
  final String id;

  /// Main content of the status, in HTML format
  final String content;

  /// [Account] instance of the user that created this status
  final Account account;

  Status({required this.id, required this.content, required this.account});

  /// Given a Json-like [Map] with information for a status,
  /// build and return the respective [Status] instance.
  factory Status.fromJson(Map<String, dynamic> data) {
    return Status(
      id: data["id"]!,
      content: data["content"]!,
      account: Account.fromJson(data["account"]!),
    );
  }
}
