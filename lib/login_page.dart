import 'package:blur/blur.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jkn_gamification/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> list = <String>['Nomor Induk Kependudukan (NIK)', 'Nomor Kartu JKN'];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedValue = list.first;
  bool _isPasswordVisible = false;

  final noIdController = TextEditingController();
  final passwordController = TextEditingController();

  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<void> login(String no_id, String password) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/$no_id/user_data').get();
    if (snapshot.exists && snapshot.child("password").value == password) {
      // Menyimpan status login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Jika password benar, navigasikan ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Jika data tidak ada atau password salah, tampilkan toast
      Fluttertoast.showToast(
          msg: "Nomor ID atau password salah",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print('Nomor ID atau password salah.');
    }
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    noIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background with blur effect
            Image.asset(
              "assets/mjkn_splash_colorful.png",
              height: screenHeight * 1.0,
              width: screenWidth,
              fit: BoxFit.cover,
            ).blurred(
              colorOpacity: 0.2,
              blur: 20,
            ),
            Column(
              children: <Widget>[
                SizedBox(height: 60),
                // Logo
                Image.asset('assets/new_mjkn_2022_white.png', height: 120),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Label dan Dropdown Button
                      Text(
                        'Pilih Jenis Identitas',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        padding: EdgeInsets.only(left: 60, top: 15, bottom: 15, right: 15),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedValue,
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                            isExpanded: true,
                            onChanged: (newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                            items: list.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                    value,
                                    style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Label dan NIK atau JKN Input Field
                      Text(
                        selectedValue,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 50, // Tinggi yang lebih kecil
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: noIdController,
                          decoration: InputDecoration(
                            hintText:  selectedValue == list.first ? "16 Digit Nomor Induk Kependudukan" : "13 Digit Nomor Kartu JKN",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person, color: Colors.blue),
                            contentPadding: EdgeInsets.symmetric(vertical: 15), // Padding untuk rata tengah vertikal
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Label dan Password Input Field
                      Text(
                        'Password Mobile JKN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 50, // Tinggi yang lebih kecil
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          obscureText: !_isPasswordVisible,
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Password Mobile JKN',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock, color: Colors.blue),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15), // Padding untuk rata tengah vertikal
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Login Button
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async {
                          login(noIdController.text, passwordController.text);
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Forgot Password Text
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
