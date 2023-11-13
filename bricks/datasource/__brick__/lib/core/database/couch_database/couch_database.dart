import 'package:cbl/cbl.dart';
import 'package:uuid/uuid.dart';

import '../database_datasource.dart';
import '../query.dart';
import '../result.dart';
import 'filter_mapper.dart';

class CouchDatabaseDatasource implements DatabaseDatasource {
  @override
  Future<QueryResult> delete(String sourceName, dynamic id) async {
    try {
      final source = await _getFromSourceName(sourceName);
      final document = await source.document(id);
      if (document == null) {
        await source.close();
        return QueryResult.failureResult(errorMessage: "Document not found");
      }
      final success = await source.deleteDocument(document);
      await source.close();
      if (!success) {
        return QueryResult.failureResult(
          errorMessage:
              "Something went wrong when deleting document of id $id, from $sourceName database",
        );
      }
      return QueryResult.successResult(registersAffected: 1);
    } finally {
      final source = await _getFromSourceName(sourceName);

      await source.close();
    }
  }

  @override
  Future<QueryResult> get(GetQuery query) async {
    try {
      final source = await _getFromSourceName(query.sourceName);

      final String queryValue = query.value is List
          ? getListFormattedValue(query.value as List)
          : getFormatedValue(query.value);
      String queryString =
          'SELECT * FROM ${query.sourceName} WHERE ${query.operator == FilterOperator.like ? 'LOWER(${query.sourceName}.${query.fieldName})' : query.fieldName} ${query.operator.value} ${queryValue.toString()}';
      if (query.filters != null) {
        for (final filter in query.filters!) {
          queryString += CouchFilterMapper.parse(filter);
        }
      }
      if (query.orderBy != null) {
        queryString += " ORDER BY ${query.orderBy} ";
      }
      if (query.limit != null) {
        queryString += " LIMIT ${query.limit}";
      }
      final couchQuery = await AsyncQuery.fromN1ql(
        source,
        queryString,
      );
      final queryResult = await couchQuery.execute();

      final results = await _parseQueryResult(queryResult);
      await source.close();
      if (results.isEmpty) {
        return QueryResult.failureResult(
          errorMessage: CoreStringKeys.valueNotFoundDefaultException,
        );
      }

      return QueryResult.successResult(
        data: results.length == 1 ? results.first[query.sourceName] : null,
        multiData:
            results.map<JsonAnnotation>((e) => e[query.sourceName]).toList(),
      );
    } catch (e) {
      await _getFromSourceName(query.sourceName).then((db) => db.close());
      return QueryResult.failureResult(
        errorMessage:
            "Something went wrong querying ${query.fieldName} ${query.operator.value} ${query.value}, from ${query.sourceName}",
      );
    } finally {
      await _getFromSourceName(query.sourceName).then((db) => db.close());
    }
  }

  @override
  Future<QueryResult> getAll(String sourceName, [int? limit]) async {
    try {
      final source = await _getFromSourceName(sourceName);
      dynamic query = const QueryBuilder().selectAll([
        SelectResult.all(),
      ]).from(DataSource.database(source));
      if (limit != null) {
        query = query.limit(Expression.integer(limit));
      }
      final result = await query.execute();

      final results = await _parseQueryResult(result);
      await source.close();
      if (results.isEmpty) {
        return QueryResult.failureResult(
          errorMessage: CoreStringKeys.valueNotFoundDefaultException,
        );
      }
      return QueryResult.successResult(
        data: results.length == 1 ? results.first[sourceName] : null,
        multiData: results.map<JsonAnnotation>((e) => e[sourceName]).toList(),
      );
    } catch (e) {
      _getFromSourceName(sourceName).then((db) => db.close());
      return QueryResult.failureResult(
        errorMessage:
            "Something went wrong when getting all documents from $sourceName",
      );
    } finally {
      _getFromSourceName(sourceName).then((db) => db.close());
    }
  }

  @override
  Future<QueryResult> pop(PopQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<QueryResult> push(PushQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<QueryResult> save(SaveQuery query) async {
    try {
      final source = await _getFromSourceName(query.sourceName);
      final id = query.value["id"] ?? const Uuid().v4();
      final doc = MutableDocument.withId(
        id.toString(),
        {
          ...query.value,
          "id": id,
        },
      );
      final success = await source.saveDocument(
        doc,
      );
      await source.close();
      if (!success) {
        return QueryResult.failureResult(
          errorMessage:
              "Something went wrong when saving document ${query.value} to ${query.sourceName}",
        );
      }
      return QueryResult.successResult(
        data: doc.toPlainMap(),
        registersAffected: 1,
      );
    } catch (e) {
      return QueryResult.failureResult(
        errorMessage:
            "Something went wrong when saving document ${query.value} to ${query.sourceName}",
      );
    } finally {
      _getFromSourceName(query.sourceName).then((db) => db.close());
    }
  }

  @override
  Future<QueryResult> saveInBatch(List<SaveQuery> queries) async {
    try {
      if (queries.isEmpty) {
        return QueryResult.successResult(registersAffected: 0, multiData: []);
      }
      final List<JsonAnnotation> docs = [];
      int affectedDocs = 0;
      String errorMessage = "";
      final source = await _getFromSourceName(queries.first.sourceName);

      await source.inBatch(() async {
        for (var query in queries) {
          final id = query.value["id"] ?? const Uuid().v4();
          final data = {
            ...query.value,
            "id": id,
          };

          final doc = MutableDocument.withId(
            id.toString(),
            data,
          );

          final success = await source.saveDocument(
            doc,
          );

          if (!success) {
            errorMessage +=
                "Something went wrong when saving document ${query.value} to ${query.sourceName}\n";
            continue;
          }
          docs.add(
            doc.toPlainMap(),
          );
          affectedDocs += 1;
        }
      });
      await source.close();

      return QueryResult(
        success: affectedDocs > 0,
        failure: queries.length > affectedDocs,
        errorMessage: errorMessage.isNotEmpty ? errorMessage : null,
        registersAffected: affectedDocs,
        multiData: docs,
      );
    } finally {
      final source = await _getFromSourceName(queries.first.sourceName);
      await source.close();
    }
  }

  Future<List<JsonAnnotation>> _parseQueryResult(ResultSet result) async {
    return (await result.allResults())
        .map<JsonAnnotation>((e) => e.toPlainMap())
        .toList();
  }

  Future<AsyncDatabase> _getFromSourceName(String sourceName) async {
    final db = await Database.openAsync(
      sourceName,
    );
    return db;
  }

  String getListFormattedValue(List value) {
    return "[${(value).map((e) => e is String ? "'$e'" : "$e").join(",")}]";
  }

  String getFormatedValue(dynamic value) {
    return "${value is String ? "'" : ""}$value${value is String ? "'" : ""}";
  }

  @override
  Future<QueryResult> deleteQuery(GetQuery query) async {
    try {
      final source = await _getFromSourceName(query.sourceName);

      final getResult = await get(query);
      await source.inBatch(
        () async {
          try {
            for (var doc in getResult.multiData ?? []) {
              await source.deleteDocument(
                  MutableDocument.withId(doc["id"].toString(), doc));
            }
          } catch (e) {
            return;
          }
        },
      );
      await source.close();
      return QueryResult.successResult(
        registersAffected: getResult.multiData?.length,
      );
    } catch (e) {
      rethrow;
    } finally {
      final source = await _getFromSourceName(query.sourceName);

      await source.close();
    }
  }
}
