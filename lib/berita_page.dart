import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jkn_gamification/membaca_berita_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BeritaPage extends StatefulWidget {

  final BuildContext menuContext;

  BeritaPage({Key? key, required this.menuContext}) : super(key: key);

  @override
  _BeritaPageState createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  String _searchText = "";
  int _activeIndex = 0;

  List<Map<String, dynamic>> latestArticles = [];
  List<Map<String, dynamic>> otherNews = [];

  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();


  final List<String> _buttons = ['Rekomendasi', 'Berita Utama', 'Testimoni', 'Tips Sehat', 'Gaya Hidup'];


  DateTime parseDate(String date) {
    return DateFormat('dd-MM-yyyy').parse(date);
  }

  @override
  void initState() {
    super.initState();

    setupDataListener();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<int> parseStringToIntList(String numberString) {
    return numberString
        .split(',')
        .map((s) => int.parse(s.trim()))
        .toList();
  }

  Future<List<int>> fetchTasksByCategory(String userId, String category) async {
    DatabaseReference taskRef = FirebaseDatabase.instance.ref('tasks');
    DatabaseEvent event = await taskRef.once();
    List<int> taskIds = [];

    if (event.snapshot.exists) {
      // List<dynamic> tasks = event.snapshot.value as List<dynamic>;
      print('test : ${event.snapshot.value}');

      List<dynamic> tasks = event.snapshot.value as List<dynamic>;
      for (int i = 0; i < tasks.length; i++) {
        var data = tasks[i];
        if (data != null) {
          if (data['user_id'] == userId && data['kategori_task'] == category) {
            data['detail'] != null && data['detail']['id_berita'] != null  ? taskIds.add(int.parse(data['detail']['id_berita'].toString()!)) : print("data[$i]['detail']['id_berita'] == null");
          }
        }
      }
    }

    return taskIds;
  }


  void setupDataListener() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('berita');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ref.onValue.listen((DatabaseEvent event) async {

      String userId = prefs.getString('user_id') ?? '';
      List<int> readArticleIds = await fetchTasksByCategory(userId, 'Membaca Berita');

      if (event.snapshot.exists) {
        print('Data tersedia');
        List<Map<String, dynamic>> allArticles = [];
        List<dynamic> dataList = event.snapshot.value as List<dynamic>;
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          if (data != null) {
            Map<dynamic, dynamic> articleData = data as Map<dynamic, dynamic>;
            bool isRead = readArticleIds.contains((i));
            allArticles.add({
              "key": articleData["id_berita"],  // Menyimpan key dari setiap data
              "judul": articleData["judul"],
              "isi": articleData["isi"],
              "tanggal": articleData["tanggal"],
              "dilihat": articleData["dilihat"],
              "dibaca": isRead
            });
          }
        }
        allArticles.sort((a, b) => parseDate(b["tanggal"]).compareTo(parseDate(a["tanggal"])));


        setState(() {
          latestArticles = allArticles.take(6).toList();
          otherNews = allArticles.skip(6).toList();
        });
        print("Data berhasil dimuat: ${allArticles.length} artikel terbaru.");
      } else {
        print('Data tidak tersedia.');
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    bool readOnlySearchBar = true;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              height: 40, // Tinggi dari SearchBar
              child: TextField(
                onTap: (){
                  setState(() {
                    readOnlySearchBar = !readOnlySearchBar;
                  });
                },
                onEditingComplete: (){
                  setState(() {
                    readOnlySearchBar = true;
                  });
                },
                readOnly: readOnlySearchBar,
                onChanged: (value) {
                  setState(() {
                    _searchText = value; // Menyimpan teks pencarian
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari berita, tips sehat, dll...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14), // Ukuran font hintText
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Membuat SearchBar rounded
                    borderSide: BorderSide(color: Colors.blue), // Warna outline biru
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
                style: TextStyle(color: Colors.blue, fontSize: 14), // Warna dan ukuran teks pencarian
              ),
            ),
            PreferredSize(
              preferredSize: Size.fromHeight(88), // Menambah tinggi bottom agar sesuai dengan teks "Artikel" dan tombol
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 18.0), // Padding untuk "Artikel"
                    child: Text(
                      "Artikel",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_buttons.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 16.0 : 4.0, right: 4.0,bottom: 10), // Margin kiri pada item pertama
                          child: SizedBox(
                            height: 36, // Tinggi tombol
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _activeIndex = index; // Mengubah tombol yang aktif
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _activeIndex == index ? Colors.blue : Colors.white, // Filled jika aktif
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                side: BorderSide(color: Colors.blue, width: 2),
                              ),
                              child: Text(
                                _buttons[index],
                                style: TextStyle(
                                  color: _activeIndex == index ? Colors.white : Colors.blue, // Warna teks berubah jika aktif
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 250,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    ...List.generate(latestArticles.length, (index) {
                      Map<String, dynamic> article = latestArticles[index];

                      return artikelCard(
                          article["key"].toString(),
                        article["judul"],
                        article["isi"],
                        article["dilihat"],
                        "assets/berita/${article["key"]}.jpg",
                        article["tanggal"],
                          article["dibaca"]
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 18, right: 18),
              child: Text('Berita Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 16),
            ...List.generate(otherNews.length, (index) {
              Map<String, dynamic> article = otherNews[index];
              return Column(
                children: [
                  beritaCard(
                      article["key"].toString(),
                        article["judul"],
                        article["isi"],
                        article["dilihat"],
                        "assets/berita/${article["key"]}.jpg",
                        article["tanggal"],
                      article["dibaca"]
                    ),
                  index < otherNews.length - 1?
                      Container(
                        child: Divider(
                          thickness: 1,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      ) :
                      Container()

                ],
              );
            }),
          ],
        ),
      );
    }

  Widget artikelCard(String id, String judul, String isi, String dilihat, String imagePath, String tanggal, bool isRead) {
    return InkWell(
      onTap: () {
        Navigator.push(
          widget.menuContext,
          MaterialPageRoute(
            builder: (context) => MembacaBeritaPage(
                idBerita: id,
                judul: judul,
                isi: isi,
                dilihat: dilihat,
                imagePath: imagePath,
                tanggal: tanggal,
                diBaca: isRead,
                onArticleRead: () {
                  setupDataListener();
                },
            ),
          ),
        );
      },
      child: Container(
        width: 420, // Lebar card, sesuaikan sesuai kebutuhan
        child: Card(
          color: Colors.white,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 2,
          margin: EdgeInsets.only(left: 20, bottom: 5),
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Image.asset(
                    imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      judul,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              isRead ? Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 40, // Set the width of the container slightly larger than the icon
                  height: 40, // Set the height of the container slightly larger than the icon
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the background color of the container to white
                    borderRadius: BorderRadius.circular(20), // Use a large enough value to create a rounded effect
                  ),
                  child: Center(
                    child: Image.asset('assets/icons/done.png', width: 30),
                  ),
                ),
              ) :  Container()

            ],
          ),

        ),
      ),
    );
  }

  Widget beritaCard(String id, String judul, String isi, String dilihat, String imagePath, String tanggal, bool isRead) {
    return InkWell(
      onTap: () {
        Navigator.push(
          widget.menuContext,
          MaterialPageRoute(
            builder: (context) => MembacaBeritaPage(
              idBerita: id,
                judul: judul,
                isi: isi,
                dilihat: dilihat,
                imagePath: imagePath,
                tanggal: tanggal,
              diBaca: isRead,
              onArticleRead: () {
              setupDataListener();
            },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        elevation: 0,
        child: Container(
          height: 100,
          width: double.infinity, // Atur lebar untuk mengisi space tersedia
          child: Stack(
            children: <Widget>[

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                left: 115,
                right: 10, // Menambahkan right untuk membatasi lebar Text
                child: Text(
                  judul,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 115, // Menyesuaikan left agar sesuai dengan `title`
                child: Row(
                  children: [
                    isRead ? Image.asset('assets/icons/done.png', width: 20) : Container(),
                    SizedBox(width: 5),
                    Icon(Icons.visibility, size: 20, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(dilihat, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(tanggal, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

