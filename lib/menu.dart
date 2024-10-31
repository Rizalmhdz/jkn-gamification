import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jkn_gamification/berita_page.dart';
import 'package:jkn_gamification/home_page.dart';
import 'package:jkn_gamification/login_page.dart';
import 'package:jkn_gamification/service/navbar_visibility_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late PersistentTabController _controller;


  late bool isNavBarVisible;


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
      HomePage(),
      BeritaPage(),
      blankPage(pageName: "Kartu"),
      blankPage(pageName: "FAQ"),
      blankPage(pageName: "Profil"),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: ("Home"),
          activeColorPrimary: Colors.blue,   // Set active color
          inactiveColorPrimary: Colors.grey, // Set inactive color
      ),
      PersistentBottomNavBarItem(

          icon: Icon(Icons.article),
          activeColorPrimary: Colors.blue,   // Set active color
          inactiveColorPrimary: Colors.grey,
          title: ("Berita")
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.credit_card_rounded, color: Colors.white),
          activeColorPrimary: isNavBarVisible ? Colors.blue : Colors.transparent, // Set active color
          inactiveColorPrimary: Colors.grey,
          title: ("Kartu"),
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.forum),
          activeColorPrimary: Colors.blue, // Set active color
          inactiveColorPrimary: Colors.grey,
          title: ("FAQ")
      ),
      PersistentBottomNavBarItem(

          icon: Icon(Icons.account_circle_rounded),
          activeColorPrimary: Colors.blue,   // Set active color
          inactiveColorPrimary: Colors.grey,
          title: ("Profile"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    isNavBarVisible = Provider.of<NavBarVisibilityProvider>(context).isVisible;
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.once,
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: Colors.white,
      isVisible: isNavBarVisible,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style15, // Choose the nav bar style with this property
    );
  }
}

class blankPage extends StatelessWidget {
  final String pageName;
  const blankPage({Key? key, required this.pageName}) : super(key: key);

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