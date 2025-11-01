import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '/db_helper.dart';
import 'package:intl/intl.dart'; // for formatting dates

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _eventController = TextEditingController();
  List<Map<String, dynamic>> _eventsForSelectedDay = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEventsForDay(_selectedDay);
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _loadEventsForDay(DateTime day) async {
    final date = _formatDate(day);
    final events = await _dbHelper.getEventsByDate(date);
    setState(() {
      _eventsForSelectedDay = events;
    });
  }

  Future<void> _addEvent() async {
    final text = _eventController.text.trim();
    if (text.isEmpty) return;

    final date = _formatDate(_selectedDay);
    await _dbHelper.insertEvent(date, text);
    _eventController.clear();
    _loadEventsForDay(_selectedDay);
  }

  Future<void> _deleteEvent(int id) async {
    await _dbHelper.deleteEvent(id);
    _loadEventsForDay(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadEventsForDay(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      labelText: 'Add event or rehearsal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addEvent,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _eventsForSelectedDay.isEmpty
                ? const Center(
                    child: Text('No events for this day 🩰'),
                  )
                : ListView.builder(
                    itemCount: _eventsForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final event = _eventsForSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(event['description']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteEvent(event['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
