import 'package:beta_attemps/domain/entities/note_entitiy.dart';
import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {}

class FetchNotes extends NoteEvent {
  @override
  List<Object> get props => [];
}

class FetchNotesAfterAddingEvent extends NoteEvent {
  @override
  List<Object> get props => [];
}

class AddNoteEvent extends NoteEvent {
  final NoteEntity note;

  AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends NoteEvent {
  final NoteEntity note;

  UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NoteEvent {
  final NoteEntity note;

  DeleteNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}
