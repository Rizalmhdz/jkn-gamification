import 'package:carousel_slider/carousel_slider.dart';
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/mjkn_header_colorful.png",
                fit: BoxFit.cover,
              ),
            ),
            // AppBar content
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 20, left: 20),
              child : Image.asset(
                'assets/new_mjkn_2022_white.png',
                height: 80,
                width: 80,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(Icons.login, color: Colors.black),
                      Container( width: 4,),
                      Text('Masuk/Daftar', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Text('v4.9.0',  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(
            height: 450,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Jumlah kolom
                mainAxisSpacing: 30,
                crossAxisSpacing: 0,
                childAspectRatio: 1, // Aspek rasio 1:1 agar berbentuk kotak
              ),
              itemCount: choices.length,
              itemBuilder: (context, index) {
                return ChoiceCard(choice: choices[index]);
              },
            ),
          ),

          CarouselSlider(
              items: List.generate(5, (index) {
                  return infoBanner("assets/banners/$index.png");
                }),
               options: CarouselOptions(
                 height: 180, // Sesuaikan tinggi banner sesuai kebutuhan
                 viewportFraction: 0.8, // Lebar setiap item
                 enableInfiniteScroll: true, // Mengaktifkan scrolling berulang
                 enlargeCenterPage: true, // Membuat item tengah lebih besar
                 autoPlay: false, // Autoplay
                 autoPlayInterval: Duration(seconds: 10),
                 autoPlayAnimationDuration: Duration(milliseconds: 5000),
                 scrollDirection: Axis.horizontal,
               ),
            )

        ],
      ),
    );
  }
}

Widget infoBanner(String imagePath) {
  return Container(
    margin: EdgeInsets.only(left: 20, top: 0),
    child: Material(
      elevation: 10, // Atur besar shadow sesuai kebutuhan
      borderRadius: BorderRadius.circular(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white, // Warna latar belakang tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () {
          // Tambahkan aksi ketika tombol ditekan, jika ada
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            imagePath,
            height: 180,
            width: 400, // Atur lebar sesuai kebutuhan
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );
}

class Choice {
  final String title;
  final ImageProvider icon;
  const Choice({required this.title, required this.icon});
}


const List<Choice> choices = const <Choice>[
  const Choice(title: 'Info Program JKN', icon: AssetImage("assets/info_jkn_new_icon.png")),
  const Choice(title: 'Info Lokasi Faskes', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Info Riwayat Pelayanan', icon: AssetImage("assets/icare_icon_3.png")),
  const Choice(title: 'Skrining', icon: AssetImage("assets/skrining_new_icon.png")),
  const Choice(title: 'Rehab (Cicilan)', icon: AssetImage("assets/cicilan_icon.png")),
  const Choice(title: 'Pendaftaran Peserta Baru', icon: AssetImage("assets/pendaftaran_new_icon.png")),
  const Choice(title: 'Info Peserta', icon: AssetImage("assets/peserta_new_icon.png")),
  const Choice(title: 'Pendaftaran Pelayanan (Antrean)', icon: AssetImage("assets/infojkn_graphics_icon.png")),
  const Choice(title: 'Konsultasi Dokter', icon: AssetImage("assets/konsultasi_new_icon.png")),
  const Choice(title: 'Perubahan Data Peserta', icon: AssetImage("assets/lokasi_new_icon.png")),
  const Choice(title: 'Pengaduan Layanan JKN', icon: AssetImage("assets/informasipengaduan_new_icon.png")),
  const Choice(title: 'Menu Lainnya', icon: AssetImage("assets/lokasi_new_icon.png")),
];

class ChoiceCard extends StatelessWidget {
  final Choice choice; // Asumsikan Choice sudah didefinisikan dengan ImageProvider sebagai icon

  const ChoiceCard({Key? key, required this.choice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        children: <Widget>[
          Image(image: choice.icon, width: 70.0, height: 70.0),
          Container(
            height: 4,
          ),
          Expanded( // Membuat widget Text memperluas secara vertikal
            child: Text(
              maxLines: 2,
              choice.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.0, // Menyesuaikan ukuran font sesuai keinginan
              ),
            ),
          ),
        ],
      ),
    );
  }

}

