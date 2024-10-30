import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class MembacaBeritaPage extends StatefulWidget {
  final String judul;
  final String isi;
  final String dilihat;
  final String imagePath;
  final String tanggal;

  MembacaBeritaPage({
    required this.judul,
    required this.isi,
    required this.dilihat,
    required this.imagePath,
    required this.tanggal,
  });

  @override
  _MembacaBeritaPageState createState() => _MembacaBeritaPageState();
}

class _MembacaBeritaPageState extends State<MembacaBeritaPage> {


  String formatTanggal(String tanggal) {
    DateFormat inputFormat = DateFormat('yyyy-MM-dd');
    DateTime dateTime = inputFormat.parse(tanggal);
    DateFormat outputFormat = DateFormat('dd MMM yyyy');
    return outputFormat.format(dateTime).toUpperCase();
  }

  String repeatAndFormatString(String input) {
    String repeated = input * 10;

    List<String> parts = repeated.split('.');
    StringBuffer buffer = StringBuffer();

    // Menambahkan tanda titik kembali dan menambahkan baris baru setiap dua titik
    for (int i = 0; i < parts.length - 1; i++) {
      buffer.write(parts[i]);
      buffer.write('.');
      if ((i + 1) % 2 == 0 && i != parts.length - 2) {
        buffer.writeln();
        buffer.writeln();
      }
    }
    if (parts.last.isNotEmpty) {
      buffer.write(parts.last);
    }

    return buffer.toString();
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/mjkn_header_colorful_2.png",
                fit: BoxFit.cover,
              ),
            ),
            // AppBar content
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "JAMKESNEWS",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              centerTitle: true,
              actions: <Widget>[

                Visibility(
                  visible: false,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.transparent),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 40,
              width: screenWidth,
              margin: EdgeInsets.all(20),
              color: Color(0xFFF40000),
              child: Stack(
                alignment: AlignmentDirectional.center,
                  children: [
                    Positioned(
                      left: 10,
                      child: Text(
                      '${formatTanggal(widget.tanggal)}  |  DILIHAT ${widget.dilihat} KALI',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1,
                        )
                      ),
                    ),
                    Positioned(
                      right: 10,
                        child: Row(
                          children:  [
                            Image.asset('assets/icons/facebook.png', width: 20, height: 20),
                            Container( padding: EdgeInsets.all(2),),
                            Image.asset('assets/icons/twitter.png', width: 18, height: 18),
                            Container( padding: EdgeInsets.all(3),),
                            Image.asset('assets/icons/whatsapp.png', width: 18, height: 18),
                          ],
                        )
                    ),

                  ],
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              child:  Text(
                widget.judul,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Image.asset(widget.imagePath, fit: BoxFit.cover),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                repeatAndFormatString(widget.isi),
                style: TextStyle(fontSize: 16),
              ),
            ),
            // Anda bisa menambahkan lebih banyak komponen di sini
          ],
        ),
      ),
    );
  }
}
