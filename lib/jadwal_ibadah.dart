import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pam_project/edit_jadwal_ibadah.dart';
import 'dart:convert';
import 'tambah_jadwal_ibadah.dart';

class ListJadwalIbadah extends StatefulWidget {
  @override
  _ListJadwalIbadahState createState() => _ListJadwalIbadahState();
}

class _ListJadwalIbadahState extends State<ListJadwalIbadah> {
  List<Map<String, dynamic>> _allJadwalIbadah = [];
  List<Map<String, dynamic>> _foundJadwalIbadah = [];

  @override
  void initState() {
    super.initState();
    _fetchJadwalIbadah();
  }

  Future<void> _fetchJadwalIbadah() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/flutter_api/get_jadwal_ibadah.php'));

      if (response.statusCode == 200) {
        final List<dynamic> jadwalIbadahData = json.decode(response.body);
        setState(() {
          _allJadwalIbadah = jadwalIbadahData.cast<Map<String, dynamic>>();
          _foundJadwalIbadah = _allJadwalIbadah;
        });
      } else {
        print('Failed to load jadwal ibadah data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching jadwal ibadah data: $e');
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allJadwalIbadah;
    } else {
      results = _allJadwalIbadah
          .where((jadwal) => jadwal["nama_ibadah"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundJadwalIbadah = results;
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
          'Data Jadwal Ibadah',
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
                  labelText: 'Cari Berdasarkan Nama Ibadah',
                  suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundJadwalIbadah.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundJadwalIbadah.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(
                            _foundJadwalIbadah[index]["id_jadwal_ibadah"]),
                        color: Colors.blue,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(
                            'Nama Ibadah: ${_foundJadwalIbadah[index]["nama_ibadah"]}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Ibadah: ${_foundJadwalIbadah[index]["tgl_ibadah"]}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Waktu Ibadah: ${_foundJadwalIbadah[index]["waktu_ibadah"]}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    jadwalIbadah: _foundJadwalIbadah[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : const Text(
                      'Tidak ada hasil',
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
              MaterialPageRoute(builder: (context) => TambahJadwalIbadah()));
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> jadwalIbadah;

  const DetailPage({Key? key, required this.jadwalIbadah}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Jadwal Ibadah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemDetail('Nama Ibadah', jadwalIbadah['nama_ibadah'], Icons.event),
            const SizedBox(height: 10),
            itemDetail('Tanggal Ibadah', jadwalIbadah['tgl_ibadah'],
                Icons.calendar_today),
            const SizedBox(height: 10),
            itemDetail('Waktu Ibadah', jadwalIbadah['waktu_ibadah'],
                Icons.access_time),
            const SizedBox(height: 10),
            itemDetail(
                'Jenis Ibadah', jadwalIbadah['jenis_ibadah'], Icons.category),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditJadwalIbadah(jadwalIbadah: jadwalIbadah),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text(
                  'Edit Jadwal Ibadah',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemDetail(String title, String subtitle, IconData iconData) {
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
