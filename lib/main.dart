import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

// --- CONFIG ---
const String GEMINI_API_KEY = "AIzaSy_YAHAN_APNI_KEY_LAGAO";
FlutterTts tts = FlutterTts();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PolypickApp());
}

class PolypickApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polypick AI Dialer',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final screens = [AIDialerPad(), AICallLog(), AIContacts()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.dialpad), label: 'AI Dialer'),
          NavigationDestination(icon: Icon(Icons.history), label: 'AI Log'),
          NavigationDestination(icon: Icon(Icons.contacts), label: 'Phone Book'),
        ],
      ),
    );
  }
}

// 1. ADVANCE AI DIALER PAD
class AIDialerPad extends StatefulWidget {
  @override
  State<AIDialerPad> createState() => _AIDialerPadState();
}

class _AIDialerPadState extends State<AIDialerPad> {
  String number = "";
  String aiSuggestion = "Number dial karo, AI Caller ID batayega...";
  bool isSpam = false;

  void onNumberChange(String val) async {
    setState(() => number += val);
    if (number.length > 5) {
      // AI Caller ID Check
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
      try {
        final res = await model.generateContent([Content.text("Ye number $number kiska ho sakta hai? Agar spam lag raha hai to SPAM likhna, warna Company ka naam guess karo. Short answer.")]);
        setState(() {
          aiSuggestion = res.text?? "Unknown Business Number";
          isSpam = aiSuggestion.toLowerCase().contains("spam");
        });
      } catch (e) {
        setState(() => aiSuggestion = "Offline AI: $number - Polypick Client?");
      }
    }
  }

  Future<void> openWhatsApp() async {
    final uri = Uri.parse("https://wa.me/91$number");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: isSpam? Colors.red.shade100 : Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(number.isEmpty? "Dialer" : number, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(isSpam? Icons.warning : Icons.smart_toy, color: isSpam? Colors.red : Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text(aiSuggestion, style: TextStyle(fontWeight: FontWeight.w600))),
                    IconButton(onPressed: () => tts.speak(aiSuggestion), icon: Icon(Icons.volume_up))
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: ["1","2","3","4","5","6","7","8","9","*","0","#"].map((e) =>
                InkWell(onTap: () => onNumberChange(e), child: Card(child: Center(child: Text(e, style: TextStyle(fontSize: 28)))))).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(backgroundColor: Colors.green, onPressed: () {}, child: Icon(Icons.call, color: Colors.white)),
              FloatingActionButton.small(backgroundColor: Colors.green.shade400, onPressed: openWhatsApp, child: Icon(Icons.chat)),
              FloatingActionButton.small(backgroundColor: Colors.orange, onPressed: () async {
                Position pos = await Geolocator.getCurrentPosition();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("GPS Captured: ${pos.latitude}, ${pos.longitude}")));
              }, child: Icon(Icons.location_on)),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// 2. AI CALL LOG WITH SUMMARY
class AICallLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        ListTile(title: Text("JSW Dolvi - Purchase"), subtitle: Text("AI Summary: 100m Liner chahiye, Budget 1.5L, Mood: Urgent\nGPS: 17.6, 73.2 | Competitor: Tega"), trailing: Icon(Icons.mic, color: Colors.blue), isThreeLine: true),
        ListTile(title: Text("UltraTech Hirmi"), subtitle: Text("AI Summary: Skirt Board ka rate pucha, Positive mood"), trailing: Icon(Icons.mic)),
        ListTile(title: Text("Unknown - 98231xxxx"), subtitle: Text("AI Spam Detection: 95% Spam - Fraud Call"), trailing: Icon(Icons.block, color: Colors.red)),
      ],
    );
  }
}

// 3. PHONE BOOK
class AIContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(leading: CircleAvatar(child: Text("J")), title: Text("JSW Jaigarh Plant"), subtitle: Text("Plant Proximity Alert: 500m paas ho, purana quotation yaad dilau?")),
        ListTile(leading: CircleAvatar(child: Text("U")), title: Text("UltraTech - Sunil Sir"), subtitle: Text("Last Call: 2 din pehle")),
      ],
    );
  }
}