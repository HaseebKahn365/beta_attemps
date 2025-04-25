import 'package:beta_attemps/data/datasource/local_data/note_local_datasource.dart';
import 'package:beta_attemps/data/repositories/note_repository_implementation.dart';
import 'package:beta_attemps/domain/repositories/note_repo.dart';
import 'package:beta_attemps/domain/usecases/note_usecases.dart';
import 'package:beta_attemps/presentation/bloc/note_bloc.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

Future<void> init() async {
  //registerning a factory for the note bloc class

  locator.registerFactory(() => NoteBloc(
        locator<FetchNote>(),
        locator<AddNote>(),
      ));

  locator.registerLazySingleton(() => FetchNote(locator()));

  locator.registerLazySingleton(() => AddNote(locator()));

  locator.registerLazySingleton<NoteRepository>(
      () => NoteRepositoryImpl(noteLocalDataSource: locator()));

  locator.registerLazySingleton<NoteLocalDataSource>(
      () => NoteLocalDataSourceImpl());
}
