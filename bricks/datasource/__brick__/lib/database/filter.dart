import 'query.dart';

abstract class AggregateFilter {
  AggregateFilter({
    required this.operator,
    required this.value,
    required this.fieldName,
    this.addInitialParentheses = false,
    this.addFinalParentheses = false,
  });
  final FilterOperator operator;
  final dynamic value;
  final String fieldName;
  final bool addInitialParentheses;
  final bool addFinalParentheses;

  factory AggregateFilter.and({
    required FilterOperator operator,
    required value,
    required String fieldName,
    bool? addInitialParentheses,
    bool? addFinalParentheses,
  }) =>
      AndFilter(
        fieldName: fieldName,
        value: value,
        operator: operator,
        addFinalParentheses: addFinalParentheses ?? false,
        addInitialParentheses: addInitialParentheses ?? false,
      );

  factory AggregateFilter.or({
    required FilterOperator operator,
    required value,
    required String fieldName,
    bool? addInitialParentheses,
    bool? addFinalParentheses,
  }) =>
      OrFilter(
        fieldName: fieldName,
        value: value,
        operator: operator,
        addFinalParentheses: addFinalParentheses ?? false,
        addInitialParentheses: addInitialParentheses ?? false,
      );
}

class AndFilter<T> implements AggregateFilter {
  @override
  final String fieldName;

  @override
  final FilterOperator operator;

  @override
  final T value;

  AndFilter({
    required this.fieldName,
    required this.operator,
    required this.value,
    this.addInitialParentheses = false,
    this.addFinalParentheses = false,
  });

  @override
  final bool addFinalParentheses;

  @override
  final bool addInitialParentheses;
}

class OrFilter<T> implements AggregateFilter {
  @override
  final String fieldName;

  @override
  final FilterOperator operator;

  @override
  final T value;

  OrFilter({
    required this.fieldName,
    required this.operator,
    required this.value,
    this.addInitialParentheses = false,
    this.addFinalParentheses = false,
  });
  @override
  final bool addFinalParentheses;

  @override
  final bool addInitialParentheses;
}
