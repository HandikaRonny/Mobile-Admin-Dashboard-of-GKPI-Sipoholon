import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tambah_jemaat.dart';
import 'edit_jemaat.dart';

class ListJemaat extends StatefulWidget {
  const ListJemaat({Key? key}) : super(key: key);

  @override
  State<ListJemaat> createState() => _ListJemaatState();
}

class _ListJemaatState extends State<ListJemaat> {
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchJemaat();
  }

  Future<void> _fetchJemaat() async {
    final response = await http
        .get(Uri.parse('http://localhost/flutter_api/get_jemaat.php'));

    if (response.statusCode == 200) {
      final List<dynamic> jemaatData = json.decode(response.body);
      setState(() {
        _allUsers = jemaatData.cast<Map<String, dynamic>>();
        _foundUsers = _allUsers;
      });
    } else {
      throw Exception('Failed to load jemaat data');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["nama"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundUsers = results;
    });
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(user: user),
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
          'Data Jemaat',
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
                  labelText: 'Search by name', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundUsers[index]["nik"]),
                        color: Colors.blue,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () =>
                              _navigateToDetail(context, _foundUsers[index]),
                          child: ListTile(
                            title: Text(
                              'NIK: ${_foundUsers[index]["nik"]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama: ${_foundUsers[index]["nama"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Jenis Kelamin: ${_foundUsers[index]["jenis_kelamin"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Alamat: ${_foundUsers[index]["alamat"]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Tempat, Tanggal Lahir: ${_foundUsers[index]["tempat_lahir"] + ", " + _foundUsers[index]["tanggal_lahir"]}',
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahJemaat(),
            ),
          );
          if (result == true) {
            _fetchJemaat();
          }
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const DetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user['nama']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemProfile('NIK', user['nik'], Icons.person),
            SizedBox(height: 8),
            itemProfile('Nama', user['nama'], Icons.person),
            SizedBox(height: 8),
            itemProfile('Jenis Kelamin', user['jenis_kelamin'], Icons.person),
            SizedBox(height: 8),
            itemProfile('Alamat', user['alamat'], Icons.home),
            SizedBox(height: 8),
            itemProfile(
                'Tempat, Tanggal Lahir',
                '${user['tempat_lahir']}, ${user['tanggal_lahir']}',
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
                      builder: (context) => EditJemaat(jemaat: user),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text(
                  'Edit Jemaat',
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
