import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:async';

// Definizione della classe statica
class HomePage extends StatefulWidget {
  // C: costruttore della classe
  const HomePage({Key? key});
  // C: si va sovrascrivere createState()
  // associando alla struttura statica la parte dinamica
  @override
  State<HomePage> createState() => _HomePageState();
}

// Definizione dello stato e della logica dinamica
// _ davanti indica che è PRIVATA (visibile solo all'interno del file)
class _HomePageState extends State<HomePage> {
  // controller: scorrimento lista orario
  final ScrollController _controllerTime = ScrollController();

  @override
  // C: dentro a initState ci vanno inizializzazioni e controller
  void initState() {
    super.initState();

    // timer: sposta la lista ogni 5 sec
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // C: verifichiamo che la lista sia stata creata
      if (_controllerTime.hasClients) {
        _controllerTime.animateTo(
          _controllerTime.offset + 72,
          duration: const Duration(seconds: 1),
          curve: Curves.linearToEaseOut,
        );
      }
    });
  }

  @override
  // C: rimozione dalla schermata del widget
  void dispose() {
    _controllerTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;
    return Scaffold(
      // appBar
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Colors.amber,
      ),

      // menu' laterale
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              tileColor: Colors.amber,
              minTileHeight: 100,
              title: Text(
                "Ciao CHIARA,",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            ListTile(title: Text("Statistiche"), onTap: () {}),
            ListTile(title: Text("Homepage"), onTap: () {}),
            SizedBox(height: 300),
            ListTile(title: Text("Opzioni"), onTap: () {}),
            ListTile(
              title: Text("Logout"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),

      // Rettangolo scorrevole
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: 500,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.grey[200],
                    child: ListView.builder(
                      controller: _controllerTime,
                      itemBuilder: (c, i) =>
                          ListTile(title: Center(child: Text("Elemento $i"))),
                    ),
                  ),
                  // riga nera fissa al centro
                  IgnorePointer(
                    child: Container(height: 2, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // navigationbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.amber,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
