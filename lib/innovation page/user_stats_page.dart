import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStatsPage extends StatefulWidget {
  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> with SingleTickerProviderStateMixin{
  String _userId = "";
  String namaUser = "";
  bool allRank = true;
  late double screenWidth;
  late double screenHeight;
  late TabController _tabController;
  double lastScrollOffset = 0.0;

  int poin = 99999;
  int rank = 33;
  int rankLokal = 4;


  int stickyRank = 8;
  int _showStickyHeader = 1;

  bool editMode = false;


  @override
  void initState() {
    super.initState();
    getData();
    _tabController = TabController(length: 2, vsync: this); // Inisialisasi TabController
  }

  @override
  void dispose() {
    _tabController.dispose(); // Membersihkan TabController ketika widget dihapus
    super.dispose();
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
        namaUser = dataList["nama"];
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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220),
        child: AppBar(
          title: Text(
              editMode ? 'Ubah Avatar' : 'User Stats',
              style: TextStyle(
                color: Color(0xFF096891),
                fontWeight: FontWeight.bold,
                fontSize: 30,
                height: 1,
              ),
            ),
          centerTitle: true,
          leading: IconButton(
            padding: EdgeInsets.only(left: 20),
            icon: Icon(Icons.arrow_back,size: 30, color: Color(0xFF096891)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: Container(
              color: Color(0xFFC5FFE6),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                        top: !editMode ? 100 : 75,
                        right: 20 - 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: !editMode ? 13 : 20, bottom: 5),
                                child: Text(
                                  editMode ? "Nama Avatar" : namaUser ,
                                  style: TextStyle(
                                      color: Color(0xFF096891),
                                      fontWeight: FontWeight.bold,
                                      fontSize: !editMode ? 25 : 14,
                                    height: !editMode ? 1 : 1.5
                                  ),
                                ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              width: screenWidth - ( 30 + 130 + 10),
                              height: 45,
                              decoration: !editMode ? BoxDecoration() : BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child:
                              !editMode ? Text(
                                      'ID : $_userId',
                                      style: TextStyle(color: Color(0xFF096891), fontWeight: FontWeight.normal)
                                  )
                                  : TextField(
                                decoration: InputDecoration(
                                  hintText: "Masukkan nama avatar anda",
                                  hintStyle: TextStyle(color: Color(0xFF096891), fontSize: 12, fontWeight: FontWeight.normal),
                                  contentPadding: EdgeInsets.all(20), // Adjust padding
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Color(0xFF096891), width: 2), // Blue outline
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Color(0xFF096891), width: 2), // Darker outline when focused
                                  ),
                                ),
                              ),

                            ),
                          ],
                        )

                    ),
                    Positioned(
                        left: 30,
                        top : 80,
                        child: Stack(
                          children: [
                            Image.asset('assets/avatars/13.png', height: 125),
                            !editMode ? Container() : Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 200,
                                          child: Center(
                                            child: Text("Edit Something Here", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(Icons.edit, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )

                    ),
                    Positioned(
                      top: 150,
                      right: 30,
                      child: Row(
                        children: [
                          !editMode ? ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  editMode = true;
                                });
                              },
                              child: Text('Ubah Avatar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF096891),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            )
                          : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                editMode = false;
                              });
                            },
                            child: Text(
                              'Simpan',
                              style: TextStyle(
                                  color: Color(0xFF096891),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mengatur jarak antar item
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/poin.png', height: 12,),
                          SizedBox(width: 4), // Menggunakan SizedBox untuk jarak antar elemen
                          Text(
                            'Poin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$poin',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF096891),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    child: VerticalDivider(
                      thickness: 2,
                      color: Colors.black54,
                      width: 30,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/all rank.png', height: 12,),
                          SizedBox(width: 4),
                          Text(
                            'Rank',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF096891),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    child: VerticalDivider(
                      thickness: 2,
                      color: Colors.black54,
                      width: 30,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/local rank.png', height: 12,),
                          SizedBox(width: 4),
                          Text(
                            'Lokal Rank',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '#$rankLokal',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF096891),
                        ),
                      ),
                    ],
                  ),
                ],
              )

            ),
          Container(
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: "Tab 1"),
                  Tab(text: "Tab 2"),
                ],
              ),
          ),
          Expanded(child:
            Container(
              width: screenWidth,
              color: Color(0xFFF0F0F0),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: DefaultTabController(
                length: 2, // Total 2 tab
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ListView untuk Tab 1
                    ListView.builder(
                      itemCount: 20, // Jumlah item yang ingin ditampilkan
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.star),
                          title: Text("Item ${index + 1} in Tab 1"),
                        );
                      },
                    ),
                    // ListView untuk Tab 2
                    ListView.builder(
                      itemCount: 15, // Jumlah item yang ingin ditampilkan
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.check_circle),
                          title: Text("Item ${index + 1} in Tab 2"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CustomScrollView(
          //   controller: _scrollController,
          //   slivers: <Widget>[
          //     SliverList(
          //       delegate: SliverChildBuilderDelegate(
          //             (BuildContext context, int index) {
          //           return itemListLeaderboard(
          //             index + 1,
          //             index >= 27 ? '1' : '${index + 1}',
          //             'User $index',
          //             '${index}12345231212576',
          //             'Kalimantan Selatan',
          //             (15 - index) * 213,
          //           );
          //         },
          //         childCount: 50, // Display 50 items
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }



  Widget itemListTask(int no, String namaTask, String tanggalTask, bool isDone) {
    Color colorItem = Color(0xFFF5F5F5);
    return  Container(
        width: screenWidth - 40,
        height: 80,
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: rank == 1 ? 10 : 0),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorItem,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '#$no',
                        style: TextStyle(
                            fontSize: '#$no'.length > 4 ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF096891)
                        ),
                      ),
                    ]
                ),
                width: 50
            ),
            Container(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$namaTask',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF096891),
                      height: 1
                  ),
                ),
                Text(
                  '$tanggalTask',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF096891)
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.yellow,
                shape: isDone ? BoxShape.rectangle : BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.error_outline,
                color: Colors.white, // Icon color
                size: 12, // Icon size
              ),
            )
          ],
        )
    );
  }
}
