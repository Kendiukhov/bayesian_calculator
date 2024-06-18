import 'package:flutter/material.dart';
import 'models/event.dart';
import 'package:intl/intl.dart';

class EventEdit extends StatefulWidget {
  final Event event;
  final Function(Event) onEditEvent;

  const EventEdit({required this.event, required this.onEditEvent, super.key});

  @override
  _EventEditState createState() => _EventEditState();
}

class _EventEditState extends State<EventEdit> {
  final _formKey = GlobalKey<FormState>();
  late double _probability;
  DateTime? _resolutionDeadline;
  List<String> _tags = [];
  late String _importance;
  String? _description;

  @override
  void initState() {
    super.initState();
    _probability = widget.event.probability;
    _resolutionDeadline = widget.event.resolutionDeadline;
    _tags = List.from(widget.event.tags);
    _importance = widget.event.importance;
    _description = widget.event.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.event.name,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                  readOnly: true, // Make the event name field read-only
                ),
                TextFormField(
                  initialValue: _probability.toString(),
                  decoration: const InputDecoration(labelText: 'Probability'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a probability';
                    }
                    final prob = double.tryParse(value);
                    if (prob == null || prob < 0 || prob > 1) {
                      return 'Please enter a valid probability (0-1)';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _probability = double.parse(value!);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Resolution Deadline',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _resolutionDeadline != null
                              ? DateFormat.yMd().format(_resolutionDeadline!)
                              : 'No date chosen!',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _resolutionDeadline ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (date != null) {
                          setState(() {
                            _resolutionDeadline = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _tags.join(', '),
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                  onSaved: (value) {
                    _tags = value!.split(',').map((tag) => tag.trim()).toList();
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _importance,
                  decoration: const InputDecoration(labelText: 'Importance Level'),
                  items: <String>['Low', 'Medium', 'High'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _importance = newValue!;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final editedEvent = Event(
                          name: widget.event.name, // Use the original name
                          probability: _probability,
                          resolutionDeadline: _resolutionDeadline,
                          tags: _tags,
                          importance: _importance,
                          description: _description,
                          resolved: widget.event.resolved, // Preserve the resolved status
                        );
                        widget.onEditEvent(editedEvent);
                        Navigator.pop(context, editedEvent);
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}