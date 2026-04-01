import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NapApp",
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: Scaffold(
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
        // Menu' laterale
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
        body: ListView(
          padding: EdgeInsets.all(100),
          children: [
            ListTile(
              title: Text("data"),
              onTap: () {},
              tileColor: Color.fromRGBO(220, 217, 217, 1),
              minTileHeight: 400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          /*currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },*/
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
      ),
    );
  }
}
