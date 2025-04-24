import 'package:beta_attemps/domain/entities/note_entitiy.dart';
import 'package:beta_attemps/domain/failures/failures.dart';
import 'package:dartz/dartz.dart';

abstract class NoteRepository {
  Future<Either<Failure, NoteEntity>> addNote(NoteEntity note);
  Future<Either<Failure, List<NoteEntity>>> fetchNotes();
}
