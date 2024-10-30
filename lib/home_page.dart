import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller = PersistentTabController(initialIndex: 0);


    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile JKN'),
        backgroundColor: Colors.transparent, // Membuat latar belakang transparan
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3366FF), Color(0xFF00CCFF)], // Contoh warna gradasi
            ),
          ),
        ),
        elevation: 0, // Menghilangkan bayangan di bawah AppBar
      ),

      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: Text('Masuk/Daftar', style: TextStyle(color: Colors.white)),
                ),
                Text('v4.9.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: EdgeInsets.only(top: 20, bottom: 20, left: 4, right: 4),
              children: choices.map((choice) => ChoiceCard(choice: choice)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class Choice {
  final String title;
  final ImageProvider icon;
  const Choice({required this.title, required this.icon});
}


const List<Choice> choices = const <Choice>[
  const Choice(title: 'Info Program JKN', icon: AssetImage("assets/info_jkn_new_icon.png")),
  const Choice(title: 'Info Lokasi Faskes', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Info Riwayat Pelayanan', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Bugar', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Rehab (Cicilan)', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Pendaftaran Peserta Baru', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Pendaftaran Pelayanan (Antrean)', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Konsultasi Dokter', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Perubahan Data Peserta', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Pengaduan Layanan JKN', icon: AssetImage("assets/lokasi_new_icon.png")),
];

class ChoiceCard extends StatelessWidget {
  final Choice choice; // Asumsikan Choice sudah didefinisikan dengan ImageProvider sebagai icon

  const ChoiceCard({Key? key, required this.choice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Image(image: choice.icon, width: 50.0, height: 50.0),
          Expanded( // Membuat widget Text memperluas secara vertikal
            child: Text(
              choice.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.0, // Menyesuaikan ukuran font sesuai keinginan
              ),
            ),
          ),
        ],
    );
  }

}

