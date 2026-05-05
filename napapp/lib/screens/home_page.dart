import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
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
  List<Map<String, dynamic>> listaImpegni = [];
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _orarioController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  IconData _selectedIcon = Icons.event;

  final double tileHeight = 100;
  int _pageIndex = 1;

  @override
  Widget build(BuildContext context) {
    // C: definizione delle pagine dell'app
    final List<Widget> pagesList = [
      const CalendarPage(),
      _homeWidget(),
      const StatsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person, size: 30, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),

      // Menu laterale (Drawer)
      drawer: Drawer(
        child: Column(
          children: [
            Container(),
            const Spacer(),
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
          ],
        ),
      ),
      body: pagesList[_pageIndex],
      floatingActionButton: _pageIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Nuova Attività"),
                      content: Column(
                        mainAxisSize: MainAxisSize
                            .min, // La finestra si adatta al contenuto
                        children: [
                          TextField(
                            controller: _titoloController,
                            decoration: InputDecoration(
                              labelText: "Titolo (es. Coccinelle)",
                            ),
                          ),
                          TextField(
                            controller: _orarioController,
                            decoration: InputDecoration(
                              labelText: "Orario (es. 21:00)",
                            ),
                          ),
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: "Descrizione",
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Annulla"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              Map<String, dynamic> newImpegno = {
                                'titolo': _titoloController.text,
                                'orario': _orarioController.text,
                                'note': _noteController.text,
                                'icona': _selectedIcon,
                              };
                              listaImpegni.add(newImpegno);
                              _titoloController.clear();
                              _orarioController.clear();
                              _noteController.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Aggiungi"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) => setState(() => _pageIndex = index),
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

  // C: Page builder
  Widget _homeWidget() {
    return Column(
      children: [
        Text(
          "Ciao oggi il pisolino è da questo a questo",
          style: TextStyle(fontSize: 15),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: listaImpegni.length, // Quante card dobbiamo disegnare?
            itemBuilder: (context, index) {
              // Prendiamo i dati della card numero "index"
              final impegno = listaImpegni[index];
              // Usiamo il tuo widget _buildCard per disegnarla
              return _buildCard(
                Colors.white,
                impegno['titolo'] ?? "no title",
                impegno['orario'] ?? "--.--",
                impegno['note'] ?? "",
                impegno['icona'] ?? Icons.notifications,
              );
            },
          ),
        ),
      ],
    );
  }

  // C: Widget per generare le card bianche e pulite
  Widget _buildCard(
    Color color,
    String title,
    String time,
    String notes,
    IconData icon,
  ) {
    return Card(
      color: color,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 35, color: Colors.amber[700]),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    notes,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
