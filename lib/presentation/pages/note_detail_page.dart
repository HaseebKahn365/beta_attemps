import 'package:beta_attemps/core/theme/app_colos.dart';
import 'package:beta_attemps/domain/entities/note_entitiy.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_styles.dart';

class NoteDetailPage extends StatelessWidget {
  final NoteEntity note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: note.id,
              child: Text(
                note.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppStyles.noteTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              note.text,
              style: AppStyles.body.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
