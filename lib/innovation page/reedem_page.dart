import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReedemPage extends StatefulWidget {
  @override
  _ReedemPageState createState() => _ReedemPageState();
}

class _ReedemPageState extends State<ReedemPage> with SingleTickerProviderStateMixin {
  String _userId = "";
  String namaPanggilan = "";
  bool allRank = true;
  late double screenWidth;
  late double screenHeight;
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  double lastScrollOffset = 0.0;

  List<Map<dynamic, dynamic>> leaderboadRanks = [];
  int userRankAll = 0;

  List<Map<dynamic, dynamic>> leaderboadLocalRanks = [];
  int userLocalRank = 0;


  int _showStickyHeader = 1;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);
    getLeaderboardData();
  }

  void _onScroll() {
    double stickyHeaderPosition = (85) * (userRankAll - 1) + 200;
    double currentOffset = _scrollController.offset;

    bool isRankInView = currentOffset < stickyHeaderPosition &&
        (currentOffset + screenHeight - 200) > stickyHeaderPosition + 85;

    setState(() {
      if (!isRankInView &&
          currentOffset <= stickyHeaderPosition - (screenHeight - 200)) {
        _showStickyHeader = 2;
        // print("Sticky Bawah");
      } else if (!isRankInView && currentOffset >= stickyHeaderPosition) {
        _showStickyHeader = 0;
        // print("Sticky Atas");
      } else {
        // Remove sticky if the rank is in the viewport
        _showStickyHeader = 1;
      }
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void switchToAllRank() {
    setState(() {
      allRank = true;
      _tabController.animateTo(0); // Switch to the first tab
    });
  }

  void switchToLocalRank() {
    setState(() {
      allRank = false;
      _tabController.animateTo(1); // Switch to the second tab
    });
  }

  Future<void> getLeaderboardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id') ?? '';
    });
    String userProvince = '';


    final refUser = FirebaseDatabase.instance.ref();
    final snapshot = await refUser.child('users/$_userId/biodata').get();
    if (snapshot.exists) {
      setState(() {
        userProvince = snapshot
            .child("provinsi")
            .value
            .toString();
      });
    } else {
      print('User ID tidak ditemukan');
    }
    final ref = FirebaseDatabase.instance.ref('leaderboard');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      print('Data: $data');
      if (data != null) {
        var entries = data.entries.map((e) =>
        Map<dynamic, dynamic>.from(e.value as Map)).toList();
        entries.sort((a, b) =>
            (b['jumlah_poin'] as int).compareTo(a['jumlah_poin'] as int));

        var localEntries = entries.where((entry) =>
        entry['provinsi'] == userProvince).toList();
        localEntries.sort((a, b) =>
            (b['jumlah_poin'] as int).compareTo(a['jumlah_poin'] as int));

        setState(() {
          leaderboadRanks = entries;
          leaderboadLocalRanks = localEntries;
          userRankAll =
              entries.indexWhere((entry) => entry['user_id'] == _userId) + 1;
          userLocalRank =
              localEntries.indexWhere((entry) => entry['user_id'] == _userId) +
                  1;

          if (userRankAll > 9) _showStickyHeader = 2;
          print('Global rank of User ID $_userId is $userRankAll');
          print(
              'Local rank of User ID $_userId in $userProvince is $userLocalRank');
        });

        if (userRankAll == 0) {
          print('User ID $_userId tidak ditemukan di All Rank leaderboard');
        }
        if (userLocalRank == 0) {
          print('User ID $_userId tidak ditemukan di local rank leaderboard');
        }
      } else {
        print('Tidak ada data');
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
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: AppBar(
          automaticallyImplyLeading: false,
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
                        right: -0,
                        top: -0,
                        child: SvgPicture.asset(
                          'assets/icons/reedem poin.svg', height: 180,)
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, size: 30,
                          color: Color(0xFF096891),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: 75,
                      left: 40,
                      child: Text(
                        'Reedem Poin',
                        style: TextStyle(
                          color: Color(0xFF096891),
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          height: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: 35,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: switchToAllRank,
                            child: Text(
                              'SPECIAL GIFT',
                              style: TextStyle(
                                color: allRank ? Colors.white : Color(
                                    0xFF096891),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: allRank
                                  ? Color(0xFF096891)
                                  : Color(0xFFC5FFE6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Color(0xFF096891),
                                    width: !allRank ? 2 : 0),
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // Space between buttons
                          ElevatedButton(
                            onPressed: switchToLocalRank,
                            child: Text(
                              'DONASI',
                              style: TextStyle(
                                color: !allRank ? Colors.white : Color(
                                    0xFF096891),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !allRank
                                  ? Color(0xFF096891)
                                  : Color(0xFFC5FFE6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Color(0xFF096891),
                                    width: allRank ? 2 : 0),
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
      body:  Container(
        height: screenHeight/2 + 40,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Fitur dalam tahap Pengembangan",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                    height: 4
                ),
              ),
              Image.asset('assets/icons/out-of-stock.png', height: 150,),
            ],
          ),
        ),
      ),


    );
  }
}