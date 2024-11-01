import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jkn_gamification/innovation%20page/leaderboard_page.dart';
import 'package:jkn_gamification/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOnPage extends StatefulWidget {
  @override
  _GameOnPageState createState() => _GameOnPageState();
}

class _GameOnPageState extends State<GameOnPage> {


  String _userId = "";
  String namaPanggilan = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id')!;
    });

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/$_userId/biodata').get();
    if (snapshot.exists) {
      setState(() {
        Map<dynamic, dynamic> dataList = snapshot.value as Map<dynamic, dynamic>;
        namaPanggilan = getNickname(dataList["nama"]);
      });
    } else {
      print('User ID tidak ditemukan');
    }
  }

  String getNickname(String fullName) {
    List<String> names = fullName.split(' ');
    if (names.length == 1) {
      return names[0];
    } else {
      return names[1];
    }
  }




  List<Map<String, dynamic>> tasks = [
    {'title': "Minum Obat", 'description': "Jangan lupa minum obat hipertensi", 'time': "10:00 AM"},
    {'title': "Kunjungan Faskes", 'description': "Mengunjungi Faskes Kinibalu untuk cek mata", 'time': "11:00 AM"},
    {'title': "Kunjungan Faskes", 'description': "Mengunjungi Faskes Kinibalu untuk cek mata", 'time': "11:00 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: Stack(
              children: [
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,size: 40, color: Colors.black,),
                    onPressed: () {
                          Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 35,
                  left: 70,
                  child: Text(
                    'GAME \nON',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      height: 1,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30, top: 150),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Message
                      Container(
                          width: screenWidth,
                          height: 100,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFFC5FFE6),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello $namaPanggilan..',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Selesaikan misiimu hari ini',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],

                                    ),
                                  )

                                ],
                              ),

                            ],
                          )
                      ),
                      SizedBox(height: 20),
                      // Menu Section
                      Text(
                        'Menu',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            menuCard('user stats.png', 'User Stats', blankPage(pageName: "User Stats")),
                            menuCard('leaderboard.png', 'Leaderboard', LeaderboardPage()),
                            menuCard('reedem poin.png', 'Reedem Poin', blankPage(pageName: "Reedem Poin")),
                          ],
                        ),
                      ),


                      SizedBox(height: 20),
                      // Tasks Section
                      Text(
                        'Tugas Hari Ini',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tasks.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            // Memastikan data yang diteruskan ke TaskCard benar
                            return TaskCard( tasks[index]["title"],tasks[index]["description"], tasks[index]["time"]
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    right: 30,
                    top : 110,
                    child: Image.asset('assets/skrining_new_icon.png', height: 180,)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget menuCard(String imagePath, String title, Widget namePage) {
    return Expanded(
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => namePage),
          );
        }, // Tambahkan parameter onTap untuk menangani aksi saat kartu diklik
        child: Card(
          color: Color(0xFFC5FFE6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/$imagePath", height: 80, width: 80, fit: BoxFit.cover,),
              Container(height: 10,),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF096891)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget TaskCard(String title, String description, String time) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey,),
                Container(width: 5,),
                Text(time, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
