import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final int questionsCount;
  final int resolutionsCount;

  const ProfileScreen({required this.questionsCount, required this.resolutionsCount, super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameController = TextEditingController();
  File? _image;
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileString = prefs.getString('profile');
    if (profileString != null) {
      final Map<String, dynamic> profileJson = jsonDecode(profileString);
      setState(() {
        _nickname = profileJson['nickname'];
        _nicknameController.text = _nickname;
        if (profileJson['imagePath'] != null) {
          _image = File(profileJson['imagePath']);
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String imagePath = _image?.path ?? '';
    final profileJson = jsonEncode({
      'nickname': _nickname,
      'imagePath': imagePath,
    });
    prefs.setString('profile', profileJson);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.add_a_photo, size: 50) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
              onChanged: (value) {
                _nickname = value;
                _saveProfile();
              },
            ),
            const SizedBox(height: 20),
            Text('Questions made: ${widget.questionsCount}'),
            const SizedBox(height: 10),
            Text('Resolutions: ${widget.resolutionsCount}'),
          ],
        ),
      ),
    );
  }
}