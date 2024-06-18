import 'package:flutter/material.dart';

class AddTagPopup extends StatefulWidget {
  final Function(String) onAddTag;

  const AddTagPopup({required this.onAddTag, super.key});

  @override
  _AddTagPopupState createState() => _AddTagPopupState();
}

class _AddTagPopupState extends State<AddTagPopup> {
  final TextEditingController tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new tag'),
      content: TextField(
        controller: tagController,
        decoration: const InputDecoration(
          labelText: 'Tag',
          hintText: 'Enter a new tag',
        ),
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
            final String newTag = tagController.text;
            if (newTag.isNotEmpty) {
              widget.onAddTag(newTag);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
