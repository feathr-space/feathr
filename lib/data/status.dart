import 'dart:ui';

import 'package:feathr/data/account.dart';
import 'package:feathr/data/custom_emoji.dart';
import 'package:relative_time/relative_time.dart';

/// The [StatusVisibility] enum represents the visibility of a status
/// in a Mastodon instance.
enum StatusVisibility { public, unlisted, private }

/// The [Status] class represents information for a given status (toot)
/// made in a Mastodon instance.
///
/// reference: https://docs.joinmastodon.org/entities/status/
/// TODO: fill in all necessary fields
class Status {
  /// ID of the status in the Mastodon instance it belongs to
  final String id;

  /// Datetime when the status was created
  final DateTime createdAt;

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

  // If this status is a reblog, the reblogged status content will be available here
  final Status? reblog;

  // Amount of times ths status has been favorited
  final int favouritesCount;

  // Amount of times this status has been reblogged
  final int reblogsCount;

  // Amount of replies to this status
  final int repliesCount;

  // Status visibility
  final StatusVisibility visibility;

  // Spoiler text (content warning)
  final String spoilerText;

  // Custom emojis
  final List<CustomEmoji> customEmojis;

  Status({
    required this.id,
    required this.createdAt,
    required this.content,
    required this.account,
    required this.favorited,
    required this.reblogged,
    required this.bookmarked,
    required this.favouritesCount,
    required this.reblogsCount,
    required this.repliesCount,
    required this.visibility,
    required this.spoilerText,
    required this.customEmojis,
    this.reblog,
  });

  /// Given a Json-like [Map] with information for a status,
  /// build and return the respective [Status] instance.
  factory Status.fromJson(Map<String, dynamic> data) {
    return Status(
      id: data["id"]!,
      createdAt: DateTime.parse(data["created_at"]!),
      content: data["content"]!,
      account: Account.fromJson(data["account"]!),
      favorited: data["favourited"]!,
      reblogged: data["reblogged"]!,
      bookmarked: data["bookmarked"]!,
      favouritesCount: data["favourites_count"]!,
      reblogsCount: data["reblogs_count"]!,
      repliesCount: data["replies_count"]!,
      visibility: StatusVisibility.values.byName(data["visibility"]!),
      spoilerText: data["spoiler_text"]!,
      reblog: data["reblog"] == null ? null : Status.fromJson(data["reblog"]),
      customEmojis:
          ((data["emojis"] ?? []) as List)
              .map(
                (emoji) => CustomEmoji.fromJson(emoji as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  /// Returns the processed and augmented content of the [Status] instance,
  /// including a note about the reblogged status if applicable,
  /// and replacing custom emojis with their respective HTML tags.
  String getContent() {
    // If this status is a reblog, show the original user's account name
    if (reblog != null) {
      // TODO: display original user's avatar on reblogs
      return "Reblogged from ${reblog!.account.acct}: ${reblog!.getContent()}";
    }

    String processedContent = content;

    // Replacing custom emojis with their respective HTML tags
    for (var emoji in customEmojis) {
      processedContent = processedContent.replaceAll(
        ":${emoji.shortcode}:",
        '<img src="${emoji.staticUrl}" alt="${emoji.shortcode}" />',
      );
    }

    return processedContent;
  }

  String getRelativeDate() {
    // TODO: set up localization for the app
    return createdAt.relativeTimeLocale(const Locale('en'));
  }
}
