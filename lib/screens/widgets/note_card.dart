import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../note_view.dart';
import '../create_note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.onNoteDeleted,
    required this.onNoteEdit,
  });

  final Note note;
  final int index;
  final Function(int) onNoteDeleted;
  final Function(Note) onNoteEdit;

  void _handleMenuAction(BuildContext context, String value) {
    if (value == 'edit') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateNote(
            existingNote: note,
            onNewNoteCreated: (updatedNote) {
              onNoteEdit(updatedNote);
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } else if (value == 'delete') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Note'),
          content: Text("Delete '${note.title}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onNoteDeleted(index);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteView(
              note: note,
              index: index,
              onNoteDeleted: onNoteDeleted,
              onNoteEdited: onNoteEdit, // ✅ Forward edit callback
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
