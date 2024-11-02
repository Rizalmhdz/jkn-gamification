import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String _userId = "";
  String namaPanggilan = "";
  bool allRank = true;
  late double screenWidth;
  late double screenHeight;
  ScrollController _scrollController = ScrollController();
  double lastScrollOffset = 0.0;


  int stickyRank = 8;
  int _showStickyHeader = 1;


  @override
  void initState() {
    super.initState();
    getData();
    setState(() {
      if (stickyRank > 9) _showStickyHeader = 2;
      // print("showStickyHeader = $_showStickyHeader");
      // print('(screenHeight - 200) / 85) = ${(screenHeight - 200 - 85) / 85}');
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double stickyHeaderPosition = (85) * (stickyRank - 1) + 200;
    double currentOffset = _scrollController.offset;

    bool isRankInView = currentOffset < stickyHeaderPosition &&
        (currentOffset + screenHeight - 200) > stickyHeaderPosition + 85;

    setState(() {
      if (!isRankInView && currentOffset <= stickyHeaderPosition - (screenHeight - 200)) {
        _showStickyHeader = 2;
        print("Sticky Bawah");
      } else if (!isRankInView && currentOffset >= stickyHeaderPosition) {
        _showStickyHeader = 0;
        print("Sticky Atas");
      } else {
        // Remove sticky if the rank is in the viewport
        _showStickyHeader = 1;
      }
    });
  }



  @override
  void dispose() {
    _scrollController.dispose();
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
                          Container(
                            margin: EdgeInsets.only(right: 10), // Add spacing between the buttons
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  allRank = true;
                                });
                              },
                              child: Text('KESELURUHAN',
                                style: TextStyle(
                                    color: !allRank? Color(0xFF096891) : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !allRank? Color(0xFFC5FFE6) : Color(0xFF096891),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: Color(0xFF096891), width: !allRank ? 2 : 0),// Rounded corners
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                allRank = false;
                              });
                            },
                            child: Text(
                              'LOKAL RANK',
                              style: TextStyle(
                                  color: allRank? Color(0xFF096891) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: allRank? Color(0xFFC5FFE6) : Color(0xFF096891),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                                side: BorderSide(color: Color(0xFF096891), width: allRank ? 2 : 0), // Dark cyan outline
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
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              if (_showStickyHeader == 0)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: itemListLeaderboard(
                      stickyRank,
                      stickyRank >= 27 ? '1' : '${stickyRank + 1}',
                      'User $stickyRank',
                      '${stickyRank}12345231212576',
                      'Kalimantan Selatan',
                      (15 - stickyRank) * 213,
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return itemListLeaderboard(
                      index + 1,
                      index >= 27 ? '1' : '${index + 1}',
                      'User $index',
                      '${index}12345231212576',
                      'Kalimantan Selatan',
                      (15 - index) * 213,
                    );
                  },
                  childCount: 50, // Display 50 items
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
                  stickyRank,
                  stickyRank >= 27 ? '1' : '${stickyRank + 1}',
                  'User $stickyRank',
                  '${stickyRank}12345231212576',
                  'Kalimantan Selatan',
                  (15 - stickyRank) * 213,
                ),
              ),
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
