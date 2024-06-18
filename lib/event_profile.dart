import 'package:flutter/material.dart';
import 'models/event.dart';
import 'event_edit.dart';
import 'package:intl/intl.dart';

class EventProfile extends StatelessWidget {
  final Event event;
  final Function(Event) onDeleteEvent;
  final Function(Event) onEditEvent;

  const EventProfile({
    required this.event,
    required this.onDeleteEvent,
    required this.onEditEvent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final editedEvent = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventEdit(
                    event: event,
                    onEditEvent: (updatedEvent) {
                      onEditEvent(updatedEvent);
                    },
                  ),
                ),
              );
              if (editedEvent != null) {
                onEditEvent(editedEvent); // Ensure the edited event is updated
                Navigator.pop(context); // Go back to the previous screen after editing
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${event.name}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text('Probability: ${event.probability}'),
            const SizedBox(height: 10),
            if (event.resolutionDeadline != null)
              Text('Deadline: ${DateFormat.yMd().format(event.resolutionDeadline!)}'),
            const SizedBox(height: 10),
            if (event.tags.isNotEmpty) Text('Tags: ${event.tags.join(', ')}'),
            const SizedBox(height: 10),
            Text('Importance: ${event.importance}'),
            const SizedBox(height: 10),
            if (event.description != null && event.description!.isNotEmpty)
              Text('Description: ${event.description}'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  onDeleteEvent(event);
                  Navigator.pop(context); // Go back to the previous screen after deleting
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: const Text('Delete Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}