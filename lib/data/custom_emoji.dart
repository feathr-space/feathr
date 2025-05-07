/// The [CustomEmoji] class represents a custom emoji that can be used in
/// Mastodon statuses.
class CustomEmoji {
  /// The shortcode of the custom emoji.
  final String shortcode;

  /// The URL of the custom emoji.
  final String url;

  /// The static URL of the custom emoji.
  final String staticUrl;

  CustomEmoji({
    required this.shortcode,
    required this.url,
    required this.staticUrl,
  });

  /// Creates a [CustomEmoji] instance from a JSON object.
  factory CustomEmoji.fromJson(Map<String, dynamic> json) {
    return CustomEmoji(
      shortcode: json['shortcode'] as String,
      url: json['url'] as String,
      staticUrl: json['static_url'] as String,
    );
  }
}
