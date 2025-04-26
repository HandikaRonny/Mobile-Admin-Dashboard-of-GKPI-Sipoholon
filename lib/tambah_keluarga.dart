import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'list_keluarga.dart';

class TambahKeluarga extends StatefulWidget {
  @override
  _TambahKeluargaState createState() => _TambahKeluargaState();
}

class _TambahKeluargaState extends State<TambahKeluarga> {
  DateTime? _selectedDate;
  TextEditingController noKKController = TextEditingController();
  TextEditingController namaKeluargaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

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

  Future<void> _simpanDataKeluarga() async {
    final String noKK = noKKController.text
        .replaceAll(RegExp(r'\D'), ''); // Menghapus semua karakter selain angka
    final String namaKeluarga = namaKeluargaController.text;
    final String alamat = alamatController.text;
    final String tglNikah = _selectedDate != null
        ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
        : '';

    if (noKK.isEmpty ||
        namaKeluarga.isEmpty ||
        alamat.isEmpty ||
        tglNikah.isEmpty) {
      _showAlertDialog("Error", "Form harus diisi dengan benar.");
      return;
    }

    if (noKK.length != noKKController.text.length) {
      // Jika karakter telah dihapus, maka panjang teks akan berbeda
      _showAlertDialog("Error", "Nomor KK hanya boleh berisi angka.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/flutter_api/tambah_keluarga.php'), // Ganti dengan IP lokal yang sesuai
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'no_kk': noKK,
          'nama_keluarga': namaKeluarga,
          'alamat': alamat,
          'tgl_nikah': tglNikah,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data.contains("Data berhasil disimpan")) {
          _showAlertDialog(
            "Berhasil",
            "Data berhasil disimpan",
            () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ListKeluarga()),
              );
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Tambah Data Keluarga",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Column(
                children: <Widget>[
                  makeInput(
                      label: "Nomor KK:",
                      controller: noKKController,
                      inputType: TextInputType.number),
                  makeInput(
                      label: "Nama Keluarga:",
                      controller: namaKeluargaController),
                  makeInput(label: "Alamat:", controller: alamatController),
                  makeDatePicker(label: "Tanggal Nikah:"),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    )),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: _simpanDataKeluarga,
                  color: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: Text(
                    "Simpan",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({
    required String label,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget makeDatePicker({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Pilih Tanggal"
                      : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
