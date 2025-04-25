import 'package:beta_attemps/data/datasource/local_data/database_helper.dart';
import 'package:beta_attemps/data/models/note.dart';

abstract class NoteLocalDataSource {
  Future<List<Note>> fetch();
  Future<Note> add(Note note);
  Future<int?> delete(int noteId);
  Future<int?> update(Note note);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Future<Note> add(Note note) => _databaseHelper.add(note);

  @override
  Future<List<Note>> fetch() => _databaseHelper.fetch();

  @override
  Future<int?> update(Note note) => _databaseHelper.update(note);

  @override
  Future<int?> delete(int noteId) => _databaseHelper.delete(noteId);
}
