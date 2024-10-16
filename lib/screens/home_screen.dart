import 'package:flutter/material.dart';
import 'card_view.dart';
import 'timeline_view.dart';
// import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    CardView(),
    TimelineView(),
    // SettingsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return '卡片视图';
      case 1:
        return '时间轴视图';
      // case 2:
      //   return '设置';
      default:
        return 'Something went wrong...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedIndex)),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '卡片视图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '时间轴视图',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置')
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
