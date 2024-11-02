import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin{
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
      if (!isRankInView && currentOffset <= stickyHeaderPosition - (screenHeight - 200)) {
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
        userProvince = snapshot.child("provinsi").value.toString();
      });
    } else {
      print('User ID tidak ditemukan');
    }
    final ref = FirebaseDatabase.instance.ref('leaderboard');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      print('Data: $data');
      if (data != null) {
        var entries = data.entries.map((e) => Map<dynamic, dynamic>.from(e.value as Map)).toList();
        entries.sort((a, b) => (b['jumlah_poin'] as int).compareTo(a['jumlah_poin'] as int));

        var localEntries = entries.where((entry) => entry['provinsi'] == userProvince).toList();
        localEntries.sort((a, b) => (b['jumlah_poin'] as int).compareTo(a['jumlah_poin'] as int));

        setState(() {
          leaderboadRanks = entries;
          leaderboadLocalRanks = localEntries;
          userRankAll = entries.indexWhere((entry) => entry['user_id'] == _userId) + 1;
          userLocalRank = localEntries.indexWhere((entry) => entry['user_id'] == _userId) + 1;

          if (userRankAll > 9) _showStickyHeader = 2;
          print('Global rank of User ID $_userId is $userRankAll');
          print('Local rank of User ID $_userId in $userProvince is $userLocalRank');
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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

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
                        right: -60,
                        top : -20,
                        child: SvgPicture.asset('assets/icons/crown.svg', height: 220,)
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,size: 30, color: Color(0xFF096891),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: 75,
                      left: 40,
                      child: Text(
                        'Leaderboard',
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
                              'KESELURUHAN',
                              style: TextStyle(
                                color: allRank ? Colors.white : Color(0xFF096891),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: allRank ? Color(0xFF096891) : Color(0xFFC5FFE6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Color(0xFF096891), width: !allRank ? 2 : 0),
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // Space between buttons
                          ElevatedButton(
                            onPressed: switchToLocalRank,
                            child: Text(
                              'LOKAL RANK',
                              style: TextStyle(
                                color: !allRank ? Colors.white : Color(0xFF096891),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !allRank ? Color(0xFF096891) : Color(0xFFC5FFE6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Color(0xFF096891), width: allRank ? 2 : 0),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  if (_showStickyHeader == 0)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        child: itemListLeaderboard(
                          userRankAll,
                          leaderboadRanks[userRankAll - 1]["avatar"].toString(),
                          leaderboadRanks[userRankAll - 1]["avatarname"],
                          leaderboadRanks[userRankAll - 1]["user_id"],
                          leaderboadRanks[userRankAll - 1]["provinsi"],
                          leaderboadRanks[userRankAll - 1]["jumlah_poin"],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return itemListLeaderboard(
                          index+1,
                          leaderboadRanks[index]["avatar"].toString(),
                          leaderboadRanks[index]["avatarname"],
                          leaderboadRanks[index]["user_id"],
                          leaderboadRanks[index]["provinsi"],
                          leaderboadRanks[index]["jumlah_poin"],
                        );
                      },
                      childCount: leaderboadRanks.length, // Display 50 items
                    ),
                  ),
                ],
              ),
              if (_showStickyHeader == 2)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    color: Color(0xFFC9C9C9),
                    child: itemListLeaderboard(
                      userRankAll,
                      leaderboadRanks[userRankAll - 1]["avatar"].toString(),
                      leaderboadRanks[userRankAll - 1]["avatarname"],
                      leaderboadRanks[userRankAll - 1]["user_id"],
                      leaderboadRanks[userRankAll - 1]["provinsi"],
                      leaderboadRanks[userRankAll - 1]["jumlah_poin"],
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  if (_showStickyHeader == 0)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        child: itemListLeaderboard(
                          userLocalRank,
                          leaderboadLocalRanks[userLocalRank - 1]["avatar"].toString(),
                          leaderboadLocalRanks[userLocalRank - 1]["avatarname"],
                          leaderboadLocalRanks[userLocalRank - 1]["user_id"],
                          leaderboadLocalRanks[userLocalRank - 1]["provinsi"],
                          leaderboadLocalRanks[userLocalRank - 1]["jumlah_poin"],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return itemListLeaderboard(
                          index+1,
                          leaderboadLocalRanks[index]["avatar"].toString(),
                          leaderboadLocalRanks[index]["avatarname"],
                          leaderboadLocalRanks[index]["user_id"],
                          leaderboadLocalRanks[index]["provinsi"],
                          leaderboadLocalRanks[index]["jumlah_poin"],
                        );
                      },
                      childCount: leaderboadLocalRanks.length, // Display 50 items
                    ),
                  ),
                ],
              ),
              if (_showStickyHeader == 2)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    color: Color(0xFFC9C9C9),
                    child: itemListLeaderboard(
                      userLocalRank,
                      leaderboadLocalRanks[userLocalRank - 1]["avatar"].toString(),
                      leaderboadLocalRanks[userLocalRank - 1]["avatarname"],
                      leaderboadLocalRanks[userLocalRank - 1]["user_id"],
                      leaderboadLocalRanks[userLocalRank - 1]["provinsi"],
                      leaderboadLocalRanks[userLocalRank - 1]["jumlah_poin"],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),


    );
  }



  Widget itemListLeaderboard(int rank, String avatarImg, String avatarName, String user_id, String provinsi, int poin) {
     Color colorItem = Color(0xFFF5F5F5);
     if(rank == 1){
       colorItem = Color(0xFFFFE07B);
     } else if(rank == 2){
       colorItem = Color(0xFFE4E7E7);
     } else if(rank == 3){
       colorItem = Color(0xFFED9D5D);
     }
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
                        '#$rank',
                        style: TextStyle(
                            fontSize: '#$rank'.length > 4 ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF096891)
                        ),
                      ),
                    ]
                ),
                width: 50
            ),

            Image.asset('assets/avatars/$avatarImg.png'),
            Container(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$avatarName',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF096891),
                    height: 1
                  ),
                ),
                Text(
                  'ID : $user_id',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF096891)
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.black54,size: 12,),
                    Container(width: 6,),
                    Text(
                      provinsi,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(width: '$poin'.length > 4 ? 10 : 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$poin',
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF096891),
                    height: 1
                  ),
                ),
                Text(
                  'Perolehan Poin',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF096891),
                    height: 1
                  ),
                )
              ],
            )
          ],
        )
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      color: Color(0xFFC9C9C9),
      child: child,
    );
  }

  @override
  double get maxExtent => 90;
  @override
  double get minExtent => 90;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
