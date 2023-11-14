import 'filter.dart';

enum FilterOperator {
  greaterThan(">"),
  equalsOrGreaterThan(">="),
  lesserThan("<"),
  equalsOrLesserThan("<="),
  notEqualsTo("!="),
  like("LIKE"),
  inValues("IN"),
  notInValues("NOT IN"),
  equalsTo("=");

  final String value;
  const FilterOperator(this.value);
}

abstract class DatabaseQuery {
  DatabaseQuery({
    required this.sourceName,
  });

  final String sourceName;
}

class GetQuery<T> implements DatabaseQuery {
  GetQuery({
    required this.sourceName,
    required this.value,
    required this.fieldName,
    this.operator = FilterOperator.equalsTo,
    this.filters,
    this.singleResult = true,
    this.limit,
    this.orderBy,
  });

  @override
  final String sourceName;

  final FilterOperator operator;
  final String fieldName;
  final T value;

  final bool singleResult;

  final List<AggregateFilter>? filters;

  final int? limit;

  final String? orderBy;

  GetQuery<T> copyWith({
    String? sourceName,
    FilterOperator? operator,
    String? fieldName,
    T? value,
    bool? singleResult,
    List<AggregateFilter>? filters,
    int? limit,
  }) {
    return GetQuery<T>(
      sourceName: sourceName ?? this.sourceName,
      operator: operator ?? this.operator,
      fieldName: fieldName ?? this.fieldName,
      value: value ?? this.value,
      singleResult: singleResult ?? this.singleResult,
      filters: filters ?? this.filters,
      limit: limit ?? this.limit,
    );
  }
}

class SaveQuery implements DatabaseQuery {
  SaveQuery({
    required this.sourceName,
    required this.value,
    this.id,
  });

  @override
  final String sourceName;
  final Map<String, dynamic> value;
  final String? id;
}

class PushQuery implements DatabaseQuery {
  PushQuery({
    required this.sourceName,
    required this.value,
    required this.id,
    required this.field,
  });

  @override
  final String sourceName;
  final dynamic value;
  final String id;
  final String field;
}

class PopQuery extends PushQuery {
  PopQuery({
    required super.sourceName,
    required super.value,
    required super.id,
    required super.field,
  });
}
