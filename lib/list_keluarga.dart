import 'package:flutter/material.dart';
import 'package:pam_project/tambah_keluarga.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_keluarga.dart';
import 'tambah_jemaat.dart';

class ListKeluarga extends StatefulWidget {
  @override
  _ListKeluargaState createState() => _ListKeluargaState();
}

class _ListKeluargaState extends State<ListKeluarga> {
  List<Map<String, dynamic>> _allFamilies = [];
  List<Map<String, dynamic>> _foundFamilies = [];

  @override
  void initState() {
    super.initState();
    _fetchKeluarga();
  }

  Future<void> _fetchKeluarga() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/flutter_api/get_keluarga.php'));

      if (response.statusCode == 200) {
        final List<dynamic> keluargaData = json.decode(response.body);
        setState(() {
          _allFamilies = keluargaData.cast<Map<String, dynamic>>();
          _foundFamilies = _allFamilies;
        });
      } else {
        print('Failed to load keluarga data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching keluarga data: $e');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFamilies;
    } else {
      results = _allFamilies
          .where((family) => family["nama_keluarga"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundFamilies = results;
    });
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> family) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(family: family),
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
          'Data Keluarga',
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
                  labelText: 'Search by Family Name',
                  suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundFamilies.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundFamilies.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundFamilies[index]["no_kk"]),
                        color: Colors.blue,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () =>
                              _navigateToDetail(context, _foundFamilies[index]),
                          child: ListTile(
                            title: Text(
                              'Nomor KK: ${_foundFamilies[index]["no_kk"]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama Keluarga: ${_foundFamilies[index]["nama_keluarga"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Alamat: ${_foundFamilies[index]["alamat"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Tanggal Nikah: ${_foundFamilies[index]["tgl_nikah"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons
                                  .arrow_forward_ios, // Ini adalah ikon anak panah ke kanan
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
              MaterialPageRoute(builder: (context) => TambahKeluarga()));
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> family;

  const DetailPage({Key? key, required this.family}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(family['nama_keluarga']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemProfile('Nomor KK', family['no_kk'], Icons.family_restroom),
            const SizedBox(height: 10),
            itemProfile('Nama Keluarga', family['nama_keluarga'], Icons.person),
            const SizedBox(height: 10),
            itemProfile('Alamat', family['alamat'], Icons.home),
            const SizedBox(height: 10),
            itemProfile(
                'Tanggal Nikah', family['tgl_nikah'], Icons.calendar_today),
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
                        builder: (context) => TambahJemaat(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text(
                    'Tambah Jemaat',
                    style: TextStyle(color: Colors.black),
                  )),
            ),
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
                        builder: (context) => EditKeluarga(family: family),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text(
                    'Edit Keluarga',
                    style: TextStyle(color: Colors.black),
                  )),
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
