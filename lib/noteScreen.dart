import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';


class NoteScreen extends StatefulWidget {
  final Function(ThemeData) onThemeChanged;
  const NoteScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late ThemeData selectedTheme;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final List<ThemeData> availableThemes = [
    ThemeData(
      primaryColor: const Color.fromARGB(229, 245, 164, 37),
      backgroundColor: const Color.fromARGB(255, 252, 241, 145),
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
    widget.onThemeChanged(availableThemes[themeIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Enter note title',
            hintStyle: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: true,
        backgroundColor: selectedTheme.primaryColor,
        actions: [
          // Theme selection button
          PopupMenuButton<ThemeData>(
            icon: const Icon(Icons.format_paint),
            onSelected: (theme) {
              setState(() {
                selectedTheme = theme;
              });
              _saveSelectedTheme(availableThemes.indexOf(theme));
            },
            itemBuilder: (BuildContext context) {
              return availableThemes.map((theme) {
                return PopupMenuItem<ThemeData>(
                  value: theme,
                  child: Text(_getThemeName(theme)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        color: selectedTheme.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: noteController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.black),
                ),
              )
            )
          ]
        )
      ),
    );
  }

  String _getThemeName(ThemeData theme) {
    if (theme.primaryColor == const Color.fromARGB(229, 245, 164, 37) &&
        theme.backgroundColor == const Color.fromARGB(255, 252, 241, 145)) {
      return 'Yellow';
    } else if (theme.primaryColor == Colors.pink &&
        theme.backgroundColor == Colors.pink[100]) {
      return 'Pink';
    } else if (theme.primaryColor == Colors.blue &&
        theme.backgroundColor == Colors.blue[100]) {
      return 'Blue';
    } else if (theme.primaryColor == Colors.grey[400] &&
        theme.backgroundColor == Colors.white30) {
      return 'White';
    } else {
      return 'Unknown';
    }
  }
}
