import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/user.jpeg'),
            ),
            const SizedBox(height: 20),
            itemProfile('NIK', '1212010707040004', CupertinoIcons.number),
            const SizedBox(height: 10),
            itemProfile('Nama', 'Handika Harahap', CupertinoIcons.person),
            const SizedBox(height: 10),
            itemProfile('Jenis Kelamin', 'Laki-laki', CupertinoIcons.location),
            const SizedBox(height: 10),
            itemProfile('Alamat', 'Balige', CupertinoIcons.location),
            const SizedBox(height: 10),
            itemProfile('Tempat, Tanggal Lahir', 'Balige, 07 07 2004',
                CupertinoIcons.location),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Edit Profile')),
            )
          ],
        ),
      ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Colors.blue.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
