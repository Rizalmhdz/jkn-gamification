import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jkn_gamification/berita_page.dart';
import 'package:jkn_gamification/home_page.dart';
import 'package:jkn_gamification/login_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late PersistentTabController _controller;


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }


  List<Widget> _buildScreens() {
    return [
      HomePage(menuContext: context,),
      BeritaPage(menuContext: context,),
      blankPage(pageName: "Kartu"),
      blankPage(pageName: "FAQ"),
      profilePage(pageName: "Profil", menuContext: context,),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: ("Home"),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(

          icon: Icon(Icons.article),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          title: ("Berita")
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.credit_card_rounded, color: Colors.white),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          title: ("Kartu"),
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.forum),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          title: ("FAQ")
      ),
      PersistentBottomNavBarItem(

          icon: Icon(Icons.account_circle_rounded),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          title: ("Profile"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.once,
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: Colors.white,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style15,
    );
  }
}

class blankPage extends StatelessWidget {
  final String pageName;
  const blankPage({Key? key, required this.pageName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(pageName), // Menggunakan parameter di AppBar
      ),
      body: Center(
        child: pageName == "Profil" ?
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFC5FFE6)),
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                width: 100,
                child:  Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black,),
                    Container( width: 4,),
                    Text("Logout", style:  TextStyle(color: Colors.black),)
                  ],
                )
              )
            )
        : Text("Welcome to $pageName")
      ),
    );
  }
}

class profilePage extends StatelessWidget {
  final String pageName;
  final BuildContext menuContext;
  const profilePage({Key? key, required this.pageName, required this.menuContext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName), // Menggunakan parameter di AppBar
      ),
      body: Center(
          child: pageName == "Profil" ?
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFC5FFE6)), // Warna merah muda
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  menuContext,
                  MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Container(
                  height: 40,
                  width: 100,
                  child:  Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black,),
                      Container( width: 4,),
                      Text("Logout", style:  TextStyle(color: Colors.black),)
                    ],
                  )
              )
          )
              : Text("Welcome to $pageName")
      ),
    );
  }
}