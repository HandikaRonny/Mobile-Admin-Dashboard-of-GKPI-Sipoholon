import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tambah_sektor.dart';
import 'edit_sektor.dart';

class ListSektor extends StatefulWidget {
  final Map<String, String>? sektorBaru;

  ListSektor({this.sektorBaru});

  @override
  _ListSektorState createState() => _ListSektorState();
}

class _ListSektorState extends State<ListSektor> {
  List<Map<String, dynamic>> _allSektors = [];

  @override
  void initState() {
    super.initState();
    _fetchSektor();
  }

  Future<void> _fetchSektor() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/flutter_api/get_sektor.php'));

      if (response.statusCode == 200) {
        final List<dynamic> sektorData = json.decode(response.body);
        if (sektorData.isNotEmpty) {
          setState(() {
            _allSektors = sektorData.cast<Map<String, dynamic>>();
          });
        } else {
          print('No data found');
        }
      } else {
        print('Failed to load sektor data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sektor data: $e');
    }
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> sektor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSektorPage(sektor: sektor),
      ),
    ).then((value) {
      if (value == true) {
        _fetchSektor(); // Refresh list after returning from edit page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Text(
          'Data Sektor',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _allSektors.isNotEmpty
                  ? ListView.builder(
                      itemCount: _allSektors.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_allSektors[index]["id_sektor"]),
                        color: Colors.blue,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () =>
                              _navigateToDetail(context, _allSektors[index]),
                          child: ListTile(
                            title: Text(
                              'ID Sektor: ${_allSektors[index]["id_sektor"]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama Sektor: ${_allSektors[index]["nama_sektor"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TambahSektor()));
        },
      ),
    );
  }
}

class DetailSektorPage extends StatelessWidget {
  final Map<String, dynamic> sektor;

  const DetailSektorPage({Key? key, required this.sektor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sektor['nama_sektor']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemProfile('ID Sektor', sektor['id_sektor'].toString(),
                Icons.account_tree),
            const SizedBox(height: 10),
            itemProfile('Nama Sektor', sektor['nama_sektor'], Icons.home),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSektor(sektor: sektor),
                    ),
                  );
                  if (result == true) {
                    Navigator.pop(
                        context, true); // Return true to indicate success
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text(
                  'Edit Sektor',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 5),
            color: Colors.blue.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
