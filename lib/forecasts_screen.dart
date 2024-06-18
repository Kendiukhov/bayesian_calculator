import 'package:flutter/material.dart';
import 'models/event.dart';
import 'package:intl/intl.dart';
import 'event_profile.dart';
import 'event_edit.dart';

class ForecastsScreen extends StatefulWidget {
  final List<Event> events;
  final Function(Event, bool) onResolveEvent;
  final Function(Event) onDeleteEvent;
  final Function(Event) onEditEvent;

  const ForecastsScreen({
    required this.events,
    required this.onResolveEvent,
    required this.onDeleteEvent,
    required this.onEditEvent,
    super.key,
  });

  @override
  _ForecastsScreenState createState() => _ForecastsScreenState();
}

class _ForecastsScreenState extends State<ForecastsScreen> {
  String _searchQuery = '';
  String _selectedImportance = 'All';
  String _selectedTag = 'All';
  String _selectedDeadline = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    List<Event> filteredEvents = widget.events.where((event) {
      bool matchesSearch = event.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesImportance = _selectedImportance == 'All' || event.importance == _selectedImportance;
      bool matchesTag = _selectedTag == 'All' || event.tags.contains(_selectedTag);
      bool matchesDeadline = true;
      if (_selectedDeadline == 'Within 24 hours') {
        matchesDeadline = event.resolutionDeadline != null &&
            event.resolutionDeadline!.isBefore(DateTime.now().add(const Duration(hours: 24)));
      } else if (_selectedDeadline == 'Within 7 days') {
        matchesDeadline = event.resolutionDeadline != null &&
            event.resolutionDeadline!.isBefore(DateTime.now().add(const Duration(days: 7)));
      }
      bool matchesStatus = _selectedStatus == 'All' ||
          (_selectedStatus == 'Opened' && event.resolved == null) ||
          (_selectedStatus == 'Closed' && event.resolved != null);
      return matchesSearch && matchesImportance && matchesTag && matchesDeadline && matchesStatus;
    }).toList();

    List<String> tags = ['All'] + widget.events.expand((e) => e.tags).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Forecasts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Search'),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Importance Level'),
                        value: _selectedImportance,
                        items: <String>['All', 'Low', 'Medium', 'High'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedImportance = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Tags'),
                        value: _selectedTag,
                        items: tags.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTag = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Deadline'),
                        value: _selectedDeadline,
                        items: <String>['All', 'Within 24 hours', 'Within 7 days'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDeadline = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Status'),
                        value: _selectedStatus,
                        items: <String>['All', 'Opened', 'Closed'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Probability: ${event.probability}'),
                      if (event.resolutionDeadline != null)
                        Text('Deadline: ${DateFormat.yMd().format(event.resolutionDeadline!)}'),
                      if (event.tags.isNotEmpty) Text('Tags: ${event.tags.join(', ')}'),
                      Text('Importance: ${event.importance}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final editedEvent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventEdit(
                                event: event,
                                onEditEvent: (updatedEvent) {
                                  widget.onEditEvent(updatedEvent);
                                },
                              ),
                            ),
                          );
                          if (editedEvent != null) {
                            setState(() {}); // Trigger a UI update
                          }
                        },
                      ),
                      if (event.resolved == null) ...[
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            widget.onResolveEvent(event, true);
                            setState(() {}); // Trigger a UI update
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            widget.onResolveEvent(event, false);
                            setState(() {}); // Trigger a UI update
                          },
                        ),
                      ] else
                        Icon(
                          event.resolved! ? Icons.check : Icons.close,
                          color: event.resolved! ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventProfile(
                          event: event,
                          onDeleteEvent: (deletedEvent) {
                            widget.onDeleteEvent(deletedEvent);
                            setState(() {}); // Trigger a UI update
                          },
                          onEditEvent: (updatedEvent) {
                            widget.onEditEvent(updatedEvent);
                            setState(() {}); // Trigger a UI update
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}