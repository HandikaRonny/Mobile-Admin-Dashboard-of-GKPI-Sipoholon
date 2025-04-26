import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditJemaat extends StatefulWidget {
  final Map<String, dynamic> jemaat;

  EditJemaat({required this.jemaat});

  @override
  _EditJemaatState createState() => _EditJemaatState();
}

class _EditJemaatState extends State<EditJemaat> {
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  late String _selectedNoKK;
  late String _selectedIdSektor;
  late String _selectedStatusGereja;
  late String _selectedStatusNikah;

  List<Map<String, dynamic>> _keluargaList = [];
  List<Map<String, dynamic>> _sektorList = [];
  List<String> _statusGerejaList = ['Aktif', 'Pindah', 'Meninggal', 'Nonaktif'];
  List<String> _statusNikahList = ['Sudah', 'Belum'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.jemaat['nama']);
    _alamatController = TextEditingController(text: widget.jemaat['alamat']);
    _tempatLahirController =
        TextEditingController(text: widget.jemaat['tempat_lahir']);
    _tanggalLahirController =
        TextEditingController(text: widget.jemaat['tanggal_lahir']);
    _selectedNoKK = widget.jemaat['no_kk'];
    _selectedIdSektor = widget.jemaat['id_sektor'];
    _selectedStatusGereja = widget.jemaat['status_gereja'];
    _selectedStatusNikah =
        widget.jemaat['status_nikah'] == 1 ? 'Sudah' : 'Belum';

    fetchKeluarga();
    fetchSektor();
  }

  Future<void> fetchKeluarga() async {
    final response = await http
        .get(Uri.parse('http://localhost/flutter_api/get_keluarga.php'));
    if (response.statusCode == 200) {
      setState(() {
        _keluargaList =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load keluarga');
    }
  }

  Future<void> fetchSektor() async {
    final response = await http
        .get(Uri.parse('http://localhost/flutter_api/get_sektor.php'));
    if (response.statusCode == 200) {
      setState(() {
        _sektorList =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load sektor');
    }
  }

  Future<void> updateJemaat() async {
    final response = await http.post(
      Uri.parse('http://localhost/flutter_api/update_jemaat.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nik': widget.jemaat['nik'],
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'tempat_lahir': _tempatLahirController.text,
        'tanggal_lahir': _tanggalLahirController.text,
        'no_kk': _selectedNoKK,
        'id_sektor': _selectedIdSektor,
        'status_gereja': _selectedStatusGereja,
        'status_nikah': _selectedStatusNikah == 'Sudah' ? 1 : 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['message'] == "Data jemaat berhasil diupdate.") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Data jemaat berhasil diupdate."),
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal mengupdate data jemaat."),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Failed to update data jemaat. Status code: ${response.statusCode}"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Jemaat'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _tempatLahirController,
              decoration: InputDecoration(labelText: 'Tempat Lahir'),
            ),
            TextField(
              controller: _tanggalLahirController,
              decoration: InputDecoration(labelText: 'Tanggal Lahir'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedNoKK,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedNoKK = newValue!;
                });
              },
              items: _keluargaList.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> keluarga) {
                return DropdownMenuItem<String>(
                  value: keluarga['no_kk'],
                  child: Text(keluarga['nama_keluarga']),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Nomor KK'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedIdSektor,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedIdSektor = newValue!;
                });
              },
              items: _sektorList
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> sektor) {
                return DropdownMenuItem<String>(
                  value: sektor['id_sektor'],
                  child: Text(sektor['nama_sektor']),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Sektor'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatusGereja,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatusGereja = newValue!;
                });
              },
              items: _statusGerejaList
                  .map<DropdownMenuItem<String>>((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Status Gereja'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatusNikah,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatusNikah = newValue!;
                });
              },
              items: _statusNikahList
                  .map<DropdownMenuItem<String>>((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Status Nikah'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateJemaat();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
