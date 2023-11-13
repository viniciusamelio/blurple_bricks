import '../../core.dart';

abstract class CouchFilterMapper {
  static String parse(AggregateFilter filter) {
    var value = filter.value;
    if (filter.value is List) {
      value = _getListFormattedValue(value);
    }
    String preffix = filter.addInitialParentheses ? "(" : "";
    String suffix = filter.addFinalParentheses ? ")" : "";
    if (filter is AndFilter) {
      return " AND  $preffix ${filter.fieldName} ${filter.operator.value} ${[
        int,
        bool,
        List,
        List<int>,
        List<String>,
      ].contains(filter.value.runtimeType) ? value : "'$value'"} $suffix";
    }
    return " OR $preffix  ${filter.fieldName} ${filter.operator.value}  ${[
      int,
      bool,
      List,
      List<int>,
      List<String>,
    ].contains(filter.value.runtimeType) ? value : "'$value'"} $suffix";
  }

  static String _getListFormattedValue(List value) {
    return "[${(value).map((e) => e is String ? "'$e'" : "$e").join(",")}]";
  }
}
