import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'jadwal_ibadah.dart';

class EditJadwalIbadah extends StatefulWidget {
  final Map<String, dynamic> jadwalIbadah;

  const EditJadwalIbadah({Key? key, required this.jadwalIbadah})
      : super(key: key);

  @override
  _EditJadwalIbadahState createState() => _EditJadwalIbadahState();
}

class _EditJadwalIbadahState extends State<EditJadwalIbadah> {
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpanPerubahanJadwalIbadah() async {
    final String idJadwalIbadah =
        widget.jadwalIbadah['id_jadwal_ibadah'].toString();
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
        Uri.parse('http://localhost/flutter_api/update_jadwal_ibadah.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id_jadwal_ibadah': idJadwalIbadah,
          'nama_ibadah': namaIbadah,
          'tgl_ibadah': tglIbadah,
          'waktu_ibadah': waktuIbadah,
          'jenis_ibadah': jenisIbadah,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data.contains("Data berhasil diperbarui")) {
          _showAlertDialog("Berhasil", "Data berhasil diperbarui", () {
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
  void initState() {
    super.initState();
    namaIbadahController.text = widget.jadwalIbadah['nama_ibadah'];
    _selectedDate = DateTime.parse(widget.jadwalIbadah['tgl_ibadah']);
    final waktuIbadah =
        widget.jadwalIbadah['waktu_ibadah'].toString().split(':');
    _selectedTime = TimeOfDay(
        hour: int.parse(waktuIbadah[0]), minute: int.parse(waktuIbadah[1]));
    _selectedJenisIbadah = widget.jadwalIbadah['jenis_ibadah'];
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
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Column(
                children: <Widget>[
                  Text(
                    "Edit Jadwal Ibadah",
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
                padding: const EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    )),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: _simpanPerubahanJadwalIbadah,
                  color: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Text(
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
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        const SizedBox(height: 30),
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
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
        const SizedBox(height: 30),
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
              style: const TextStyle(
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
        const SizedBox(height: 30),
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
              style: const TextStyle(
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
        const SizedBox(height: 30),
      ],
    );
  }
}
