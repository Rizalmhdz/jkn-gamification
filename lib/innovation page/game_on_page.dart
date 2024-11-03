import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jkn_gamification/innovation%20page/leaderboard_page.dart';
import 'package:jkn_gamification/innovation%20page/user_stats_page.dart';
import 'package:jkn_gamification/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOnPage extends StatefulWidget {
  @override
  _GameOnPageState createState() => _GameOnPageState();
}

class _GameOnPageState extends State<GameOnPage> {


  String _userId = "";
  String namaPanggilan = "";

  late double screenWidth;
  late double screenHeight;

  final List<Map<dynamic, dynamic>> todayTask = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  bool isTodayTask(String tanggalTask){
    DateTime today = DateTime.now();
    String formattedToday = DateFormat('dd-MM-yyyy').format(today);

    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(tanggalTask);

    if (today.isAtSameMomentAs(parsedDate)) {
      return true;
    // } else if (today.isBefore(parsedDate)) {
    //   return false;
    // } else if (today.isAfter(parsedDate)) {
    //   return false;
    } else {
      return false;
    }
  }

  List<int> parseStringToIntList(String numberString) {
    return numberString
        .split(',')
        .map((s) => int.parse(s.trim()))
        .toList();
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

    final DatabaseReference taskUserRef = ref.child('users/$_userId/task_user');
    taskUserRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;

      if (data != null) {
        setState(() {
          List<int> taskIds = parseStringToIntList(data.toString());
          print("taskUser : $taskIds");

          if (taskIds.isNotEmpty) {
            for (int id in taskIds) {
              final taskRef = ref.child('tasks/$id');
              taskRef.get().then((snapshot) {
                if (snapshot.exists) {
                  final taskData = snapshot.value as Map<dynamic, dynamic>;
                  final String taskDate = taskData['timestamp'];

                  if (isTodayTask(taskDate)) {
                    setState(() {
                      todayTask.add(taskData);
                    });
                    print("Task ID $id ditambahkan.");
                    print(taskData);
                    print("todayTask : $todayTask");
                  } else {
                    print("Task ID $id bukan hari ini.");
                  }
                } else {
                  print("Task dengan ID $id tidak ada.");
                }
              }).catchError((error) {
                print("Error ketika mengambil data tasks: $error");
              });
            }
          } else {
            print("No tasks found for user.");
          }
        });
      } else {
        print('Task user "$_userId" tidak ditemukan');
      }
    });


  }

  String getNickname(String fullName) {
    List<String> names = fullName.split(' ');
    if (names.length == 1) {
      return names[0];
    } else {
      return names[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
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
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF096891)),
                                        ),
                                        Text(
                                          'Selesaikan misiimu hari ini',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF096891)),
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
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            menuCard('user stats.png', 'User Stats', UserStatsPage()),
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
                        child: todayTask.length > 0 ?ListView.builder(
                          itemCount: todayTask.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            print("todayTask : ${todayTask.length}");
                            return TaskCard(
                                todayTask[index]["kategori_task"],
                                todayTask[index]["timestamp"]
                            );
                          },
                        ) : Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                    "Tugas Hari ini Tidak Ditemukan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45,
                                      height: 4
                                    ),
                                ),
                                Image.asset('assets/icons/no-data.png', height: 150,),
                              ],
                            ),
                          ),
                        )
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


  Widget TaskCard(String title, String time, {String namaObat = "", String alamatFaskes = ""}) {
    String imagePath = '';
    String deskripsi = '';
    String pukul =  DateFormat('HH:mm').format(DateFormat('dd-MM-yyyy HH:mm:ss').parse(time));




    switch (title) {
      case 'Meminum Obat':
        imagePath = 'assets/icons/meminum obat.png';
        deskripsi = 'Jangan lupa minum obat "$namaObat".';
        break;
      case 'Kunjungan Faskes':
        imagePath = 'assets/icons/kunjungan faskes.png';
        deskripsi = 'Jangan lupa anda ada jadwal berkunjung ke Faskes "$alamatFaskes" hari ini.';
        break;
      case 'Skrining Kesehatan':
        imagePath = 'assets/icons/skrining.png';
        deskripsi = 'Lakukan Skrining Kesehatan Hari ini';
        break;
      case 'Membaca Berita':
        imagePath = 'assets/icons/membaca berita.png';
        deskripsi = 'Jangan Lupa Membaca Berita Kesehatan Hari ini';
        break;
      default:
        imagePath = 'assets/icons/poin.png';
        deskripsi = 'Informasi tidak tersedia.';
    }

    return Card(
      color: Color(0xFFC5FFE6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        Row(
          children: [
            Container(
              width: (screenWidth - 20 - 20) * ( 5/ 8 ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF096891))),
                SizedBox(height: 2),
                Text(deskripsi, style: TextStyle(color: Color(0xFF096891))),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey,),
                    Container(width: 5,),
                    Text(pukul, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            ),


            Image.asset(imagePath, height: 80,)
          ],
        ),

      ),
    );
  }


}
