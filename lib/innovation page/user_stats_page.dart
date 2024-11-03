import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  int selectedAvatar = 0;
  int savedAvatar = 0;

  int poin = 0;
  int rank = 0;
  int rankLokal = 0;

  String savedAvatarname = "";
  String selectedAvatarname = "";


  final avatarNameController = TextEditingController();


  int stickyRank = 8;
  String provinsiUser = '';

  bool editMode = false;

  List<Map<dynamic, dynamic>> onGoingTasks = [];
  List<Map<dynamic, dynamic>> riwayatTasks = [];


  @override
  void initState() {
    super.initState();
    getData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    avatarNameController.dispose();
    super.dispose();
  }
  DateTime parseCustomDateTime(String dateString) {
    try {
      List<String> dateTimeParts = dateString.split(' ');
      List<String> dateParts = dateTimeParts[0].split('-');
      List<String> timeParts = dateTimeParts[1].split(':');
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );
    } catch (e) {
      throw FormatException("Invalid date format", dateString);
    }
  }

  bool isTodayTask(String timestamp) {
    final taskDate = parseCustomDateTime(timestamp);
    return DateTime.now().difference(taskDate).inDays == 0 && DateTime.now().day == taskDate.day;
  }

  List<int> parseStringToIntList(String numberString) {
    return numberString
        .split(',')
        .map((s) => int.parse(s.trim()))
        .toList();
  }

  Future<void> updateAvatarData() async {
    final ref = FirebaseDatabase.instance.ref();
    final updateData = {
      'stats/avatar': selectedAvatar.toString(),
      'stats/avatarname': selectedAvatarname,
    };

    // Update data in Firebase
    ref.child('users/$_userId').update(updateData).then((_) {
      // On successful update, sync the local state
      setState(() {
        savedAvatar = selectedAvatar;
        savedAvatarname = selectedAvatarname;
        editMode = false;
      });
      print("Avatar data updated successfully");
    }).catchError((error) {
      print("Failed to update avatar data: $error");
    });
  }


  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id') ?? '';
    });

    final ref = FirebaseDatabase.instance.ref();
    ref.child('users/$_userId').onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        try{
          setState(() {
            namaUser = snapshot.child("biodata/nama").value.toString();
            provinsiUser = snapshot.child("biodata/provinsi").value.toString();
            savedAvatar = int.parse(snapshot.child("stats/avatar").value.toString());
            selectedAvatar = savedAvatar;

            savedAvatarname = snapshot.child("stats/avatarname").value.toString();
            selectedAvatarname = savedAvatarname;
          });

        } catch(e){
          print("Error ketika mengakses User : $e");
        }

      } else {
        print('User ID tidak ditemukan');
      }

      final data = event.snapshot.child('task_user').value;
      if (data != null) {
        List<int> taskIds = parseStringToIntList(data.toString());
        taskIds.forEach((id) {
          ref.child('tasks/$id').get().then((snapshot) {
            if (snapshot.exists) {
              Map<dynamic, dynamic> taskData = Map<dynamic, dynamic>.from(snapshot.value as Map);
              DateTime taskTimestamp = parseCustomDateTime(taskData['timestamp']);
              bool taskIsOngoing = taskTimestamp.isAfter(DateTime.now()) && taskData['status'] == 'belum selesai';

              setState(() {
                if (taskIsOngoing) {
                  onGoingTasks.add(taskData);
                } else {
                  riwayatTasks.add(taskData);
                }
              });
            } else {
              print("Task dengan ID $id tidak ada.");
            }
          }).catchError((error) {
            print("Error ketika mengambil data tasks: $error");
          });
        });
      } else {
        print('Task user "$_userId" tidak ditemukan');
      }
    }, onError: (error) {
      print('Error listening to user data: $error');
    });

    final leaderboardRef = FirebaseDatabase.instance.ref('leaderboard');
    leaderboardRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Map<dynamic, dynamic>> entries = data.entries
            .map((e) => Map<dynamic, dynamic>.from(e.value as Map))
            .toList();
        entries.sort((a, b) => (b['jumlah_poin'] as int).compareTo(a['jumlah_poin'] as int));

        List<Map<dynamic, dynamic>> localEntries = entries
            .where((entry) => entry['provinsi'] == provinsiUser)
            .toList();
        localEntries.sort((a, b) => (b['jumlah_poin'] as int).compareTo(a['jumlah_poin'] as int));

        setState(() {
          rank = entries.indexWhere((entry) => entry['user_id'] == _userId) + 1;
          rankLokal = localEntries.indexWhere((entry) => entry['user_id'] == _userId) + 1;
          poin = entries[rank - 1]['jumlah_poin'];
        });
      } else {
        print('Tidak ada data leaderboard');
      }
    }, onError: (error) {
      print('Error listening to leaderboard changes: $error');
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
                                  editMode ? "Nama Avatar" : savedAvatarname ,
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
                                style: TextStyle(
                                    color: Color(0xFF096891),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                ),
                                controller: avatarNameController,
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
                        child:Stack(
                          children: [
                            !editMode ? Image.asset('assets/avatars/$savedAvatar.png', height: 125)
                               : Image.asset('assets/avatars/$selectedAvatar.png', height: 125),
                            !editMode? Container()
                                : Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    print("Edit avatar tapped"); // Debug statement

                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 40),
                                            child: Container(
                                              height: screenHeight - 200,
                                              width: screenWidth,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 30),
                                                    child: Text(
                                                      'Pilih Avatar',
                                                      style: TextStyle(
                                                        color: Color(0xFF096891),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded( // Make sure GridView is scrollable within Column
                                                    child: GridView.builder(
                                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 4,
                                                        crossAxisSpacing: 15,
                                                        mainAxisSpacing: 15,
                                                        childAspectRatio: 1,
                                                      ),
                                                      itemCount: 28,
                                                      itemBuilder: (context, index) {

                                                        bool isSelected = selectedAvatar == index;
                                                        return index > 0 ?
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedAvatar = index;
                                                            });
                                                            Navigator.pop(context);
                                                            print("selectedAvatr : $selectedAvatar");
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: isSelected ? Colors.blue : Colors.transparent,
                                                              shape: BoxShape.circle,
                                                              border: selectedAvatar == index ? Border.all(color: Colors.blue, width: 4) : null,
                                                            ),
                                                            child: AnimatedScale(
                                                              scale: isSelected ? 0.9 : 1.0,
                                                              duration: Duration(milliseconds: 300),
                                                              child: Image.asset('assets/avatars/$index.png', fit: BoxFit.cover),
                                                            ),
                                                          ),
                                                        )
                                                            : GestureDetector(
                                                          onTap: (){

                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.black26,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: Center(
                                                              child: Icon(Icons.add, color: Colors.white, size: 40,),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                  avatarNameController.text = "$savedAvatarname";
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
                          : Row(
                            children: [
                              ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  editMode = false;
                                  selectedAvatar = savedAvatar;
                                  selectedAvatarname = savedAvatarname;
                                });
                              },
                              child: Text(
                                'Batalkan',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                              Container( width: 10,),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedAvatarname = avatarNameController.text;
                                    updateAvatarData();
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
                              ]
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
                // color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  // Override primary color and accent color used by the tab bar
                  primaryColor: Color(0xFF096891),
                  colorScheme: ColorScheme.light().copyWith(
                    primary: Color(0xFF096891),
                  ),
                  tabBarTheme: TabBarTheme(
                    labelColor: Color(0xFF096891), // Active tab label color
                    unselectedLabelColor: Colors.grey, // Unselected tab label color
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF096891), // Color of the bottom border (indicator)
                          width: 3.0, // Thickness of the indicator
                        ),
                      ),
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: "Sedang Berlangsung"),
                    Tab(text: "Riwayat Task"),
                  ],
                ),
              ),

          ),
          Expanded(child:
            Container(
              width: screenWidth,
              // color: Color(0xFFF0F0F0),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: DefaultTabController(
                length: 2, // Total 2 tab
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ListView untuk Tab 1
                    onGoingTasks.length > 0 ?
                    ListView.builder(
                      itemCount: onGoingTasks.length, // Jumlah item yang ingin ditampilkan
                      itemBuilder: (context, index) {
                        return itemListTask(
                            index,
                            int.parse(onGoingTasks[index]['id_tasks'].toString()),
                            onGoingTasks[index]['kategori_task'],
                            onGoingTasks[index]['timestamp'],
                            onGoingTasks[index]['status'].toString().toLowerCase() == "selesai" ? true : false
                        );
                      },
                    ) : Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(height: 20,),
                            Text(
                              "Tidak Ada Tugas Yang Berlangsung",
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
                    ),

                    riwayatTasks.length > 0 ?
                    // ListView untuk Tab 2
                    ListView.builder(
                      itemCount: riwayatTasks.length, // Jumlah item yang ingin ditampilkan
                      itemBuilder: (context, index) {
                        return itemListTask(
                            index,
                            int.parse(riwayatTasks[index]['id_tasks'].toString()),
                            riwayatTasks[index]['kategori_task'],
                            riwayatTasks[index]['timestamp'],
                            riwayatTasks[index]['status'].toString().toLowerCase() == "selesai" ? true : false
                        );
                      },
                    ) : Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(height: 40,),
                            Text(
                              "Tidak Ada Riwayat Tugas",
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget itemListTask(int index, int no, String namaTask, String tanggalTask, bool isDone) {
    Color colorItem = Color(0xFFF5F5F5);
    return  Container(
        width: screenWidth - 40,
        height: 80,
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: index == 0 ? 10 : 0),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorItem,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            Positioned(
              top: '#$no'.length > 4 ? 14 : 10,
                left: 12,
                child:  Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ID TASK',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF096891),
                                height: 1
                            ),
                          ),

                          Text(
                            '#$no',
                            style: TextStyle(
                                fontSize: '#$no'.length > 4 ? 16 : 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF096891)
                            ),
                          ),
                        ]
                    ),
                ),
            ),

            Positioned(
              left: 80,
              top: 12,
              child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$namaTask',
                      style: TextStyle(
                          fontSize: 16,
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
            ),

            Positioned(
                top: isDone ? 16 : 12,
                right: isDone ? 20 : 16,
                child: Container(
                    padding: isDone ? EdgeInsets.all(2) : EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green : Colors.orange,
                      shape: isDone ? BoxShape.rectangle : BoxShape.circle,
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.error_outline,
                      color: isDone ? Colors.white : Colors.white, // Icon color
                      size: 20, // Icon size
                    ),
                  )
            )

          ],
        )
    );
  }
}
