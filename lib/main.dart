import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'event_input.dart';
import 'forecasts_screen.dart';
import 'models/event.dart';
import 'my_accuracy.dart';
import 'profile_screen.dart';
import 'tips_screen.dart';
import 'about_screen.dart';
import 'event_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bayesian Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const CheckFirstLaunch(),
    );
  }
}

class CheckFirstLaunch extends StatefulWidget {
  const CheckFirstLaunch({super.key});

  @override
  _CheckFirstLaunchState createState() => _CheckFirstLaunchState();
}

class _CheckFirstLaunchState extends State<CheckFirstLaunch> {
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showInstructions = prefs.getBool('showInstructions') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showInstructions ? InstructionsScreen() : const HomeScreen();
  }
}

class InstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use This App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Bayesian Calculator! This app allows you to make and track probabilistic forecasts. You can add new events, assign probabilities, set deadlines, and track the outcomes.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              '1. To add a new event, fill in the event details and click Submit.\n'
                  '2. You can view all your forecasts by clicking "My Forecasts".\n'
                  '3. In the "My Forecasts" section, you can edit, resolve, or delete events.\n'
                  '4. Use the "My Accuracy" section to see how accurate your predictions are.\n'
                  '5. You can update your profile and view tips on using the app from the respective sections.',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('showInstructions', false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('Do not show again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> events = [];
  List<String> tags = [];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadTags();
  }

  List<Widget> _widgetOptions() {
    return <Widget>[
      HomeContent(
        onAddEvent: _addEvent,
        tags: tags,
        onAddTag: _addTag,
        events: events,
        onResolveEvent: _resolveEvent,
        onDeleteEvent: _deleteEvent,
        onEditEvent: _editEvent,
      ),
      MyAccuracy(events: events),
      ProfileScreen(
        questionsCount: events.length,
        resolutionsCount: events.where((e) => e.resolved != null).length,
      ),
      const TipsScreen(),
      const AboutScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTag(String newTag) {
    setState(() {
      tags.add(newTag);
      _saveTags();
    });
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      final List<dynamic> eventsJson = jsonDecode(eventsString);
      setState(() {
        events = eventsJson.map((json) => Event.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsString = jsonEncode(events.map((event) => event.toJson()).toList());
    prefs.setString('events', eventsString);
  }

  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? loadedTags = prefs.getStringList('tags');
    if (loadedTags != null) {
      setState(() {
        tags = loadedTags;
      });
    }
  }

  Future<void> _saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tags', tags);
  }

  void _addEvent(String name, double probability, DateTime? deadline, List<String> tags, String importance, String? description) {
    setState(() {
      events.add(Event(
        name: name,
        probability: probability,
        resolutionDeadline: deadline,
        tags: tags,
        importance: importance,
        description: description,
      ));
      _saveEvents();
    });
  }

  void _resolveEvent(Event event, bool resolved) {
    setState(() {
      event.resolved = resolved;
      _saveEvents();
    });
  }

  void _deleteEvent(Event event) {
    setState(() {
      events.remove(event);
      _saveEvents();
    });
  }

  void _editEvent(Event updatedEvent) {
    setState(() {
      final index = events.indexWhere((event) => event.name == updatedEvent.name);
      if (index != -1) {
        events[index] = updatedEvent;
        _saveEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayesian Calculator'),
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'My Accuracy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(String, double, DateTime?, List<String>, String, String?)? onAddEvent;
  final List<String>? tags;
  final Function(String)? onAddTag;
  final List<Event>? events;
  final Function(Event, bool)? onResolveEvent;
  final Function(Event)? onDeleteEvent;
  final Function(Event)? onEditEvent;

  const HomeContent({
    this.onAddEvent,
    this.tags,
    this.onAddTag,
    this.events,
    this.onResolveEvent,
    this.onDeleteEvent,
    this.onEditEvent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Event> lastThreeEvents = [];
    if (events != null && events!.length > 3) {
      lastThreeEvents = events!.sublist(events!.length - 3);
    } else {
      lastThreeEvents = events ?? [];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          EventInput(onAddEvent: onAddEvent!, tags: tags!, onAddTag: onAddTag!),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForecastsScreen(
                    events: events!,
                    onResolveEvent: onResolveEvent!,
                    onDeleteEvent: onDeleteEvent!,
                    onEditEvent: onEditEvent!,
                  )),
                ).then((_) {
                  // Refresh the state after coming back from the ForecastsScreen
                  (context as Element).reassemble();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('My Forecasts'),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Recent Forecasts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...lastThreeEvents.map((event) => ListTile(
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventProfile(
                    event: event,
                    onDeleteEvent: onDeleteEvent!,
                    onEditEvent: onEditEvent!,
                  ),
                ),
              );
            },
          )).toList(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}