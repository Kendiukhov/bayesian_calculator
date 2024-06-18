import 'package:flutter/material.dart';
import 'models/event.dart';

class EventDatabase extends StatefulWidget {
  final List<Event> events;
  final Function(Event, bool) onResolveEvent;

  const EventDatabase({required this.events, required this.onResolveEvent, super.key});

  @override
  _EventDatabaseState createState() => _EventDatabaseState();
}

class _EventDatabaseState extends State<EventDatabase> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.events.length,
        itemBuilder: (context, index) {
          final event = widget.events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text('Probability: ${event.probability}'),
            trailing: event.resolved == null
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    widget.onResolveEvent(event, true);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.onResolveEvent(event, false);
                  },
                ),
              ],
            )
                : Icon(
              event.resolved! ? Icons.check : Icons.close,
              color: event.resolved! ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }
}
