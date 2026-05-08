import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sorgente dati unica condivisa tra Home e Calendario
  Map<DateTime, List<MyEvent>> globalEvents = {};
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    String name = "";
    final List<Widget> pagesList = [
      // Passiamo la mappa e la funzione di aggiornamento al Calendario
      _homeWidget(),
      CalendarPage(
        eventsMap: globalEvents,
        onEventsUpdated: (newMap) => setState(() => globalEvents = newMap),
      ),
      StatsPage(),
    ];
    name = ModalRoute.of(context)!.settings.arguments as String? ?? "Utente";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Rende l'AppBar trasparente
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Text("Ciao $name"))),
            ListTile(title: Text("THEME"), onTap: () {}),
            ListTile(title: Text("LANGUAGE"), onTap: () {}),
            ListTile(title: Text("NOTIFICATIONS"), onTap: () {}),
            ListTile(title: Text("OPTIONS"), onTap: () {}),
            ListTile(title: Text("CREDITS"), onTap: () {}),

            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
            ),
          ],
        ),
      ),
      body: pagesList[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) => setState(() => _pageIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }

  Widget _homeWidget() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // 1. Recuperiamo la lista degli eventi
    List<MyEvent> eventiOggi = List.from(globalEvents[today] ?? []);

    // 2. Ordiniamo la lista in base all'orario di inizio
    eventiOggi.sort((a, b) {
      final int minutiA = a.startTime.hour * 60 + a.startTime.minute;
      final int minutiB = b.startTime.hour * 60 + b.startTime.minute;
      return minutiA.compareTo(minutiB);
    });

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Impegni di oggi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: eventiOggi.isEmpty
              ? const Center(child: Text("Nessun impegno per oggi"))
              : ListView.builder(
                  itemCount: eventiOggi.length,
                  itemBuilder: (context, index) {
                    final ev = eventiOggi[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: ev.color.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.circle, color: ev.color),
                        title: Text(
                          ev.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Mostriamo l'orario ordinato
                        subtitle: Text(
                          "${ev.startTime.format(context)} — Durata: ${ev.duration} min",
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
