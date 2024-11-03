import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MembacaBeritaPage extends StatefulWidget {
  final String idBerita;
  final String judul;
  final String isi;
  final String dilihat;
  final String imagePath;
  final String tanggal;
  final bool diBaca;
  final VoidCallback onArticleRead;


  MembacaBeritaPage({
    required this.idBerita,
    required this.judul,
    required this.isi,
    required this.dilihat,
    required this.imagePath,
    required this.tanggal,
    required this.diBaca,
    required this.onArticleRead


  });

  @override
  _MembacaBeritaPageState createState() => _MembacaBeritaPageState();
}

class _MembacaBeritaPageState extends State<MembacaBeritaPage> {
  ScrollController _scrollController = ScrollController();

  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  double _progress = 0.0;
  Timer? _timer;
  int _timeRemaining = 30;
  bool _isComplete = false;
  bool _popupShown = false;
  String userId =  "";

  String formatTanggal(String tanggal) {
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTime = inputFormat.parse(tanggal);
    DateFormat outputFormat = DateFormat('dd MMM yyyy');
    return outputFormat.format(dateTime).toUpperCase();
  }

  String repeatAndFormatString(String input) {
    String repeated = input * 10;

    List<String> parts = repeated.split('.');
    StringBuffer buffer = StringBuffer();

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
    _scrollController.addListener(_updateProgress);
    _startTimer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _updateProgress() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double newProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);

    if (newProgress > _progress) {
      setState(() {
        _progress = newProgress;
      });
      if (_progress == 1.0) {
        _isComplete = true;
      }
    }
    _checkCompletion();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        }
      });
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    if (_isComplete && _timeRemaining == 0 && !_popupShown) {
      _popupShown = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Selamat!"),
            content: Text("Anda Telah Menyelesaikan Tugas Membaca Berita, Anda mendapatkan 15 poin"),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await createNewTask();
                  widget.onArticleRead();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> createNewTask() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String beritaId = widget.idBerita;
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      print('User ID is not available.');
      return;
    }
    // final DateTime now = DateTime.now();
    // final String newTaskId = DateFormat('yyyyMMddHHmmss', 'id_ID').format(now);
    // final String formattedDate = DateFormat('dd-MM-yyyy hh:mm:ss', 'id_ID').format(now);

    try {
      final DataSnapshot snapshot = (await ref.child('tasks').once()).snapshot;
      if (snapshot.value != null) {
        final List<dynamic> tasks = snapshot.value as List<dynamic>;

        final int newTaskId = tasks.length + 1;

        final String newTaskKey = newTaskId.toString();

        String formattedDate = "";
        await initializeDateFormatting('id_ID', null).then((_) {
          final DateTime now = DateTime.now();
          formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss', 'id_ID').format(now);

          print(formattedDate); // Output akan berbentuk "dd-MM-yyyy HH:mm:ss", contoh: "03-11-2024 17:30:45"
        });
        final Map<String, dynamic> newTask = {
          'id_tasks': newTaskId,
          'kategori_task': 'Membaca Berita',
          'poin_diperoleh': 15,
          'status': 'selesai',
          'user_id': userId,
          'timestamp': formattedDate,
          'detail': {
            'id_berita': beritaId,
          },
        };


        await ref.child('tasks/$newTaskKey').set(newTask);


        final DatabaseEvent userEvent = await ref.child('users/$userId/task_user').once();
        String updatedTaskUser = userEvent.snapshot.value != null ? '${userEvent.snapshot.value}, $newTaskId' : newTaskId.toString();
        await ref.child('users/$userId/task_user').set(updatedTaskUser);

        final DataSnapshot userPointsSnapshot = (await ref.child('users/$userId/stats/jumlah_poin').once()).snapshot;
        final int updatedPoints = (userPointsSnapshot.value as int?) ?? 0 + 15;
        await ref.child('users/$userId/stats/jumlah_poin').set(updatedPoints);

        final DataSnapshot leaderboardSnapshot = (await ref.child('leaderboard/$userId/jumlah_poin').once()).snapshot;
        await ref.child('leaderboard/$userId/jumlah_poin').set(((leaderboardSnapshot.value as int?) ?? 0) + 15);

        print('New task added successfully for user $userId!');
      } else {
        print('Unexpected data format in tasks node. Expected Map.');
      }
    } catch (e) {
      print('An error occurred while adding the new task: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/mjkn_header_colorful_2.png",
                fit: BoxFit.cover,
              ),
            ),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
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
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        child: Row(
                          children: [
                            Image.asset('assets/icons/facebook.png', width: 20, height: 20),
                            Container(padding: EdgeInsets.all(2)),
                            Image.asset('assets/icons/twitter.png', width: 18, height: 18),
                            Container(padding: EdgeInsets.all(3)),
                            Image.asset('assets/icons/whatsapp.png', width: 18, height: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
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
              ],
            ),
          ),
          widget.diBaca ? Container() : Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _isComplete ?
                    Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      )
                      : SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 6.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                  _isComplete && _timeRemaining == 0
                      ? Icon(Icons.check, color: Colors.white, size: 30)
                      : Text(
                    '$_timeRemaining',
                    style: TextStyle(fontSize: 30, color: _isComplete ? Colors.white :  Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
