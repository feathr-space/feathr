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

  /// Whether or not the user has favorited this status
  final bool favorited;

  /// Whether or not the user has reblogged (boosted, retooted) this status
  final bool reblogged;

  /// Whether or not the user has bookmarked this status
  final bool bookmarked;

  Status({
    required this.id,
    required this.content,
    required this.account,
    required this.favorited,
    required this.reblogged,
    required this.bookmarked,
  });

  /// Given a Json-like [Map] with information for a status,
  /// build and return the respective [Status] instance.
  factory Status.fromJson(Map<String, dynamic> data) {
    return Status(
      id: data["id"]!,
      content: data["content"]!,
      account: Account.fromJson(data["account"]!),
      favorited: data["favourited"]!,
      reblogged: data["reblogged"]!,
      bookmarked: data["bookmarked"]!,
    );
  }
}
