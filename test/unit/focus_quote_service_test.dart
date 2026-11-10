import 'dart:convert';

import 'package:countdown_timer/services/focus_quote_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('FocusQuote API model and service tests', () {
    test('parses quote and author from JSON', () {
      final quote = FocusQuote.fromJson({
        'quote': 'Small steps lead to big changes.',
        'author': 'Test Author',
      });

      expect(quote.quote, 'Small steps lead to big changes.');
      expect(quote.author, 'Test Author');
    });

    test('HTTP GET response is decoded into a FocusQuote', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/quotes/random');
        return http.Response(
          jsonEncode({'quote': 'Keep going.', 'author': 'Ada'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = FocusQuoteService(client: client);

      final quote = await service.fetchRandomQuote();

      expect(quote.quote, 'Keep going.');
      expect(quote.author, 'Ada');
      client.close();
    });

    test('non-200 API response throws an exception', () async {
      final client = MockClient((request) async => http.Response('Unavailable', 503));
      final service = FocusQuoteService(client: client);

      expect(service.fetchRandomQuote(), throwsException);
      client.close();
    });

    test('unexpected JSON fields throw FormatException', () {
      expect(
        () => FocusQuote.fromJson({'message': 'missing quote fields'}),
        throwsFormatException,
      );
    });
  });
}
