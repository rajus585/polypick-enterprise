import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String GEMINI_API_KEY = "AIzaSy_YAHAN_APNI_KEY_LAGAO";
FlutterTts tts = FlutterTts();

// ORIGINAL RAJU SINGH BRAIN - SATH ME HI
class PolypickAIBrain {
  static Map<String, dynamic> companyData = {};
  static Future<void> loadOriginalData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/polypick_original_knowledge.json');
      companyData = json.decode(jsonString);
      await Hive.box('companyBox').put('original', companyData);
    } catch(e) { print(e); }
  }
  static Future<void> resetCompanyData() async {
    await Hive.box('companyBox').clear();
    await Hive.box('productBox').clear();
    await Hive.box('callDiaryBox').clear();
  }
  static bool isNewUser() => Hive.box('companyBox').isEmpty;
  static String getAIReply(String query, String callerName) {
    query = query.toLowerCase();
    if (query.contains("liner") || query.contains("ceramic") || query.contains("lagging") || query.contains("price") || query.contains("uhmw") || query.contains("scraper") || query.contains("conveyor")) {
      return "Namaste $callerName ji, main Raju Singh ji ki awaz me bol raha hu, Service Marketing Head, Mumbai 9784641949. Aapne $query pucha. PolyPick me Virgin UHMW PE, CRPM SB, Ceramic Lagging CRLG Unmatched Grip, Impact Pads, Skirt Sealing Dual Lip 50mm, UHMW Idlers sab available hai. Sheet 1000x2000, 1250x5500, Thickness 8-200 MM. Number forward kiya - 9784641949, Personal 9039055327 Rajasthan.";
    }
    if (query.contains("raju")) {
      return "Raju Singh ji Mumbai Service me busy hain, main unka AI assistant unki hi awaz me. Aapka naam/company bataiye. Official 9784641949 mumbai@polypick.com, Personal 9039055327 Rajasthan.";
    }
    return "Namaste $callerName ji, PolyPick Engineers - Indore HO, Mumbai, Bhubaneswar. Main Raju Singh ji ka AI. Kaunsa product? Liner, Conveyor Care, UHMW ya Glider Pipes?";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('companyBox');
  await Hive.openBox('productBox');
  await Hive.openBox('callDiaryBox');
  await Hive.openBox('voiceBox');
  await Hive.openBox('learningBox');
  await [Permission.phone, Permission.contacts, Permission.microphone, Permission.storage, Permission.location].request();
  tts.setLanguage("hi-IN"); tts.setSpeechRate(0.5);
  runApp(PolypickApp());
}

class PolypickApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'PolyPick Original - Raju Singh', theme: ThemeData(primarySwatch: Colors.deepOrange, useMaterial3: true), home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  @override _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { super.initState(); checkUser(); }
  checkUser() async {
    await PolypickAIBrain.loadOriginalData();
    await Future.delayed(Duration(seconds: 2));
    if (PolypickAIBrain.isNewUser()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetupWizardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
    }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.settings, size: 80, color: Colors.orange), SizedBox(height: 20), Text("POLYPICK", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), Text("Raju Singh - Service Marketing Head"), Text("9784641949 | 9039055327 Rajasthan"), SizedBox(height: 20), CircularProgressIndicator()])));
  }
}

class SetupWizardScreen extends StatefulWidget {
  @override _SetupWizardScreenState createState() => _SetupWizardScreenState();
}
class _SetupWizardScreenState extends State<SetupWizardScreen> {
  TextEditingController companyCtrl = TextEditingController(text: "POLYPICK ENGINEERS PVT LTD");
  TextEditingController nameCtrl = TextEditingController(text: "Raju Singh");
  TextEditingController mobileCtrl = TextEditingController(text: "9784641949");
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Setup Your Original AI - Sath Me Hi")), body: Padding(padding: EdgeInsets.all(16), child: ListView(children: [
      Text("Step 1: Company ORIGINAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      TextField(controller: companyCtrl, decoration: InputDecoration(labelText: "Company Name")),
      TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Your Name")),
      TextField(controller: mobileCtrl, decoration: InputDecoration(labelText: "Mobile")),
      SizedBox(height: 20),
      ElevatedButton(onPressed: () async { await Hive.box('companyBox').put('owner_name', nameCtrl.text); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen())); }, child: Text("SAVE & CREATE MY ORIGINAL AI - RAJU SINGH"), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50))),
    ])));
  }
}

class MainScreen extends StatefulWidget {
  @override State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final screens = [AIDialerPad(), AICallDiaryLog(), AIContactsWithOriginal()];
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PolyPick AI Dialer - Raju Singh Original Sath Me"), actions: [IconButton(icon: Icon(Icons.restart_alt), onPressed: () async { showDialog(context: context, builder: (_) => AlertDialog(title: Text("Reset Company?"), content: Text("Company chhod rahe ho? Data delete, naya wizard khulega - Play Store feature!"), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")), TextButton(onPressed: () async { await PolypickAIBrain.resetCompanyData(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => SetupWizardScreen()), (r)=>false); }, child: Text("YES RESET", style: TextStyle(color: Colors.red))) ])); })]),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: (i) => setState(() => _index = i), destinations: [NavigationDestination(icon: Icon(Icons.dialpad), label: 'AI Dialer Sath'), NavigationDestination(icon: Icon(Icons.history), label: 'Call Diary'), NavigationDestination(icon: Icon(Icons.contacts), label: 'Contacts Owner')]),
    );
  }
}

class AIDialerPad extends StatefulWidget { @override State<AIDialerPad> createState() => _AIDialerPadState(); }
class _AIDialerPadState extends State<AIDialerPad> {
  String number = ""; String aiSuggestion = "Number dial karo, AI batayega..."; bool isSpam = false;
  void onNumberChange(String val) async {
    setState(() => number += val);
    if (number.length > 5) {
      try {
        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
        final res = await model.generateContent([Content.text("Ye number $number kiska ho sakta hai? Spam to SPAM likhna.")]);
        setState(() { aiSuggestion = res.text?? "PolyPick Client?"; isSpam = aiSuggestion.toLowerCase().contains("spam"); });
      } catch (e) { setState(() => aiSuggestion = "Offline AI Raju Singh: $number - PolyPick Client? 9784641949"); }
    }
  }
  Future<void> openWhatsApp() async { final uri = Uri.parse("https://wa.me/91$number"); await launchUrl(uri, mode: LaunchMode.externalApplication); }
  Future<void> saveToDiary(String productAsked) async { var box = Hive.box('callDiaryBox'); box.add({"date": DateTime.now().toString(), "number": number, "caller_name": "Customer - AI puchega naam", "product_asked": productAsked, "ai_reply": PolypickAIBrain.getAIReply(productAsked, "Customer"), "mood": "Urgent", "next_action": "Kal 11 baje call back - 9784641949"}); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Diary save - Raju Singh Original!"))); }
  @override Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      Card(color: Colors.orange.shade50, margin: EdgeInsets.all(12), child: Padding(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("ORIGINAL OWNER - RAJU SINGH - Service Marketing Head", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text("Official: 9784641949 | mumbai@polypick.com - Personal: 9039055327 Rajasthan", style: TextStyle(fontSize: 11)), Text("AI Status: Hubhu Awaz Me Active - Sath Me Hi", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11))]))),
      Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: isSpam? Colors.red.shade100 : Colors.blue.shade50, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(number.isEmpty? "AI Dialer Sath Me" : number, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), Row(children: [Icon(isSpam? Icons.warning : Icons.smart_toy), SizedBox(width: 8), Expanded(child: Text(aiSuggestion, style: TextStyle(fontSize: 12))), IconButton(onPressed: () => tts.speak(aiSuggestion), icon: Icon(Icons.volume_up))])])),
      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: TextField(decoration: InputDecoration(hintText: "Customer kya pucha? Ex: Ceramic Lagging price? AI bolega", border: OutlineInputBorder(), isDense: true), onSubmitted: (val) async { String reply = PolypickAIBrain.getAIReply(val, "Vikas"); tts.speak(reply); saveToDiary(val); })),
      Expanded(child: GridView.count(crossAxisCount: 3, childAspectRatio: 1.5, children: ["1","2","3","4","5","6","7","8","9","*","0","#"].map((e) => InkWell(onTap: () => onNumberChange(e), child: Card(child: Center(child: Text(e, style: TextStyle(fontSize: 28)))))).toList())),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [FloatingActionButton(backgroundColor: Colors.green, onPressed: () {}, child: Icon(Icons.call)), FloatingActionButton.small(onPressed: openWhatsApp, child: Icon(Icons.chat)), FloatingActionButton.small(onPressed: () async { Position pos = await Geolocator.getCurrentPosition(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("GPS: ${pos.latitude} - Raju Singh Branch"))); }, child: Icon(Icons.location_on))]),
      SizedBox(height: 10),
    ]));
  }
}

class AICallDiaryLog extends StatefulWidget { @override State<AICallDiaryLog> createState() => _AICallDiaryLogState(); }
class _AICallDiaryLogState extends State<AICallDiaryLog> {
  List<Map> diary = []; @override void initState() { super.initState(); loadDiary(); }
  loadDiary() { var box = Hive.box('callDiaryBox'); setState(() { diary = box.values.map((e) => Map.from(e)).toList().reversed.toList(); }); }
  @override Widget build(BuildContext context) {
    return diary.isEmpty ? Center(child: Text("Koi diary nahi - Dialer me product likho\nRaju Singh AI save karega")) : ListView.builder(padding: EdgeInsets.all(12), itemCount: diary.length, itemBuilder: (ctx, i) { var d = diary[i]; return Card(child: ListTile(title: Text((d['caller_name'] ?? '') + " - " + (d['product_asked'] ?? '')), subtitle: Text("${d['date']?.toString().substring(0,16)}\nNext: ${d['next_action']}"), trailing: IconButton(icon: Icon(Icons.volume_up), onPressed: () => tts.speak(d['ai_reply'])))); });
  }
}

class AIContactsWithOriginal extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return ListView(padding: EdgeInsets.all(12), children: [
      Card(color: Colors.deepOrange.shade50, child: ListTile(leading: CircleAvatar(backgroundColor: Colors.orange, child: Text("RS", style: TextStyle(color: Colors.white))), title: Text("Raju Singh - Service Marketing Head (ORIGINAL)"), subtitle: Text("Mumbai: 9784641949 mumbai@polypick.com\nPersonal: 9039055327 Rajasthan - AI Hubhu Awaz"))),
      ListTile(leading: CircleAvatar(child: Text("J")), title: Text("JSW Dolvi"), subtitle: Text("100m Liner - 500m paas")),
      ListTile(leading: CircleAvatar(child: Text("H")), title: Text("Head Office Indore"), subtitle: Text("F2, 14-B, Sector A, Sanwer Road, Indore - Polypick@gmail.com")),
    ]);
  }
}