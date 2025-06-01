import 'dart:developer';
import 'package:vievu/features/search/data/models/explore_search_result_model.dart';
import 'dart:math' as math; // For Math.log if you use a more standard IDF

// --- BM25Ranker Class Definition (Paste the BM25Ranker class here or import it) ---
// Conceptual BM25 implementation structure
class BM25Ranker {
  final List<String> _stopWords; // Consider making this configurable or language-specific
  final double k1;
  final double b;

  BM25Ranker({
    this.k1 = 1.5, // Typical value
    this.b = 0.75, // Typical value
    List<String>? stopWords,
  }) : _stopWords = stopWords ?? // Default English stop words, expand or make language-aware
            [
              'a', 'an', 'and', 'are', 'as', 'at', 'be', 'but', 'by', 'for', 'if', 'in',
              'into', 'is', 'it', 'no', 'not', 'of', 'on', 'or', 'such', 'that', 'the',
              'their', 'then', 'there', 'these', 'they', 'this', 'to', 'was', 'will', 'with',
              // Add Vietnamese stop words if needed, e.g., 'là', 'của', 'và', 'có', 'trong', 'để'
              // This list should be much more comprehensive for good results
            ];


  List<String> _tokenizeAndClean(String text) {
    if (text.isEmpty) return [];
    // Basic tokenization: lowercase, split by non-alphanumeric, remove stop words
    // This needs to be improved for different languages, especially Vietnamese.
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]+'))
        .where((token) => token.isNotEmpty && !_stopWords.contains(token))
        .toList();
  }

  List<ExploreSearchResultModel> rank({
    required String query,
    required List<ExploreSearchResultModel> documents,
  }) {
    if (documents.isEmpty) {
      log("BM25: No documents to rank.");
      return [];
    }

    final List<String> queryTerms = _tokenizeAndClean(query);
    if (queryTerms.isEmpty) {
      log("BM25: No query terms after cleaning.");
      return documents; // No specific ranking if query is empty after cleaning
    }
    log("BM25: Query terms: $queryTerms");

    final List<List<String>> tokenizedDocs = documents.map((doc) {
      final StringBuffer docTextBuffer = StringBuffer();
      if (doc.title.isNotEmpty) docTextBuffer.write('${doc.title} ');
      if (doc.address != null && doc.address!.isNotEmpty) docTextBuffer.write('${doc.address} ');
      // Add other relevant fields like tags, type, etc.
      // Example: if (doc.type != null) docTextBuffer.write('${doc.type} ');
      return _tokenizeAndClean(docTextBuffer.toString());
    }).toList();

    final int N = documents.length;
    double avgdl = 0;
    if (N > 0) {
        avgdl = tokenizedDocs.fold<int>(0, (sum, doc) => sum + doc.length) / N;
    }
    if (avgdl == 0) avgdl = 1.0; // Avoid division by zero

    final Map<String, double> idfScores = {};
    for (final term in queryTerms.toSet()) {
      int docFreq = tokenizedDocs.where((docTokens) => docTokens.contains(term)).length;
      // Standard IDF formula variant
      idfScores[term] = math.log((N - docFreq + 0.5) / (docFreq + 0.5) + 1.0);
    }
    log("BM25: IDF Scores: $idfScores");


    final List<double> docScores = List.filled(N, 0.0);
    for (int i = 0; i < N; i++) {
      final docTokens = tokenizedDocs[i];
      final docLength = docTokens.length;
      if (docLength == 0 && queryTerms.isNotEmpty) continue; // Skip empty docs if query exists

      double score = 0.0;
      for (final term in queryTerms) {
        if (!idfScores.containsKey(term) || idfScores[term]! <= 0) continue;

        int termFreqInDoc = docTokens.where((t) => t == term).length;
        if (termFreqInDoc == 0) continue;

        double termScore = idfScores[term]! *
            (termFreqInDoc * (k1 + 1)) /
            (termFreqInDoc + k1 * (1 - b + b * (docLength / avgdl)));
        score += termScore;
      }
      docScores[i] = score;
    }
    // log("BM25: Document Scores: $docScores");


    final List<MapEntry<ExploreSearchResultModel, double>> scoredDocuments = [];
    for (int i = 0; i < N; i++) {
      scoredDocuments.add(MapEntry(documents[i], docScores[i]));
    }

    // Filter out documents with a score of 0 if there are others with scores > 0
    // This can happen if none of the query terms match the document after cleaning.
    // bool hasPositiveScores = scoredDocuments.any((entry) => entry.value > 0);
    // List<MapEntry<ExploreSearchResultModel, double>> relevantScoredDocuments = scoredDocuments;
    // if(hasPositiveScores){
    //     relevantScoredDocuments = scoredDocuments.where((entry) => entry.value > 0).toList();
    // }


    scoredDocuments.sort((a, b) => b.value.compareTo(a.value));

    log("BM25: Ranked ${scoredDocuments.length} documents."); // Now logs the total number of documents
    return scoredDocuments.map((e) => e.key).toList();
  }
}