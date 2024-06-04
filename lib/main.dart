import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notely/constants/constants.dart';
import 'package:notely/screens/add_note.dart';
import 'package:notely/screens/view_note.dart';
import 'package:notely/db/notes_database.dart';
import 'package:notely/models/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  final themeMode = await themeService.getThemeMode();
  runApp(MyApp(themeMode: themeMode));
}

class MyApp extends StatefulWidget {
  final ThemeMode themeMode;

  const MyApp({super.key, required this.themeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
  }

  void _toggleThemeMode(ThemeMode theme) async {
    setState(() {
      _themeMode = theme;
    });
    await _themeService.saveThemeMode(theme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: MyAppThemes.lightTheme,
      darkTheme: MyAppThemes.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: FlutterNoteApp(
        themeMode: _themeMode,
        toggleThemeMode: _toggleThemeMode,
      ),
    );
  }
}

class FlutterNoteApp extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> toggleThemeMode;

  const FlutterNoteApp({
    super.key,
    required this.themeMode,
    required this.toggleThemeMode,
  });

  @override
  State<FlutterNoteApp> createState() => _FlutterNoteAppState();
}

class _FlutterNoteAppState extends State<FlutterNoteApp> {
  List<Note?>? notes;
  List<Note?>? filteredNotes;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshNotes();
    searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshNotes() async {
    setState(() => isLoading = true);
    notes = await NotesDatabase.instance.readAllNotes();
    notes!.sort((a, b) {
      if (a!.isPinned && !b!.isPinned) {
        return -1;
      } else if (!a.isPinned && b!.isPinned) {
        return 1;
      } else {
        return 0;
      }
    });
    filteredNotes = notes;
    setState(() => isLoading = false);
  }

  void _filterNotes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes?.where((note) {
        return note!.title!.toLowerCase().contains(query) ||
            note.description!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        toolbarHeight: 80.0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Notely',
            style: TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.only(right: 25.0),
            icon: Icon(
              isDarkMode
                  ? FontAwesomeIcons.solidSun
                  : FontAwesomeIcons.solidMoon,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              isDarkMode
                  ? widget.toggleThemeMode(ThemeMode.light)
                  : widget.toggleThemeMode(ThemeMode.dark);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
              controller: searchController,
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.black),
                hintText: 'Search notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFD9D9D9),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: NotesDatabase.instance.readAllNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredNotes!.isEmpty
                  ? const Center(child: Text('No notes found'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredNotes!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ViewNote(
                                    noteId: filteredNotes![index]!.id,
                                  ),
                                ),
                              );
                              refreshNotes(); // Refresh notes after updating a note
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                  height: 200.0,
                                  color: Theme.of(context).primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Stack(
                                      children: [
                                        Visibility(
                                          visible: notes![index]!.isPinned,
                                          child: const Positioned(
                                            right: 0.0,
                                            top: 0.0,
                                            child: Icon(Icons.push_pin),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              filteredNotes![index]!
                                                  .title
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  filteredNotes![index]!
                                                      .description
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddNote(),
            ),
          );
          refreshNotes(); // Refresh notes after adding or updating a note
        },
        shape: const CircleBorder(),
        child: Icon(
          Icons.add,
          size: 50,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
