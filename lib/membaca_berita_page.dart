import 'package:flutter/material.dart';
import 'package:jkn_gamification/service/navbar_visibility_provider.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.judul),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset(widget.imagePath),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                widget.judul,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.dilihat != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Views: ${widget.dilihat}"),
              ),
            if (widget.tanggal != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Published on ${widget.tanggal}"),
              ),
            // Anda bisa menambahkan lebih banyak konten atau interaktivitas di sini
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    setState(() {
      Provider.of<NavBarVisibilityProvider>(context, listen: false).setVisible(true);
    });
    super.dispose();
  }
}
