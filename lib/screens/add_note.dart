import 'package:flutter/material.dart';
import 'package:notely/db/notes_database.dart';
import 'package:notely/models/note.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    if (_formKey.currentState!.validate()) {
      final newNote = Note(
        title: titleController.text,
        description: descriptionController.text,
      );
      await NotesDatabase.instance.create(newNote);
      Navigator.of(context).pop();
    }
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
                Icons.check,
                // color: Colors.black,
                size: 30.0,
              ),
              onPressed: () async {
                await saveNote();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              TextFormField(
                controller: titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: descriptionController,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: InputBorder.none,
                ),
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
