import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

String get kGroqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WifiAgentScreen(),
    );
  }
}

class WifiAgentScreen extends StatefulWidget {
  const WifiAgentScreen({super.key});

  @override
  State<WifiAgentScreen> createState() => _WifiAgentScreenState();
}

class _WifiAgentScreenState extends State<WifiAgentScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.yourapp/wifi_toggle');

  final stt.SpeechToText _speech = stt.SpeechToText();

  final FlutterTts _tts = FlutterTts();

  bool _listening = false;

  bool _accessibilityEnabled = false;

  String _statusText = 'Checking Accessibility...';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _tts.setLanguage('hi-IN');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccessibility();
    });
  }

  Future<void> _checkAccessibility() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('checkAccessibility');

      print('[WifiAgent] Accessibility enabled: $enabled');

      if (!mounted) return;

      setState(() {
        _accessibilityEnabled = enabled == true;

        _statusText = enabled == true
            ? 'Ready. Say: WiFi band karo'
            : 'Accessibility permission required';
      });

      if (enabled != true) {
        await _showAccessibilityDialog();
      }
    } catch (e) {
      print('[WifiAgent] Accessibility check error: $e');

      if (!mounted) return;

      setState(() {
        _statusText = 'Accessibility check failed';
      });
    }
  }

  Future<void> _showAccessibilityDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Accessibility Required'),

          content: const Text(
            'Please enable WiFi Toggler in '
            'Accessibility Settings so the '
            'assistant can control the phone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await _channel.invokeMethod('openAccessibilitySettings');
              },

              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibility();
    }
  }

  Future<void> _startListening() async {
    if (!_accessibilityEnabled) {
      await _checkAccessibility();

      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _listening = false;
            });
          }
        }
      },

      onError: (error) {
        if (mounted) {
          setState(() {
            _statusText = 'Speech error: ${error.errorMsg}';
          });
        }
      },
    );

    if (!available) {
      setState(() {
        _statusText = 'Speech recognition unavailable';
      });

      return;
    }

    setState(() {
      _listening = true;
      _statusText = 'Listening...';
    });

    await _speech.listen(
      localeId: 'hi_IN',

      onResult: (result) async {
        if (result.finalResult) {
          final text = result.recognizedWords;

          setState(() {
            _listening = false;
            _statusText = 'You said: "$text"';
          });

          await _handleCommand(text);
        }
      },
    );
  }

  Future<void> _handleCommand(String spokenText) async {
    if (spokenText.trim().isEmpty) {
      return;
    }

    print('[WifiAgent] User said: "$spokenText"');

    setState(() {
      _statusText = 'Understanding command...';
    });

    final action = await _getActionFromGroq(spokenText);

    print('[WifiAgent] AI action: $action');

    if (action == null || action['action'] != 'turn_wifi_off') {
      setState(() {
        _statusText = 'Only WiFi OFF is supported in this POC.';
      });

      return;
    }

    setState(() {
      _statusText = 'Agent is controlling the phone...';
    });

    try {
      await _channel.invokeMethod('startWifiAgent');
    } on PlatformException catch (e) {
      print('[WifiAgent] Native error: $e');

      setState(() {
        _statusText = 'Could not start agent';
      });

      return;
    }

    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _statusText = 'WiFi agent finished';
    });
  }

  Future<Map<String, dynamic>?> _getActionFromGroq(String userText) async {
    const systemPrompt = '''
You are an intent parser.

The application currently supports ONLY one action:

Turn WiFi OFF.

If the user asks to turn WiFi off in Hindi,
English, or Hinglish, return:

{"action":"turn_wifi_off"}

Otherwise return:

{"action":"unknown"}

Return ONLY JSON.
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),

        headers: {
          'Authorization': 'Bearer $kGroqApiKey',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',

          'messages': [
            {'role': 'system', 'content': systemPrompt},

            {'role': 'user', 'content': userText},
          ],

          'temperature': 0,

          'max_tokens': 50,
        }),
      );

      if (response.statusCode != 200) {
        print(
          '[WifiAgent] Groq error: '
          '${response.body}',
        );

        return null;
      }

      final data = jsonDecode(response.body);

      final content = data['choices'][0]['message']['content'] as String;

      final cleaned = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      print('[WifiAgent] Groq exception: $e');

      return null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android Agent POC')),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: _listening ? null : _startListening,

                child: CircleAvatar(
                  radius: 45,

                  backgroundColor: _listening ? Colors.red : Colors.blue,

                  child: Icon(
                    _listening ? Icons.mic : Icons.mic_none,

                    size: 40,

                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text('Try: "WiFi band karo"'),
            ],
          ),
        ),
      ),
    );
  }
}
