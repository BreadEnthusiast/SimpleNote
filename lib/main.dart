import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'noteScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleNote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 252, 241, 145)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SimpleNote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ThemeData> availableThemes = [
    ThemeData(
      primaryColor: const Color.fromARGB(229, 245, 164, 37),
      backgroundColor: const Color.fromARGB(255,252, 241, 145),
    ),
    ThemeData(
      primaryColor: Colors.pink,
      backgroundColor: Colors.pink[100],
    ),
    ThemeData(
      primaryColor: Colors.blue,
      backgroundColor: Colors.blue[100],
    ),
    ThemeData(
      primaryColor: Colors.grey[400],
      backgroundColor: Colors.white30,
    ),
  ];

  void onThemeChanged(ThemeData newTheme) {
    setState(() {
      selectedTheme = newTheme;
    });
  }

  late ThemeData selectedTheme;

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  // Load selected theme from shared preferences
  Future<void> _loadSelectedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('selectedThemeIndex') ?? 0;
    setState(() {
      selectedTheme = availableThemes[themeIndex];
    });
  }

  // Save selected theme to shared preferences
  Future<void> _saveSelectedTheme(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedThemeIndex', themeIndex);
  }
  void _handleThemeChanged(ThemeData newTheme) {
    setState(() {
      selectedTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: selectedTheme.primaryColor,
        actions: [
          // Theme selection button
          PopupMenuButton<ThemeData>(
            icon: const Icon(Icons.format_paint),
            onSelected: (theme) {
              setState((){
                selectedTheme = theme;
              });
              _saveSelectedTheme(availableThemes.indexOf(theme));
            },
            itemBuilder: (BuildContext context) {
              return availableThemes.map((theme) {
                return PopupMenuItem<ThemeData>(
                    value: theme,
                    child: Text(_getThemeName(theme))
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
          color: selectedTheme.backgroundColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteScreen(onThemeChanged: _handleThemeChanged),
              )
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add), // You can customize the button color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // function to get theme name
  String _getThemeName(ThemeData theme) {
    if (theme.primaryColor == const Color.fromARGB(229, 245, 164, 37) &&
        theme.backgroundColor == const Color.fromARGB(255, 252, 241, 145)) {
      return 'Yellow';
  }  else if (theme.primaryColor == Colors.pink && theme.backgroundColor == Colors.pink[100]) {
  return 'Pink';
  } else if (theme.primaryColor == Colors.blue && theme.backgroundColor == Colors.blue[100]) {
  return 'Blue';
  } else if (theme.primaryColor == Colors.grey[400] && theme.backgroundColor == Colors.white30) {
  return 'White';
  } else {
  return 'Unknown';
  }
  }
}
