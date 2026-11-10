import 'package:flutter/material.dart';

import '../services/focus_quote_service.dart';

/// Experiment 9: demonstrates an HTTP GET request, JSON parsing and UI output.
class ApiQuoteScreen extends StatefulWidget {
  static const routeName = '/api-quote';

  const ApiQuoteScreen({super.key});

  @override
  State<ApiQuoteScreen> createState() => _ApiQuoteScreenState();
}

class _ApiQuoteScreenState extends State<ApiQuoteScreen> {
  late final FocusQuoteService _service;
  late Future<FocusQuote> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _service = FocusQuoteService();
    _quoteFuture = _service.fetchRandomQuote();
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  void _loadAnotherQuote() {
    setState(() {
      _quoteFuture = _service.fetchRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('REST API – Focus Quote')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('A little focus inspiration',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FutureBuilder<FocusQuote>(
                      future: _quoteFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Column(
                            children: [
                              const Icon(Icons.cloud_off_outlined, size: 36),
                              const SizedBox(height: 8),
                              Text('Could not load data: ${snapshot.error}',
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _loadAnotherQuote,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again'),
                              ),
                            ],
                          );
                        }

                        final quote = snapshot.data!;
                        return Column(
                          children: [
                            Text('“${quote.quote}”',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text('— ${quote.author}',
                                style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _loadAnotherQuote,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Load another quote'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Source: dummyjson.com/quotes/random  •  HTTP GET + JSON',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
