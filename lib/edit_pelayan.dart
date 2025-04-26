import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'list_pelayan.dart';

class EditPelayan extends StatefulWidget {
  final Map<String, dynamic> pelayan;

  const EditPelayan({Key? key, required this.pelayan}) : super(key: key);

  @override
  _EditPelayanState createState() => _EditPelayanState();
}

class _EditPelayanState extends State<EditPelayan> {
  List<Map<String, dynamic>> _jemaatList = [];
  String? _selectedJabatan;
  DateTime? _tglTerimaJabatan;
  DateTime? _tglAkhirJabatan;

  @override
  void initState() {
    super.initState();
    _fetchJemaat();
    _selectedJabatan = widget.pelayan['jabatan'];
    _tglTerimaJabatan = DateTime.parse(widget.pelayan['tgl_terima_jabatan']);
    _tglAkhirJabatan = widget.pelayan['tgl_akhir_jabatan'] != null
        ? DateTime.parse(widget.pelayan['tgl_akhir_jabatan'])
        : null;
  }

  Future<void> _fetchJemaat() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/flutter_api/get_jemaat.php'));
      if (response.statusCode == 200) {
        final List<dynamic> jemaatData = json.decode(response.body);
        setState(() {
          _jemaatList = jemaatData.cast<Map<String, dynamic>>();
        });
      } else {
        print('Failed to load jemaat data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching jemaat data: $e');
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

  Future<void> _updateDataPelayan() async {
    if (_selectedJabatan == null || _tglTerimaJabatan == null) {
      _showAlertDialog("Error", "Form harus diisi dengan benar.");
      return;
    }

    final String tglTerimaJabatan =
        "${_tglTerimaJabatan!.year}-${_tglTerimaJabatan!.month.toString().padLeft(2, '0')}-${_tglTerimaJabatan!.day.toString().padLeft(2, '0')}";
    final String? tglAkhirJabatan = _tglAkhirJabatan != null
        ? "${_tglAkhirJabatan!.year}-${_tglAkhirJabatan!.month.toString().padLeft(2, '0')}-${_tglAkhirJabatan!.day.toString().padLeft(2, '0')}"
        : null;

    try {
      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/update_pelayan.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id_pelayan': widget.pelayan['id_pelayan'].toString(),
          'jabatan': _selectedJabatan!,
          'tgl_terima_jabatan': tglTerimaJabatan,
          'tgl_akhir_jabatan': tglAkhirJabatan ??
              '', // Kirim string kosong jika tglAkhirJabatan NULL
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data.contains("Data berhasil diperbarui")) {
          _showAlertDialog(
            "Berhasil",
            "Data berhasil diperbarui",
            () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ListPelayan()),
              );
            },
          );
        } else {
          _showAlertDialog("Error", data);
        }
      } else {
        _showAlertDialog("Error",
            'Failed to update data. Status code: ${response.statusCode}');
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
                    "Edit Data Pelayan",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Column(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Jabatan',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    value: _selectedJabatan,
                    items: ['Pendeta', 'Sekretaris', 'Bendahara', 'Penatua']
                        .map((jabatan) {
                      return DropdownMenuItem<String>(
                        value: jabatan,
                        child: Text(jabatan),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedJabatan = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  _makeDatePicker(
                    label: "Tanggal Terima Jabatan",
                    selectedDate: _tglTerimaJabatan,
                    onDateChanged: (date) {
                      setState(() {
                        _tglTerimaJabatan = date;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  _makeDatePicker(
                    label: "Tanggal Akhir Jabatan (opsional)",
                    selectedDate: _tglAkhirJabatan,
                    onDateChanged: (date) {
                      setState(() {
                        _tglAkhirJabatan = date;
                      });
                    },
                  ),
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
                  ),
                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: _updateDataPelayan,
                  color: Colors.blueAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
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
    );
  }

  Widget _makeDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            _selectDate(context, selectedDate, onDateChanged);
          },
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"
                      : "Pilih Tanggal",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime? selectedDate,
      Function(DateTime?) onDateChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}
