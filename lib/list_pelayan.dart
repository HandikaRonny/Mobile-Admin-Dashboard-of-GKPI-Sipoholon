import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tambah_pelayan.dart';
import 'edit_pelayan.dart';

class ListPelayan extends StatefulWidget {
  @override
  _ListPelayanState createState() => _ListPelayanState();
}

class _ListPelayanState extends State<ListPelayan> {
  List<Map<String, dynamic>> _allPelayan = [];
  List<Map<String, dynamic>> _foundPelayan = [];

  @override
  void initState() {
    super.initState();
    _fetchPelayan();
  }

  Future<void> _fetchPelayan() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/flutter_api/get_pelayan.php'));

      if (response.statusCode == 200) {
        final List<dynamic> pelayanData = json.decode(response.body);
        setState(() {
          _allPelayan = pelayanData.cast<Map<String, dynamic>>();
          _foundPelayan = _allPelayan;
        });
      } else {
        print('Failed to load pelayan data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pelayan data: $e');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allPelayan;
    } else {
      results = _allPelayan
          .where((pelayan) => pelayan["nama"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundPelayan = results;
    });
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> pelayan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(pelayan: pelayan),
      ),
    );
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
          'Data Pelayan',
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
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  labelText: 'Search by Name', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundPelayan.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundPelayan.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundPelayan[index]["id_pelayan"]),
                        color: Colors.blue,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () =>
                              _navigateToDetail(context, _foundPelayan[index]),
                          child: ListTile(
                            title: Text(
                              'Nama: ${_foundPelayan[index]["nama"]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jabatan: ${_foundPelayan[index]["jabatan"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Tanggal Terima Jabatan: ${_foundPelayan[index]["tgl_terima_jabatan"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                if (_foundPelayan[index]["tgl_akhir_jabatan"] !=
                                    null)
                                  Text(
                                    'Tanggal Akhir Jabatan: ${_foundPelayan[index]["tgl_akhir_jabatan"]}',
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TambahPelayan()));
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> pelayan;

  const DetailPage({Key? key, required this.pelayan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pelayan['nama']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemProfile('NIK', pelayan['nik'], Icons.person),
            const SizedBox(height: 10),
            itemProfile('Nama', pelayan['nama'], Icons.person),
            const SizedBox(height: 10),
            itemProfile('Jabatan', pelayan['jabatan'], Icons.work),
            const SizedBox(height: 10),
            itemProfile('Tanggal Terima Jabatan', pelayan['tgl_terima_jabatan'],
                Icons.calendar_today),
            const SizedBox(height: 10),
            if (pelayan['tgl_akhir_jabatan'] != null)
              itemProfile('Tanggal Akhir Jabatan', pelayan['tgl_akhir_jabatan'],
                  Icons.calendar_today),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPelayan(pelayan: pelayan),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text(
                  'Edit Pelayan',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
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
