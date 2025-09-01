import 'package:flutter/material.dart';
import '../db/note_database.dart';
import '../models/note_model.dart';
import 'create_note.dart';
import 'widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes(); // ✅ Load saved notes on app launch
  }

  void loadNotes() async {
    notes = await NoteDatabase.instance.readAllNotes();
    filteredNotes = List.from(notes);
    setState(() {});
  }
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredNotes = List.from(notes);
    });
  }

  void _filterNotes(String query) {
    setState(() {
      filteredNotes = notes
          .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void onNewNoteCreated(Note note) {
    setState(() {
      notes.add(note);
      filteredNotes = List.from(notes);
    });
  }

  void onNoteDeleted(int index) {
    setState(() {
      notes.removeAt(index);
      filteredNotes = List.from(notes);
    });
  }

  void onNoteEdited(Note updatedNote) {
    setState(() {
      final i = notes.indexWhere((n) => n.id == updatedNote.id);
      if (i != -1) {
        notes[i] = updatedNote;
      }
      filteredNotes = List.from(notes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _stopSearch,
            ),
          ),
          onChanged: _filterNotes,
        )
            : const Text("Flutter Notes"),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
          if (!_isSearching)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'about') {
                  showAboutDialog(
                    context: context,
                    applicationName: 'QuickNotes',
                    applicationVersion: 'Version: 1.0.0',
                    applicationLegalese: '© 2025 Shailesh Paudel',
                  );
                } else if (value == 'clear_all') {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Clear All Notes"),
                      content: const Text("Are you sure you want to delete all notes?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              notes.clear();
                              filteredNotes.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Clear All", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'about', child: Text('About')),
                const PopupMenuItem(value: 'clear_all', child: Text('Clear All Notes')),
              ],
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: filteredNotes.isEmpty
          ? const Center(child: Text("No notes found."))
          : ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: filteredNotes[index],
            index: index,
            onNoteDeleted: onNoteDeleted,
            onNoteEdit: onNoteEdited,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateNote(
                onNewNoteCreated: (newNote) {
                  onNewNoteCreated(newNote);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
