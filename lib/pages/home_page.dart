import 'package:flutter/material.dart';
import '../db_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _notes = [];
  final DBHelper _dbHelper = DBHelper();

  String _sortOrder = 'newest'; // or 'oldest'
  DateTimeRange? _dateFilter;

  void _addNote() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await _dbHelper.insertNote(text);
      _controller.clear();
      _loadNotes();
    }
  }

  Future<void> _loadNotes() async {
  final data = await _dbHelper.getNotes();
  setState(() {
    _notes.clear();
    _notes.addAll(data);
  });
  }

  void _showEditDialog(Map<String, dynamic> note) {
    final editController = TextEditingController(text: note['content']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit your note...',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {
                await _dbHelper.updateNote(note['id'], updatedText);
                _loadNotes();
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteNote(id);
              _loadNotes();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      // Sort notes
      if (_sortOrder == 'newest') {
        _notes.sort((a, b) => b['id'].compareTo(a['id']));
      } else {
        _notes.sort((a, b) => a['id'].compareTo(b['id']));
      }

      // Filter by date range (if selected)
      if (_dateFilter != null) {
        _notes.retainWhere((note) {
          final date = DateTime.tryParse(note['date']);
          return date != null &&
              date.isAfter(_dateFilter!.start.subtract(const Duration(days: 1))) &&
              date.isBefore(_dateFilter!.end.add(const Duration(days: 1)));
        });
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Newest first'),
            onTap: () {
              _sortOrder = 'newest';
              _applyFilters();
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Oldest first'),
            onTap: () {
              _sortOrder = 'oldest';
              _applyFilters();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDateFilter() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateFilter = picked);
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _dateFilter = null;
      _loadNotes();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bunhead Scribble')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Write your ballet notes:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type something...',
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _addNote, child: Text('Save Note')),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort),
                  label: Text('Sort (${_sortOrder == 'newest' ? 'Newest' : 'Oldest'})'),
                ),
                ElevatedButton.icon(
                  onPressed: _showDateFilter,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filter'),
                ),
                if (_dateFilter != null)
                  IconButton(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _notes.isEmpty
                  ? Center(
                      child: Text(
                        'No notes yet! Write your first scribble 🩰',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                    reverse: false,
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(note['content'], style: TextStyle(fontSize: 16)),
                          subtitle: Text(
                            note['date'],
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () => _showEditDialog(note),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(note['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}