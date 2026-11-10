import 'dart:convert';

import 'package:http/http.dart' as http;

/// A short motivational quote returned by the DummyJSON REST API.
class FocusQuote {
  final String quote;
  final String author;

  const FocusQuote({required this.quote, required this.author});

  factory FocusQuote.fromJson(Map<String, dynamic> json) {
    final quote = json['quote'];
    final author = json['author'];
    if (quote is! String || author is! String) {
      throw const FormatException('The API response has an unexpected format.');
    }
    return FocusQuote(quote: quote, author: author);
  }
}

/// Performs an HTTP GET request and converts the JSON response into a model.
class FocusQuoteService {
  final http.Client _client;
  final bool _ownsClient;

  FocusQuoteService({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  Future<FocusQuote> fetchRandomQuote() async {
    final response = await _client.get(
      Uri.parse('https://dummyjson.com/quotes/random'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load a quote (HTTP ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The API response is not a JSON object.');
    }
    return FocusQuote.fromJson(decoded);
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
