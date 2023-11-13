class QueryResult {
  const QueryResult({
    required this.success,
    required this.failure,
    this.errorMessage,
    this.data,
    this.registersAffected,
    this.multiData,
  });

  factory QueryResult.successResult({
    Map<String, dynamic>? data,
    List<Map<String, dynamic>>? multiData,
    int? registersAffected,
  }) =>
      QueryResult(
          success: true,
          failure: false,
          data: data,
          multiData: multiData,
          registersAffected: registersAffected ?? 1);

  factory QueryResult.failureResult({
    required String errorMessage,
    final Map<String, dynamic>? data,
    final List<Map<String, dynamic>>? multiData,
  }) =>
      QueryResult(
        success: false,
        failure: true,
        errorMessage: errorMessage,
        data: data,
        multiData: multiData,
        registersAffected: 0,
      );

  final bool success;
  final bool failure;
  final String? errorMessage;
  final Map<String, dynamic>? data;
  final List<Map<String, dynamic>>? multiData;
  final int? registersAffected;
}
