import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onTabTapped(0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.house,
                      color: _currentIndex == 0 ? Colors.orange.shade700 : const Color.fromARGB(221, 230, 230, 230),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onTabTapped(1),
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.settings,
                      color: _currentIndex == 1 ? Colors.orange.shade700 : const Color.fromARGB(221, 230, 230, 230),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
