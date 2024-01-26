import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'noteScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

int totalIndex = 0;

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

//

class _MyHomePageState extends State<MyHomePage> {

  final List<ThemeData> availableThemes = [
    ThemeData(
      colorScheme: const ColorScheme.light(
        background: Color.fromARGB(255, 252, 241, 145),
        primary: Color.fromARGB(229, 245, 164, 37),
      ),
    ),
    ThemeData(
      colorScheme: ColorScheme.light(
        background: Colors.pink[100] as Color,
        primary: Colors.pink,
      ),
    ),
    ThemeData(
      colorScheme: ColorScheme.light(
        background: Colors.blue[100] as Color,
        primary: Colors.blue,
      ),
    ),
    ThemeData(
      colorScheme: ColorScheme.light(
        background: Colors.white30,
        primary: Colors.grey[400] as Color,
      ),
    ),
  ];

  void onThemeChanged(ThemeData newTheme) {
    setState(() {
      selectedTheme = newTheme;
    });
  }

  late ThemeData selectedTheme = availableThemes[0];
  List<Note?> notes = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
    _loadNotes();
    initializeIndex();
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

  Future<void> initializeIndex() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String notesFolderPath = '${documentsDirectory.path}/noteFiles';

    if (await Directory(notesFolderPath).exists()) {
      List<FileSystemEntity> noteFiles = Directory(notesFolderPath).listSync();
      totalIndex = noteFiles.length;
      debugPrint("Current totalIndex: $totalIndex");
    }
  }

  void _handleThemeChanged(ThemeData newTheme) {
    setState(() {
      selectedTheme = newTheme;
    });
  }

  Future<void> _loadNotes() async {
    List<Note> loadedNotes = [];
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String notesFolderPath = '${documentsDirectory.path}/noteFiles';

    if (await Directory(notesFolderPath).exists()) {
      List<FileSystemEntity> noteFiles = Directory(notesFolderPath).listSync();

      for (FileSystemEntity file in noteFiles) {
        String title = await _readTitleFromFile(file);
        loadedNotes.add(Note(title: title, filePath: file.path));
      }
    }
    setState(() {
      notes = loadedNotes;
    });
  }

  Future<String> _readTitleFromFile(FileSystemEntity file) async {
    String content = await File(file.path).readAsString();
    // Split the content at the first line break to get the title
    return content.split('\n').first;
  }

  late File noteFile;

  Future<void> _navigateToNoteScreen() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String notesFolderPath = '${documentsDirectory.path}/noteFiles';

    await Directory(notesFolderPath).create(recursive: true);

    int index = notes.length;
    String fileName = '$index';
    File noteFile = File('$notesFolderPath/$fileName');
    debugPrint('!!!!!!!!!!!!!!!!!$noteFile');
    await noteFile.writeAsString('');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(onThemeChanged: _handleThemeChanged, noteFile: noteFile,)),
    );
    debugPrint(result);
    _loadNotes(); // Refresh notes when returning from NoteScreen
  }


  @override
  Widget build(BuildContext context) {
    initializeIndex();
    debugPrint("${notes.length}");
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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNoteScreen,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add), // You can customize the button color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _removeNote(int index) async {
    File file = File(notes[index]!.filePath);
    await file.delete();
    await _loadNotes();
  }

  Widget _buildBody() {
    if (notes.isNotEmpty) {
      return Container(
        color: selectedTheme.colorScheme.background,
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  Note? note = notes[index];
                  return Dismissible(
                      key: UniqueKey(),onDismissed: (direction) {
                    _removeNote(index);
                  },
                      child: GestureDetector(
                        onTap: () {
                          if (note != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteScreen(
                                  onThemeChanged: onThemeChanged,
                                  initialNote: note,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              note?.title ?? "",
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      )
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // Display default content when there are no notes
      return Container(
        color: selectedTheme.colorScheme.background,
        child: const Center(
          child: Text(
            "No notes available",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
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
