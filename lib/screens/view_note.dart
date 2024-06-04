import 'package:flutter/material.dart';
import 'package:notely/db/notes_database.dart';
import 'package:notely/models/note.dart';
import 'package:share_plus/share_plus.dart';

class ViewNote extends StatefulWidget {
  final int? noteId;
  const ViewNote({
    super.key,
    required this.noteId,
  });

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  bool isLoading = false;
  late Note notes;
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future<void> refreshNotes() async {
    setState(() => isLoading = true);
    notes = await NotesDatabase.instance.readNote(widget.noteId!);
    titleController = TextEditingController(text: notes.title);
    descriptionController = TextEditingController(text: notes.description);
    setState(() => isLoading = false);
  }

  Future<void> saveNote() async {
    final updatedNote = notes.copy(
      title: titleController.text,
      description: descriptionController.text,
    );
    await NotesDatabase.instance.updateNote(updatedNote);
  }

  Future<void> deleteNote() async {
    await NotesDatabase.instance.deleteNote(widget.noteId!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Container(
              color: Theme.of(context).colorScheme.onPrimary,
              child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(
                  Icons.delete,
                ),
                title: const Text(
                  'Delete Note',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await deleteNote();
                },
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 2.0,
              color: Colors.black,
              endIndent: 10.0,
              indent: 10.0,
            ),
            Container(
              color: Theme.of(context).colorScheme.onPrimary,
              child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.share),
                title: const Text(
                  'Share Note',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Share.share('${notes.title!}\n${notes.description!}');
                  Navigator.pop(context);
                  // Add your share logic here
                },
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 2.0,
              color: Colors.black,
              endIndent: 10.0,
              indent: 10.0,
            ),
            Container(
              color: Theme.of(context).colorScheme.onPrimary,
              child: ListTile(
                horizontalTitleGap: 5.0,
                leading: Icon(
                  Icons.push_pin,
                  color: notes.isPinned ? Colors.red : null,
                ),
                title: Text(
                  notes.isPinned ? 'Unpin from top' : 'Pin to top',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    notes = notes.copy(
                        isPinned: !notes.isPinned); // Toggle pin state
                  });
                  await NotesDatabase.instance.updateNote(notes);
                  refreshNotes();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        toolbarHeight: 80.0,
        automaticallyImplyLeading: false,
        leadingWidth: 150.0,
        leading: Row(
          children: [
            IconButton(
              padding: const EdgeInsets.only(left: 15.0),
              onPressed: () async {
                await saveNote();
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                // color: Colors.black,
                size: 24.0,
              ),
            ),
            const Text(
              'Notes',
              style: TextStyle(
                // color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.more_vert,
                // color: Colors.black,
                size: 30.0,
              ),
              onPressed: () {
                showMoreOptions(context);
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ],
              ),
            ),
    );
  }
}
