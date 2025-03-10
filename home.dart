import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:notes_app/add_note.dart';
import 'package:notes_app/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [];

  final Map<String, Color> _priorityColors = {
    "High": Colors.red[400]!,
    "Medium": const Color.fromARGB(255, 221, 144, 0)!,
    "Low": Colors.green[400]!,
  };

  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getStringList('notes') ?? [];
    setState(() {
      _notes.addAll(
          notesData.map((note) => Note.fromJson(json.decode(note))).toList());
      _sortNotesByPriority();
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = _notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList('notes', notesData);
  }

  void _sortNotesByPriority() {
    _notes.sort((a, b) {
      const priorityOrder = {"High": 1, "Medium": 2, "Low": 3};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
  }

  void _addOrEditNote(Note? note) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (ctx) => AddNoteScreen(note: note),
    ))
        .then((result) {
      if (result != null) {
        setState(() {
          if (note != null) {
            final index = _notes.indexWhere((n) => n.id == note.id);
            _notes[index] = result;
          } else {
            _notes.add(result);
          }
          _sortNotesByPriority();
          _saveNotes();
        });
      }
    });
  }

  void _deleteSelectedNotes() {
    setState(() {
      _notes.removeWhere((note) => _selectedNoteIds.contains(note.id));
      _selectedNoteIds.clear();
      _isSelectionMode = false;
      _saveNotes();
    });
  }

  void _deleteNoteById(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
      _saveNotes();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedNoteIds.clear();
      }
    });
  }

  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _selectedNoteIds.isEmpty ? null : _deleteSelectedNotes,
            ),
          TextButton(
            onPressed: _toggleSelectionMode,
            child: Text(
              _isSelectionMode ? 'Cancel' : 'Select',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _notes.isEmpty
          ? Center(
              child: Text(
                'No notes added yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (ctx, index) {
                final note = _notes[index];
                final color = _priorityColors[note.priority]!;
                final isSelected = _selectedNoteIds.contains(note.id);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.8),
                          color.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              note.priority,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Divider(color: Colors.white70, thickness: 0.5),
                          ListTile(
                            title: Text(
                              note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onTap: _isSelectionMode
                                ? () => _toggleNoteSelection(note.id)
                                : null,
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _toggleSelectionMode();
                              }
                              _toggleNoteSelection(note.id);
                            },
                            trailing: _isSelectionMode
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (_) =>
                                        _toggleNoteSelection(note.id),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () => _addOrEditNote(note),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.white),
                                        onPressed: () =>
                                            _deleteNoteById(note.id),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            note.date.substring(0, 10),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _addOrEditNote(null),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
