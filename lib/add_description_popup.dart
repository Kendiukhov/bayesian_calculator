import 'package:flutter/material.dart';

class AddDescriptionPopup extends StatelessWidget {
  final Function(String) onAddDescription;

  AddDescriptionPopup({required this.onAddDescription, super.key});

  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add description'),
      content: TextField(
        controller: descriptionController,
        decoration: const InputDecoration(
          labelText: 'Description',
          hintText: 'Enter event description',
        ),
        maxLines: 5,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final String description = descriptionController.text;
            if (description.isNotEmpty) {
              onAddDescription(description);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
