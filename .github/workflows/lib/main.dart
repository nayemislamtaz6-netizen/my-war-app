import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyWarApp());
}

class MyWarApp extends StatelessWidget {
  const MyWarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'আমার যুদ্ধ অ্যাপ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // বাংলাদেশের পতাকার লাল ও সবুজ থিম
        primaryColor: const Color(0xFF006A4E), // পতাকার সবুজ
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006A4E),
          primary: const Color(0xFF006A4E),
          secondary: const Color(0xFFF42A41), // পতাকার লাল
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF006A4E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const RegistrationPage(),
    );
  }
}

// ১. সদস্য নিবন্ধন পেজ
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সব তথ্য সঠিকভাবে দিন।')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> usersList = prefs.getStringList('users') ?? [];
    
    // নতুন ইউজারের ডাটা (ডিফল্ট পদবি: সাধারণ সদস্য)
    Map<String, String> newUser = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'password': _passwordController.text,
      'role': 'সাধারণ সদস্য'
    };

    usersList.add(jsonEncode(newUser));
    await prefs.setStringList('users', usersList);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(currentUserPhone: _phoneController.text)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // পতাকার থিমে তৈরি লোগো ও হেডার
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF006A4E),
                borderRadius: BorderRadius.only(bottomBottomRadius: Radius.circular(50)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // লোগো: লাল বৃত্ত (পতাকা নির্দেশক)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF42A41),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flag, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'জয় বাংলা',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'সদস্য নিবন্ধন',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006A4E)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'নাম', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'মোবাইল নাম্বার', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'পাসওয়ার্ড', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF42A41),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('নিবন্ধন করুন', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ২. হোম পেজ (সদস্যদের তালিকা)
class HomePage extends StatefulWidget {
  final String currentUserPhone;
  const HomePage({super.key, required this.currentUserPhone});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersList = prefs.getStringList('users') ?? [];
    setState(() {
      _allUsers = usersList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  void _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse("https://wa.meি আমার পদের জন্য যোগাযোগ করছি।");
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('হোয়াটসঅ্যাপ ওপেন করা যাচ্ছে না');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সদস্যদের তালিকা'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegistrationPage()));
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'whatsapp') {
                _launchWhatsApp();
              } else if (value == 'admin') {
                _showAdminPasswordDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'whatsapp',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.message, color: Colors.green),
                        SizedBox(width: 8),
                        Text('এডমিন হোয়াটসঅ্যাপ'),
                      ],
                    ),
                    const Text(
                      'নতুন সমস্যারা তাদের পদের জন্য এখানে যোগাযোগ করুন',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.red),
                    SizedBox(width: 8),
                    Text('এডমিন প্যানেল'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _allUsers.isEmpty
          ? const Center(child: Text('কোনো সদস্য নিবন্ধিত নেই।'))
          : ListView.builder(
              itemCount: _allUsers.length,
              itemBuilder: (context, index) {
                final user = _allUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF006A4E),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('মোবাইল: ${user['phone']}\nপদবি: ${user['role']}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  void _showAdminPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('এডমিন লগইন'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'এডমিন পাসওয়ার্ড দিন'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(
            onPressed: () {
              if (passwordController.text == '1971') {
