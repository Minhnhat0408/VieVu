import 'package:flutter/material.dart';
import 'package:vievu/features/search/domain/entities/explore_search_result.dart';

class CustomTextEditingController extends TextEditingController {
  List<ExploreSearchResult> searchResults = [];

  // Getter and setter for searchResults
  List<ExploreSearchResult> get selectedResults => searchResults;
  set selectedResults(List<ExploreSearchResult> results) {
    searchResults = results;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final String text = this.text;
    final List<TextSpan> spans = [];
    int start = 0;

    // Iterate over each search result to find and highlight its title
    for (final result in searchResults) {
      final String title = result.title;
      final int index = text.indexOf(title, start);

      if (index >= 0) {
        // Add unhighlighted text before the match
        if (index > start) {
          spans.add(TextSpan(
            text: text.substring(start, index),
            style: style,
          ));
        }
        // Add highlighted text
        spans.add(TextSpan(
          text: title,
          style: style?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ));
        // Update the start position
        start = index + title.length;
      }
    }

    // Add any remaining unhighlighted text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return TextSpan(children: spans, style: style);
  }
}
