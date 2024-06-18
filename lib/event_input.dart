import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'add_tag_popup.dart'; // Import the new add tag popup widget
import 'add_description_popup.dart'; // Import the new add description popup widget

class EventInput extends StatefulWidget {
  final Function(String, double, DateTime?, List<String>, String, String?) onAddEvent;
  final List<String> tags;
  final Function(String) onAddTag;

  const EventInput({required this.onAddEvent, required this.tags, required this.onAddTag, super.key});

  @override
  _EventInputState createState() => _EventInputState();
}

class _EventInputState extends State<EventInput> {
  final TextEditingController eventController = TextEditingController();
  final TextEditingController probabilityController = TextEditingController();
  DateTime? _selectedDate;
  List<String> _selectedTags = [];
  String _importance = 'Medium';
  String? _description;

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddTagPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTagPopup(
          onAddTag: (String newTag) {
            setState(() {
              widget.onAddTag(newTag);
              _selectedTags.add(newTag);
            });
          },
        );
      },
    );
  }

  void _showAddDescriptionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDescriptionPopup(
          onAddDescription: (String description) {
            setState(() {
              _description = description;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: eventController,
            decoration: const InputDecoration(
              labelText: 'Event',
              hintText: 'Enter the event name',
            ),
          ),
          TextField(
            controller: probabilityController,
            decoration: const InputDecoration(
              labelText: 'Probability',
              hintText: 'Enter the probability (0-1)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          const Text('Resolution Deadline (optional):'),
          Row(
            children: <Widget>[
              Text(_selectedDate == null
                  ? 'No date chosen!'
                  : DateFormat.yMd().format(_selectedDate!)),
              TextButton(
                onPressed: _pickDate,
                child: const Text('Choose Date'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Tags (optional):'),
                    DropdownButton<String>(
                      hint: const Text('Select a tag'),
                      isExpanded: true,
                      items: widget.tags.map((String tag) {
                        return DropdownMenuItem<String>(
                          value: tag,
                          child: Text(tag),
                        );
                      }).toList(),
                      onChanged: (String? newTag) {
                        setState(() {
                          if (newTag != null && !_selectedTags.contains(newTag)) {
                            _selectedTags.add(newTag);
                          }
                        });
                      },
                    ),
                    Wrap(
                      children: _selectedTags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                      )).toList(),
                    ),
                    TextButton(
                      onPressed: _showAddTagPopup,
                      child: const Text('Add a tag'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Importance level:'),
                    DropdownButton<String>(
                      value: _importance,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _importance = newValue!;
                        });
                      },
                      items: <String>['Low', 'Medium', 'High']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _showAddDescriptionPopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Add description (optional)'),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                final String event = eventController.text;
                final String probabilityStr = probabilityController.text;
                final double? probability = double.tryParse(probabilityStr);
                if (event.isNotEmpty && probability != null && probability >= 0 && probability <= 1) {
                  widget.onAddEvent(event, probability, _selectedDate, _selectedTags, _importance, _description);
                  eventController.clear();
                  probabilityController.clear();
                  setState(() {
                    _selectedDate = null;
                    _selectedTags = [];
                    _importance = 'Medium';
                    _description = null;
                  });
                } else {
                  _showErrorDialog(context, 'Please enter a valid event and probability (0-1).');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 85, vertical: 20),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
