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

  List<String> selectedTags = [];
  final TextEditingController _tagInputController = TextEditingController();

  List<String> _tagFilter = [];

  void _addNote() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final noteId = await _dbHelper.insertNote(text);

      for (final tag in selectedTags) {
        final tagId = await _dbHelper.getTagIdOrCreate(tag);
        await _dbHelper.addTagToNote(noteId, tagId);
      }

      _controller.clear();
      selectedTags.clear();
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

  void _showEditDialog(Map<String, dynamic> note) async {
    final editController = TextEditingController(text: note['content']);
    _tagInputController.clear();

    final Set<String> selectedTagsSet = Set<String>.from(note['tags'] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder so the dialog UI can update independently
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // local selected set for dialog UI (starts from selectedTags)
            // final Set<String> selected = Set<String>.from(selectedTags);

            return AlertDialog(
              title: Text('Edit Note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Note text field
                    TextField(
                      controller: editController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Edit your note...',
                      ),
                      maxLines: null,
                    ),

                    const SizedBox(height: 20),

                    // TAGS SECTION
                    FutureBuilder<List<String>>(
                      future: _dbHelper.getAllTags(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: CircularProgressIndicator(),
                          );
                        }

                        final allTags = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            const Text(
                              "Tags",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // ADD NEW TAG FIELD
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagInputController,
                                    decoration: const InputDecoration(
                                      hintText: "Create new tag",
                                    ),
                                    onSubmitted: (value) async {
                                      value = value.trim();
                                      if (value.isEmpty) return;

                                      await _dbHelper.getTagIdOrCreate(value);
                                      setStateDialog(() {
                                        selectedTagsSet.add(value);
                                        _tagInputController.clear();
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    String value = _tagInputController.text
                                        .trim();
                                    if (value.isEmpty) return;

                                    await _dbHelper.getTagIdOrCreate(value);
                                    setStateDialog(() {
                                      selectedTagsSet.add(value);
                                      _tagInputController.clear();
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // TAG CHIPS
                            Wrap(
                              spacing: 8,
                              children: allTags.map((tag) {
                                final isSelected = selectedTagsSet.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isSelected,

                                  selectedColor: Colors.pink.shade300,
                                  backgroundColor: Colors.grey.shade200,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),

                                  onSelected: (value) {
                                    setStateDialog (() {
                                      if (value) {
                                        selectedTagsSet.add(tag);
                                      } else {
                                        selectedTagsSet.remove(tag);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedText = editController.text.trim();
                    if (updatedText.isNotEmpty) {
                      // Update note text
                      await _dbHelper.updateNote(note['id'], updatedText);

                      // Sync selected set into the page-level selectedTags
                      final selectedTags = selectedTagsSet.toList();

                      // Replace tags for this note
                      await _dbHelper.clearTagsForNote(note['id']);
                      for (final tag in selectedTags) {
                        final tagId = await _dbHelper.getTagIdOrCreate(tag);
                        await _dbHelper.addTagToNote(note['id'], tagId);
                      }

                      _loadNotes();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
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

  void _showTagFilterDialog() async {
    final allTags = await _dbHelper.getAllTags();
    final selected = Set<String>.from(_tagFilter);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by Tags'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            children: allTags.map((tag) {
              return FilterChip(
                label: Text(tag),
                selected: selected.contains(tag),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      selected.add(tag);
                    } else {
                      selected.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tagFilter = selected.toList();
                _applyFilters(); // refresh notes
              });
              Navigator.pop(context);
            },
            child: Text('Apply'),
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
              date.isAfter(
                _dateFilter!.start.subtract(const Duration(days: 1)),
              ) &&
              date.isBefore(_dateFilter!.end.add(const Duration(days: 1)));
        });
      }

      // Filter by tags
      if (_tagFilter.isNotEmpty) {
        _notes.retainWhere((note) {
          final noteTags = List<String>.from(note['tags'] ?? []);
          // Keep note if it has any of the selected tags
          return _tagFilter.any((tag) => noteTags.contains(tag));
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

void _showCombinedFilterDialog() async {
  final allTags = await _dbHelper.getAllTags();
  final selectedTagsSet = Set<String>.from(_tagFilter);

  DateTimeRange? tempDateRange = _dateFilter;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Filter Notes'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- DATE RANGE ---
                  ListTile(
                    title: Text(tempDateRange == null
                        ? 'Select Date Range'
                        : '${tempDateRange!.start.toLocal().toString().split(' ')[0]} - ${tempDateRange!.end.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: tempDateRange,
                      );
                      if (picked != null) {
                        setStateDialog(() => tempDateRange = picked); // now works
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- TAG FILTER ---
                  const Text('Filter by Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: allTags.map((tag) {
                      final isSelected = selectedTagsSet.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (value) {
                          setStateDialog(() {
                            if (value) {
                              selectedTagsSet.add(tag);
                            } else {
                              selectedTagsSet.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _dateFilter = tempDateRange;
                    _tagFilter = selectedTagsSet.toList();
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
                child: Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}


  void _clearFilters() {
    setState(() {
      _dateFilter = null;
      _tagFilter.clear();
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
                  label: Text(
                    'Sort (${_sortOrder == 'newest' ? 'Newest' : 'Oldest'})',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showCombinedFilterDialog,
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
                            title: Text(
                              note['content'],
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (note['tags'] != null && note['tags'].isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    children: (note['tags'] as List<String>).map((tag) {
                                      return Chip(
                                        label: Text(tag),
                                        backgroundColor: Colors.pink.shade100,
                                      );
                                    }).toList(),
                                  ),

                                const SizedBox(height: 4),

                                Text(
                                  note['date'],
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () => _showEditDialog(note),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
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
