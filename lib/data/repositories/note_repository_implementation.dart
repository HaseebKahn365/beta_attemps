import 'package:beta_attemps/data/datasource/local_data/note_local_datasource.dart';
import 'package:beta_attemps/data/models/note.dart';
import 'package:beta_attemps/domain/entities/note_entitiy.dart';
import 'package:beta_attemps/domain/exceptions/exceptions.dart';
import 'package:beta_attemps/domain/failures/failures.dart';
import 'package:beta_attemps/domain/repositories/note_repo.dart';
import 'package:dartz/dartz.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource noteLocalDataSource;

  NoteRepositoryImpl({required this.noteLocalDataSource});

  @override
  Future<Either<Failure, List<NoteEntity>>> fetchNotes() async {
    try {
      final notes = await noteLocalDataSource.fetch();
      return Right(notes.map((note) => note.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> addNote(note) async {
    try {
      final noteToInsert = Note.fromEntity(note);
      await noteLocalDataSource.add(noteToInsert);
      return Right(note);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
}
