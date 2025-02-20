import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final CollectionReference students =
      FirebaseFirestore.instance.collection('students');

  void _editStudent(DocumentSnapshot doc) {
    TextEditingController nameController =
        TextEditingController(text: doc['name']);
    TextEditingController idController = TextEditingController(text: doc['id']);
    TextEditingController yearController =
        TextEditingController(text: doc['year']);
    String department = doc['department'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID')),
            TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year')),
            DropdownButtonFormField<String>(
              value: department,
              onChanged: (value) => department = value!,
              items: ['CS', 'DS']
                  .map((dept) =>
                      DropdownMenuItem(value: dept, child: Text(dept)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              students.doc(doc.id).update({
                'name': nameController.text,
                'id': idController.text,
                'year': yearController.text,
                'department': department,
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(String id) {
    students.doc(id).delete();
  }

  void _addStudent() {
    TextEditingController nameController = TextEditingController();
    TextEditingController idController = TextEditingController();
    TextEditingController yearController = TextEditingController();
    String department = 'CS';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID')),
            TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year')),
            DropdownButtonFormField<String>(
              value: department,
              onChanged: (value) => department = value!,
              items: ['CS', 'DS']
                  .map((dept) =>
                      DropdownMenuItem(value: dept, child: Text(dept)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              students.add({
                'name': nameController.text,
                'id': idController.text,
                'year': yearController.text,
                'department': department,
              });
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student List')),
      body: StreamBuilder(
        stream: students.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(
                    'ID: ${doc['id']} | Year: ${doc['year']} | ${doc['department']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editStudent(doc)),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteStudent(doc.id)),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addStudent,
      ),
    );
  }
}
