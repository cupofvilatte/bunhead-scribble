import 'package:flutter/material.dart';
import '/db_helper.dart';

class ChoreographyPage extends StatefulWidget {
  const ChoreographyPage({super.key});

  @override
  _ChoreographyPageState createState() => _ChoreographyPageState();
}

class _ChoreographyPageState extends State<ChoreographyPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _choreoNotes = [];
  final List<Map<String, dynamic>> _searchResults = [];

  final DBHelper _dbHelper = DBHelper();

  Future<void> _loadChoreoNotes() async {
    // final db = await _dbHelper.database;
    final data = await _dbHelper.getChoreoNotes();
    setState(() {
      _choreoNotes
        ..clear()
        ..addAll(data);
    });
  }

  Future<void> _addChoreoNote() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await _dbHelper.insertChoreo(text);
      _controller.clear();
      _loadChoreoNotes();
    }
  }

  void _searchSteps(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }
    final results = await _dbHelper.searchSteps(query);
    setState(() {
      _searchResults
        ..clear()
        ..addAll(results);
    });
  }


  @override
  void initState() {
    super.initState();
    _loadChoreoNotes();
  }

  void _showEditDialog(Map<String, dynamic> note) {
    final editController = TextEditingController(text: note['content']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Choreography'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit choreography details...',
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
              final updated = editController.text.trim();
              if (updated.isNotEmpty) {
                await _dbHelper.updateChoreo(note['id'], updated);
                _loadChoreoNotes();
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
        title: Text('Delete Choreography'),
        content: Text('Are you sure you want to delete this choreography note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteChoreo(id);
              _loadChoreoNotes();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choreography Notes')),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('Write choreography ideas:', style: TextStyle(fontSize: 20)),
      const SizedBox(height: 12),
      TextField(
        controller: _controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Describe steps, sequences, or formations...',
        ),
        maxLines: null,
      ),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _addChoreoNote, child: const Text('Save')),
      const SizedBox(height: 16),

      const Text('Search ballet steps:', style: TextStyle(fontSize: 20)),
      const SizedBox(height: 8),
      TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Type a step name or category...',
        ),
        onChanged: _searchSteps,
      ),
      const SizedBox(height: 8),

      // Search results section
      if (_searchResults.isNotEmpty)
        Expanded(
          child: _buildSearchResults(),
        )
      else
        const SizedBox.shrink(),

      const SizedBox(height: 12),

      const Text('Your choreography notes:', style: TextStyle(fontSize: 20)),
      const SizedBox(height: 8),
      Expanded(child: _buildChoreoNotesList()),
    ],
  ),
),

    );
  }

  Widget _buildChoreoNotesList() {
    if (_choreoNotes.isEmpty) {
      return const Center(
        child: Text(
          'No choreography notes yet! Start creating 🩰',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      itemCount: _choreoNotes.length,
      itemBuilder: (context, index) {
        final note = _choreoNotes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(note['content'], style: const TextStyle(fontSize: 16)),
            subtitle: Text(
              note['date'],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => _showEditDialog(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(note['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final step = _searchResults[index];
        return Card(
          child: ListTile(
            title: Text(step['name']),
            subtitle: Text('${step['category']}\n${step['description']}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}