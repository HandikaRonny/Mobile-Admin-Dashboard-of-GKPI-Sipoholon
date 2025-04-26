import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'jadwal_ibadah.dart';

class TambahJadwalIbadah extends StatefulWidget {
  @override
  _TambahJadwalIbadahState createState() => _TambahJadwalIbadahState();
}

class _TambahJadwalIbadahState extends State<TambahJadwalIbadah> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  TextEditingController namaIbadahController = TextEditingController();
  String? _selectedJenisIbadah;

  final List<String> _jenisIbadahOptions = [
    'Mingguan',
    'Situasional',
    'Sektor',
    'Dukacita'
  ];

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

  Future<void> _simpanDataJadwalIbadah() async {
    final String namaIbadah = namaIbadahController.text;
    final String jenisIbadah = _selectedJenisIbadah ?? '';
    final String tglIbadah = _selectedDate != null
        ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
        : '';
    final String waktuIbadah = _selectedTime != null
        ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
        : '';

    if (namaIbadah.isEmpty ||
        jenisIbadah.isEmpty ||
        tglIbadah.isEmpty ||
        waktuIbadah.isEmpty) {
      _showAlertDialog("Error", "Semua field harus diisi.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/tambah_jadwal_ibadah.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'nama_ibadah': namaIbadah,
          'tgl_ibadah': tglIbadah,
          'waktu_ibadah': waktuIbadah,
          'jenis_ibadah': jenisIbadah,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data.contains("Data berhasil disimpan")) {
          _showAlertDialog("Berhasil", "Data berhasil disimpan", () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ListJadwalIbadah()),
            );
          });
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
                    "Tambah Jadwal Ibadah",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Column(
                children: <Widget>[
                  makeInput(
                      label: "Nama Ibadah:", controller: namaIbadahController),
                  makeDropdown(
                      label: "Jenis Ibadah:",
                      options: _jenisIbadahOptions,
                      value: _selectedJenisIbadah),
                  makeDatePicker(label: "Tanggal Ibadah:"),
                  makeTimePicker(label: "Waktu Ibadah:"),
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
                  onPressed: _simpanDataJadwalIbadah,
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

  Widget makeDropdown({
    required String label,
    required List<String> options,
    required String? value,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedJenisIbadah = newValue;
            });
          },
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
            ElevatedButton(
              onPressed: () async {
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
              child: Text(
                _selectedDate != null
                    ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                    : 'Pilih Tanggal',
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget makeTimePicker({required String label}) {
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
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
              child: Text(
                _selectedTime != null
                    ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
                    : 'Pilih Waktu',
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
