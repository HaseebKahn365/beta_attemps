import 'package:beta_attemps/core/theme/app_colos.dart';
import 'package:beta_attemps/core/theme/app_styles.dart';
import 'package:beta_attemps/presentation/bloc/note_bloc.dart';
import 'package:beta_attemps/presentation/bloc/note_event.dart';
import 'package:beta_attemps/presentation/bloc/note_state.dart';
import 'package:beta_attemps/presentation/pages/add_note_page.dart';
import 'package:beta_attemps/presentation/widgets/display_notes.dart';
import 'package:beta_attemps/presentation/widgets/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NoteBloc>().add(FetchNotes()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddNotePage(note: null),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            buildAppBar(),
            const SizedBox(height: 16),
            buildBody(),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notes',
            style: AppStyles.title.copyWith(fontSize: 32),
          ),
          MyIconButton(
            onTap: () {},
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is LoadingNoteState) {
              return const CircularProgressIndicator();
            } else if (state is NoteLoadedState) {
              return SingleChildScrollView(
                child: DisplayNotes(notes: state.notes),
              );
            } else if (state is LoadedNoteAfterAddingState) {
              return SingleChildScrollView(
                child: DisplayNotes(notes: state.notes),
              );
            } else if (state is NoteErrorState) {
              return Center(
                child: Text('Error loading notes: ${state.message}'),
              );
            } else {
              return const Center(
                child: Text('Unknown state'),
              );
            }
          },
        ),
      ),
    );
  }
}
