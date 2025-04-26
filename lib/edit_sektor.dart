import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditSektor extends StatefulWidget {
  final Map<String, dynamic> sektor;

  const EditSektor({Key? key, required this.sektor}) : super(key: key);

  @override
  _EditSektorState createState() => _EditSektorState();
}

class _EditSektorState extends State<EditSektor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaSektorController;

  @override
  void initState() {
    super.initState();
    _namaSektorController =
        TextEditingController(text: widget.sektor['nama_sektor']);
  }

  Future<void> _updateSektor() async {
    final String namaSektor = _namaSektorController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/update_sektor.php'),
        body: {
          'id_sektor': widget.sektor['id_sektor'].toString(),
          'nama_sektor': namaSektor,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.contains('success')) {
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update sektor')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update sektor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _namaSektorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Sektor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _namaSektorController,
                decoration: InputDecoration(
                  labelText: 'Nama Sektor',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter nama sektor';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateSektor();
                  }
                },
                child: Text('Update'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  padding: EdgeInsets.all(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
