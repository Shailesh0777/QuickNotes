import 'package:flutter/material.dart';
import '../db/note_database.dart';
import '../models/note_model.dart';

class CreateNote extends StatefulWidget {
  final Function(Note) onNewNoteCreated;
  final Note? existingNote;

  const CreateNote({
    super.key,
    required this.onNewNoteCreated,
    this.existingNote,
  });

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _bodyController = TextEditingController(text: widget.existingNote?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title can't be empty")),
      );
      return;
    }

    Note note;

    if (widget.existingNote == null) {
      // ✅ Insert new note
      note = Note(title: title, body: body);
      final id = await NoteDatabase.instance.insert(note);
      note = note.copyWith(id: id);
    } else {
      // ✅ Update existing note
      note = widget.existingNote!.copyWith(title: title, body: body);
      await NoteDatabase.instance.update(note);
    }

    widget.onNewNoteCreated(note); // ⤴️ Return it to UI
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Create Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveNote,
        child: Icon(isEditing ? Icons.check : Icons.save),
        tooltip: isEditing ? 'Update' : 'Save',
      ),
    );
  }
}
