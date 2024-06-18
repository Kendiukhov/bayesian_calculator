import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = [
      {
        'text': 'Train your rationality to be better at predictions.',
        'url': 'https://www.readthesequences.com'
      },
      {
        'text': 'Compete with others in forecasting.',
        'url': 'https://manifold.markets'
      },
      {
        'text': 'Improve your knowledge of probability.',
        'url': 'https://www.lesswrong.com/posts/XTXWPQSEgoMkAupKt/an-intuitive-explanation-of-bayes-s-theorem'
      },
      {
        'text': 'Improve your knowledge of fat tails.',
        'url': 'https://nassimtaleb.org/2018/08/technical-incerto-vol-1-statistical-consequences-fat-tails/'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip['text']!, style: const TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () => _launchURL(tip['url']!),
                    child: Text(
                      tip['url']!,
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}