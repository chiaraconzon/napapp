import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';
import 'package:napapp/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // mappa che orgainzza gli eventi usando DateTime come chiave raggruppate in event che accadono in un dato giorno
  Map<DateTime, List<MyEvent>> globalEvents = {};
  // indice per selezionare la pagina
  int _pageIndex = 0;

  // funzione di supporto per le icone
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Pranzo":
        return Icons.restaurant;
      case "Studio":
        return Icons.menu_book;
      case "Allenamento":
        return Icons.fitness_center;
      case "Lezione":
        return Icons.school;
      case "Altro":
        return Icons.more_horiz;
      default:
        return Icons.event_available;
    }
  }

  @override
  Widget build(BuildContext context) {
    // nome utente che passiamo da login
    String name = "";
    // lista con le page della nostra app
    final List<Widget> pagesList = [
      _homeWidget(),
      CalendarPage(
        // connette il widget alla sorgente di dati globali garantendo l'aggiornamento dopo ogni modifica
        eventsMap: globalEvents,
        // callback che agisce come un ponte, sincronizza
        onEventsUpdated: (newMap) => setState(() => globalEvents = newMap),
      ),
      StatsPage(),
    ];
    // estrazione del nome dagli argomenti della rotta, se non ci sono parametri allora scrive "utente"
    name = ModalRoute.of(context)!.settings.arguments as String? ?? "Utente";

    return Scaffold(
      // fa partire lo scaffold da in cima alla pagina
      extendBodyBehindAppBar: true,
      appBar: _pageIndex == 1
          ? null
          : AppBar(
              backgroundColor: Colors.transparent, // Rende l'AppBar trasparente
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Text("Ciao $name"))),
            ListTile(title: Text("THEME"), onTap: () {}),
            ListTile(title: Text("LANGUAGE"), onTap: () {}),
            ListTile(title: Text("OPTIONS"), onTap: () {}),
            ListTile(title: Text("CREDITS"), onTap: () {}),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              // sostituisce la schermata con quella di login
              // la freccia => è un "abbreviatore sintattico" (poche righe di codice)
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
            ),
          ],
        ),
      ),
      // prende la pagina dalla lista in base all'indice
      body: pagesList[_pageIndex],
      // timer
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Scegli la durata del riposino:"),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // OPZIONI
                            _napButton(
                              context,
                              "Rigenerativa 60 min",
                              Icons.hotel,
                              60,
                            ),

                            SizedBox(height: 10),

                            _napButton(
                              context,
                              "Recupero 30 min",
                              Icons.bed,
                              30,
                            ),

                            SizedBox(height: 10),

                            _napButton(
                              context,
                              "Power Nap 15 min",
                              Icons.nightlight_round,
                              15,
                            ),

                            SizedBox(height: 10),

                            _napButton(
                              context,
                              "Personalizzata",
                              Icons.edit,
                              null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            )
          : null,
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

  // widget per le sveglie
  Widget _napButton(
    BuildContext context,
    String title,
    IconData icon,
    int? minutes,
  ) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        onPressed: () {
          Navigator.pop(context);

          if (minutes != null) {
            print("Sveglia da $minutes minuti");
            NotificationService.setAlarm(minutes);
          } else {
            print("Apri personalizzata");
          }
        },

        icon: Icon(icon),

        label: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // widget per "costruire" l'homepage
  Widget _homeWidget() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // 1. Creo una lista di eventi del giorno stesso
    // se oggi non ci sono eventi restituisco una lista vuota
    List<MyEvent> eventiOggi = List.from(globalEvents[today] ?? []);

    // 2. Ordiniamo la lista in base all'orario di inizio
    eventiOggi.sort((a, b) {
      final int minutiA = a.startTime.hour * 60 + a.startTime.minute;
      final int minutiB = b.startTime.hour * 60 + b.startTime.minute;
      return minutiA.compareTo(minutiB);
    });

    return Column(
      children: [
        // titoletto carino
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "IMPEGNI DI OGGI",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        //
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "OGGI L'ORARIO PER IL RIPOSINO E' DALLE ... ALLE ...",
            style: TextStyle(fontSize: 14),
          ),
        ),
        //
        Expanded(
          child: eventiOggi.isEmpty
              // se oggi non ci sono impegni allora mostra questo
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Nessun impegno per oggi",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              // se ci sono impegni li mostra
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  // per tutti gli eventi di oggi...
                  itemCount: eventiOggi.length,
                  // ...allora creo nel contest una card con listtile
                  itemBuilder: (context, index) {
                    final ev = eventiOggi[index];

                    // creo le card per gli eventi
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: ev.color.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),

                      // creo una lista per tutti gli eventi
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ev.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(ev.category),
                            color: ev.color,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          ev.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${ev.startTime.format(context)} - ${ev.endTime.format(context)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // piccola etichetta per la categoria a destra
                        trailing: Text(
                          ev.category,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
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
