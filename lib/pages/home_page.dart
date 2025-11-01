import 'package:flutter/material.dart';
import '../db_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _notes = [];
  final DBHelper _dbHelper = DBHelper();

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
    _notes.addAll(data.map((item) => item['content'] as String));
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
            Expanded(
              child: _notes.isEmpty
                  ? Center(
                      child: Text(
                        'No notes yet! Write your first scribble 🩰',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _notes[index],
                              style: TextStyle(fontSize: 16),
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