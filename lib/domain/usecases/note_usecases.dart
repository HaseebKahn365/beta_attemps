import 'package:beta_attemps/domain/entities/note_entitiy.dart';
import 'package:beta_attemps/domain/failures/failures.dart';
import 'package:beta_attemps/domain/repositories/note_repo.dart';
import 'package:dartz/dartz.dart';

class FetchNote {
  final NoteRepository repository;

  FetchNote(this.repository);

  Future<Either<Failure, List<NoteEntity>>> execute() =>
      repository.fetchNotes();
}
