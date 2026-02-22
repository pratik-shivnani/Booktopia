import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  return WebDatabase('booktopia_db');
}
