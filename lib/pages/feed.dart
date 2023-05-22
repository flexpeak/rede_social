import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:rede_social/pages/adicionar.dart';
import 'package:rede_social/pages/configuracoes.dart';
import 'package:rede_social/pages/home.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> with TickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          controller: TabController(
            length: 3,
            vsync: this,
            initialIndex: _currentIndex
          ),
          children: const [
            Home(),
            Adicionar(),
            Configuracoes(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedLabelStyle: const TextStyle(
            fontFamily: 'ReemKufiFun',
            fontSize: 10
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'ReemKufiFun',
            fontSize: 10
          ),
          selectedItemColor: Colors.black87,
          showUnselectedLabels: false,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(TablerIcons.home_2, color: Colors.black54), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(TablerIcons.photo, color: Colors.black54), label: 'ADICIONAR'),
            BottomNavigationBarItem(icon: Icon(TablerIcons.settings, color: Colors.black54), label: 'CONFIGURAÇÕES'),
          ],
        ),
      ),
    );
  }
}
