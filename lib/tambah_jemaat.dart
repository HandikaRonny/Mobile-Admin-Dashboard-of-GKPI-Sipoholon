import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahJemaat extends StatefulWidget {
  @override
  _TambahJemaatState createState() => _TambahJemaatState();
}

class _TambahJemaatState extends State<TambahJemaat> {
  List<Map<String, dynamic>> _keluargaList = [];
  List<Map<String, dynamic>> _sektorList = [];
  String? _selectedNoKK;
  String? _selectedIdSektor;
  DateTime? _selectedDate;
  TextEditingController nikController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController tempatLahirController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  void _showAlertDialog(String title, String message,
      [VoidCallback? onOkPressed]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpanDataJemaat() async {
    final String nik = nikController.text;
    final String nama = namaController.text;
    final String alamat = alamatController.text;
    final String tempatLahir = tempatLahirController.text;
    final String tanggalLahir = _selectedDate != null
        ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
        : '';
    final String jenisKelamin = _selectedGender;

    if (nik.isEmpty ||
        nama.isEmpty ||
        alamat.isEmpty ||
        tempatLahir.isEmpty ||
        tanggalLahir.isEmpty ||
        _selectedNoKK == null ||
        _selectedIdSektor == null ||
        jenisKelamin.isEmpty) {
      _showAlertDialog("Error", "Form harus diisi dengan benar.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/tambah_jemaat.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'nik': nik,
          'nama': nama,
          'jenis_kelamin': jenisKelamin,
          'alamat': alamat,
          'tempat_lahir': tempatLahir,
          'tanggal_lahir': tanggalLahir,
          'no_kk': _selectedNoKK!,
          'id_sektor': _selectedIdSektor!,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data.contains("Data berhasil disimpan")) {
          _showAlertDialog(
            "Berhasil",
            "Data berhasil disimpan",
            () {
              Navigator.of(context).pop(true);
            },
          );
        } else {
          _showAlertDialog("Error", data);
        }
      } else {
        _showAlertDialog("Error",
            'Failed to save data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog("Error", 'Exception: $e');
    }
  }

  String _selectedGender = 'Laki-laki';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Tambah Data Jemaat",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                makeInput(
                    label: "NIK:",
                    controller: nikController,
                    inputType: TextInputType.number),
                makeInput(label: "Nama:", controller: namaController),
                makeInput(label: "Alamat:", controller: alamatController),
                makeInput(
                    label: "Tempat Lahir:", controller: tempatLahirController),
                makeDatePicker(label: "Tanggal Lahir:"),
                makeDropdown(
                  label: "Nomor KK:",
                  value: _selectedNoKK,
                  items: _keluargaList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['no_kk'],
                      child: Text(item['nama_keluarga']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedNoKK = newValue!;
                    });
                  },
                ),
                makeDropdown(
                  label: "Sektor:",
                  value: _selectedIdSektor,
                  items: _sektorList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['id_sektor'],
                      child: Text(item['nama_sektor']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIdSektor = newValue!;
                    });
                  },
                ),
                makeGenderSelection(),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: _simpanDataJemaat,
                    color: Color(0xff0095FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      "Simpan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget makeInput({label, controller, inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        TextField(
          keyboardType: inputType,
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget makeDatePicker({label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Text(
              _selectedDate == null
                  ? 'Pilih Tanggal'
                  : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
              style: TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget makeDropdown(
      {required String label,
      required String? value,
      required List<DropdownMenuItem<String>> items,
      required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          onChanged: onChanged,
          items: items,
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget makeGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Jenis Kelamin:",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Radio<String>(
              value: 'Laki-laki',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            Text("Laki-laki"),
            Radio<String>(
              value: 'Perempuan',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            Text("Perempuan"),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
