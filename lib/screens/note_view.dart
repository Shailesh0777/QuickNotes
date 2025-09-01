import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteView extends StatelessWidget {
  const NoteView({
    super.key,
    required this.note,
    required this.index,
    required this.onNoteDeleted,
    required this.onNoteEdited,
  });

  final Note note;
  final int index;
  final Function(int) onNoteDeleted;
  final Function(Note) onNoteEdited;

  void _onMenuSelected(BuildContext context, String value) {
    if (value == 'delete') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete This ?"),
            content: Text("Note ${note.title} will be deleted!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNoteDeleted(index);
                  Navigator.of(context).pop();
                },
                child: const Text("DELETE"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("CANCEL"),
              )
            ],
          );
        },
      );
    }
    // You can add more menu options here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note View"),
        actions: [
          // Existing delete icon (optional, can remove if menu handles it)
          // IconButton(
          //   onPressed: () {
          //     _onMenuSelected(context, 'delete');
          //   },
          //   icon: const Icon(Icons.delete),
          // ),

          // Popup menu button
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
              // Add more items if needed
            ],
            icon: const Icon(Icons.more_vert), // three-dot icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Text(
              note.body,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
