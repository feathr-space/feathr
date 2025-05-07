import 'package:flutter_test/flutter_test.dart';

import 'package:feathr/data/custom_emoji.dart';

void main() {
  group('CustomEmoji', () {
    test('constructor creates an instance with the correct properties', () {
      const shortcode = 'thinking';
      const url = 'https://example.com/emoji/thinking.gif';
      const staticUrl = 'https://example.com/emoji/thinking.png';

      final emoji = CustomEmoji(
        shortcode: shortcode,
        url: url,
        staticUrl: staticUrl,
      );

      expect(emoji.shortcode, shortcode);
      expect(emoji.url, url);
      expect(emoji.staticUrl, staticUrl);
    });

    test('fromJson creates a CustomEmoji from a valid JSON map', () {
      final jsonMap = {
        'shortcode': 'party',
        'url': 'https://example.com/emoji/party.gif',
        'static_url': 'https://example.com/emoji/party.png',
      };

      final emoji = CustomEmoji.fromJson(jsonMap);

      expect(emoji.shortcode, 'party');
      expect(emoji.url, 'https://example.com/emoji/party.gif');
      expect(emoji.staticUrl, 'https://example.com/emoji/party.png');
    });

    test('fromJson correctly handles JSON keys', () {
      final jsonMap = {
        'shortcode': 'smile',
        'url': 'https://mastodon.example/emoji/smile.gif',
        'static_url': 'https://mastodon.example/emoji/smile.png',
        'additional_field': 'should be ignored',
      };

      final emoji = CustomEmoji.fromJson(jsonMap);

      expect(emoji.shortcode, 'smile');
      expect(emoji.url, 'https://mastodon.example/emoji/smile.gif');
      expect(emoji.staticUrl, 'https://mastodon.example/emoji/smile.png');
    });
  });
}
