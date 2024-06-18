import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              const TextSpan(
                text: 'Welcome to Bayesian Calculator! This app allows you to make and track probabilistic forecasts. You can add new events, assign probabilities, set deadlines, and track the outcomes.\n',
              ),
              const TextSpan(
                text: '1. To add a new event, fill in the event details and click Submit.\n'
                    '2. You can view all your forecasts by clicking "My Forecasts".\n'
                    '3. In the "My Forecasts" section, you can edit, resolve, or delete events.\n'
                    '4. Use the "My Accuracy" section to see how accurate your predictions are.\n'
                    '5. You can update your profile and view tips on using the app from the respective sections.\n',
              ),
              const TextSpan(
                text: 'This is an open source project. The code is available at: ',
              ),
              TextSpan(
                text: 'GitHub Repository',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()..onTap = () => _launchURL('https://github.com/Kendiukhov/bayesian_calculator'),
              ),
              const TextSpan(
                text: '. To learn more about the author, visit ',
              ),
              TextSpan(
                text: 'linktr.ee/kendiukhov',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()..onTap = () => _launchURL('https://linktr.ee/kendiukhov'),
              ),
              const TextSpan(
                text: '.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}