import 'package:flutter/material.dart';
import 'package:napapp/screens/calendar_page.dart';
import 'package:napapp/screens/stats_page.dart';
import 'login_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // C: controller per lo scorrimento della lista orario
  final ScrollController _controllerTime = ScrollController();
  final double tileHeight = 100;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    // C: timer che sposta la lista ogni 5 secondi
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controllerTime.hasClients) {
        final nextOffset = _controllerTime.offset + tileHeight;
        _controllerTime.animateTo(
          nextOffset,
          duration: const Duration(seconds: 1),
          curve: Curves.linearToEaseOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // C: pulizia del controller per evitare sprechi di memoria
    _controllerTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // C: definizione delle pagine dell'app
    final List<Widget> _pages = [
      CalendarPage(),
      _homeBuildContent(),
      StatsPage(),
    ];

    return Scaffold(
      // C: AppBar personalizzata (senza righette, con omino a destra)
      appBar: AppBar(
        title: const Text(
          "NAP APP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),

      // C: Menu laterale (Drawer)
      drawer: Drawer(
        child: Column(
          children: [
            // C: Testata del menu
            Container(
              width: double.infinity,
              height: 120,
              color: Colors.amber,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "Ciao GINO,",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            // C: Opzioni del menu
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Homepage"),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context); // C: chiude il drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Statistiche"),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            const Spacer(), // C: spinge il logout in basso
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // C: Visualizzazione della pagina selezionata
      body: _pages[_currentIndex],

      // C: Barra di navigazione inferiore
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }

  // C: Widget che crea il rettangolo con la lista infinita
  Widget _homeBuildContent() {
    return Center(
      child: Container(
        height: 400,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListView.builder(
                controller: _controllerTime,
                itemBuilder: (c, i) => ListTile(
                  title: Center(child: Text("Elemento $i")),
                  minTileHeight: 100,
                ),
              ),
            ),
            // C: riga nera fissa al centro
            IgnorePointer(child: Container(height: 2, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
