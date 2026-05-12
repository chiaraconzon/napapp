import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// creo una classe evento che poi utilizo per l'aggiunta di eventi
class MyEvent {
  String id, groupId, title, category;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;
  final bool isRecurring;

  MyEvent({
    required this.id,
    required this.groupId,
    required this.title,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.isRecurring = false,
  });
}

class CalendarPage extends StatefulWidget {
  // definisco una mappa di eventi
  final Map<DateTime, List<MyEvent>> eventsMap;
  // definisco un callback, ovvero una funzione che si eseguirà in un secondo momento
  // comunica al widget di costruzione della pagina che i dati sono cambiati
  final Function(Map<DateTime, List<MyEvent>>) onEventsUpdated;

  const CalendarPage({
    super.key,
    required this.eventsMap,
    required this.onEventsUpdated,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
  ];

  final List<String> _categories = [
    "Pranzo",
    "Studio",
    "Allenamento",
    "Lezione",
    "Altro",
  ];

  // decide che all'inizio il giorno selezionato è il giorno corrente
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // funzione che va a riordinare cronologicamente gli eventi di quel giorno
  List<MyEvent> _getSortedEvents(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final events = widget.eventsMap[key] ?? [];
    events.sort((a, b) {
      final aTime = a.startTime.hour * 60 + a.startTime.minute;
      final bTime = b.startTime.hour * 60 + b.startTime.minute;
      return aTime.compareTo(bTime);
    });
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<MyEvent>(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mese',
            CalendarFormat.week: 'Settimana',
          },
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (sel, foc) => setState(() {
            _selectedDay = sel;
            _focusedDay = foc;
          }),
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          eventLoader: _getSortedEvents,
          calendarBuilders: CalendarBuilders(
            // qua stiamo andando a creare dei "marker", i pallini che segnano gli eventi
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events
                    .take(4) // limite di pallini
                    .map(
                      // 'e' abbrevia 'events'
                      // sostanzialmente andiamo a chiamare un evento alla volta e a lavorarci sopra
                      // (lo trasformo in un cerchio)
                      (e) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),

        // questa è tutta la parte sotto al calendar
        const Divider(),
        Expanded(child: _buildEventList()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddSheet(),
            label: const Text("Aggiungi Attività"),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  // widget per la costruzione di liste di eventi
  Widget _buildEventList() {
    final list = _getSortedEvents(_selectedDay!);
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final ev = list[i];
        return ListTile(
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: ev.color, shape: BoxShape.circle),
          ),
          title: Text(ev.title),
          subtitle: Text(
            "${ev.category} • ${ev.startTime.format(context)} - ${ev.endTime.format(context)}",
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                onPressed: () => _showAddSheet(eventToEdit: ev),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _showDeleteDialog(ev),
              ),
            ],
          ),
        );
      },
    );
  }

  // funzione del menu adding events
  void _showAddSheet({MyEvent? eventToEdit}) {
    final bool isEditing =
        eventToEdit !=
        null; // verifica se stai modificando un evento o creandone uno nuovo
    String selectedCat = isEditing
        ? eventToEdit.category
        : _categories[0]; // imposta la categoria dell'evento o la prima disponibile
    final tCtrl = TextEditingController(
      text: isEditing ? eventToEdit.title : "",
    ); //controller con il titolo dell'evento (o vuoto)
    // imposta la fine dell'evento un'ora dopo a meno che non sia in stato di modifica
    TimeOfDay startTime = isEditing ? eventToEdit.startTime : TimeOfDay.now();
    TimeOfDay endTime = isEditing
        ? eventToEdit.endTime
        : TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute);
    // assegna il colore salvato o il primo della lista
    Color selCol = isEditing ? eventToEdit.color : _colors[0];
    // inizializza la variabile impostandola come "non ricorrente"
    String repetition = 'Singolo';

    // apertura del menù di gestione degli eventi
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // l'altezza è adattabile
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // con StatefulBuilder si può aggiornare il pannello con i nuovi dati senza aggiornare l'intera pagina
      builder: (ctx) => StatefulBuilder(
        // uso Stack per posizionare la X in alto a destra
        builder: (ctx, setSt) => Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      isEditing ? "Modifica Dettagli" : "Nuova Attività",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Categoria",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _categories.map((cat) {
                      final isSelected = selectedCat == cat;
                      // i choicechip sono i pulsanti per scegliere la categoria
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: isEditing
                            ? null
                            : (selected) {
                                if (selected) setSt(() => selectedCat = cat);
                              },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Titolo (opzionale)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tCtrl,
                    decoration: InputDecoration(
                      hintText: "es. Nuoto, Arte, ...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // il widget viene forzato ad occupare tutto lo spazio a disposizione
                      Expanded(
                        // widget che rende l'area sottostante cliccabile
                        child: InkWell(
                          onTap: () async {
                            // è una funzione asincrona perché deve attendere la scelta dell'utente
                            // showTimePicker apre la finestra di dialogo predefinita del sistema
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: startTime,
                            );
                            // se l'utente non "dice nulla" allora la variabile locale viene aggiornata e si ridisegna il widget
                            if (t != null) setSt(() => startTime = t);
                          },
                          // disegna graficamente il quadratino con l'ora
                          child: _timeBox("Inizio", startTime, ctx),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // stessa roba con ma con il tempo di fine
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: endTime,
                            );
                            if (t != null) setSt(() => endTime = t);
                          },
                          child: _timeBox("Fine", endTime, ctx),
                        ),
                      ),
                    ],
                  ),

                  // verifico di non essere in editing, se sono in editing non mostro il menu per scegliere la ripetibilita dell'evento
                  if (!isEditing) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Ripetizione",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    DropdownButton<String>(
                      value: repetition,
                      isExpanded: true,
                      items:
                          ['Singolo', 'Giornaliera', 'Settimanale', 'Mensile']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (v) => setSt(() => repetition = v!),
                    ),
                  ],

                  // scelta dei colori
                  const SizedBox(height: 20),
                  const Text(
                    "Colore",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _colors
                          .map(
                            (c) => GestureDetector(
                              // aggiorna il colore selzionato
                              onTap: () => setSt(() => selCol = c),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                width: 30,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  // aggiunge un bordino se è il colore selezionato
                                  border: selCol == c
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      // double infinity dice al bottone di occupare tutta la larghezza disponibile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final startMin = startTime.hour * 60 + startTime.minute;
                      final endMin = endTime.hour * 60 + endTime.minute;
                      // controllo che l'orario di fine sia maggiore di quello di inizio
                      if (endMin <= startMin) {
                        // questa funzione si trova sotto
                        _showErrorDialog(
                          ctx,
                          "L'orario di fine deve essere dopo l'orario di inizio. Per favore, seleziona un orario corretto.",
                        );
                        return; // non chiude il foglio, l'utente può correggere
                      }

                      // verifico che ci sia un titolo, se non c'è un titolo allora si inserisce il nome della categoria selezionata
                      String finalTitle = tCtrl.text.trim().isEmpty
                          ? selectedCat
                          : tCtrl.text;

                      // verifico se sto modificando un evento
                      if (isEditing) {
                        if (eventToEdit.isRecurring) {
                          // chiedo se vuole modificare tutti gli eventi o solo quello che stiamo modificando
                          _showUpdateOptionDialog(
                            eventToEdit,
                            finalTitle,
                            startTime,
                            endTime,
                            selCol,
                          );
                        } else {
                          // se l'evento non è ricorrente aggiorna solo quello ovviamente
                          _applySingleUpdate(
                            eventToEdit,
                            finalTitle,
                            startTime,
                            endTime,
                            selCol,
                          );
                          Navigator.pop(context);
                        }
                      } else {
                        // se non sono in editing semplicemente salvo il tutto
                        _save(
                          finalTitle,
                          selectedCat,
                          startTime,
                          endTime,
                          selCol,
                          repetition,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(isEditing ? "AGGIORNA" : "SALVA ATTIVITÀ"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // pulsante di uscita
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // funzione che apre la finestra per la non-validità dell'orario
  void _showErrorDialog(BuildContext ctx, String message) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text("Orario non valido"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("HO CAPITO"),
          ),
        ],
      ),
    );
  }

  // funzione di aggiornamento evento
  void _showUpdateOptionDialog(
    MyEvent ev,
    String title,
    TimeOfDay start,
    TimeOfDay end,
    Color col,
  ) {
    // finestra per la scelta di modifica per gli eventi ricorrenti
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifica evento ricorrente"),
        content: const Text(
          "Vuoi applicare le modifiche solo a questo evento o a tutte le ripetizioni?",
        ),
        actions: [
          TextButton(
            // evento singolo
            onPressed: () {
              _applySingleUpdate(ev, title, start, end, col);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("SOLO QUESTO"),
          ),
          TextButton(
            onPressed: () {
              // tutti gli eventi modificati
              _applyGroupUpdate(ev.groupId, title, start, end, col);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("TUTTI"),
          ),
        ],
      ),
    );
  }

  // funzione aggiornamento per modifica di evento singolo
  void _applySingleUpdate(
    MyEvent ev,
    String title,
    TimeOfDay start,
    TimeOfDay end,
    Color col,
  ) {
    setState(() {
      ev.title = title;
      ev.startTime = start;
      ev.endTime = end;
      ev.color = col;
    });
    widget.onEventsUpdated(widget.eventsMap);
  }

  // funzione aggiornamento per modifica di gruppo di eventi
  void _applyGroupUpdate(
    String gId,
    String title,
    TimeOfDay start,
    TimeOfDay end,
    Color col,
  ) {
    setState(() {
      widget.eventsMap.forEach((date, list) {
        for (var ev in list) {
          if (ev.groupId == gId) {
            ev.title = title;
            ev.startTime = start;
            ev.endTime = end;
            ev.color = col;
          }
        }
      });
    });
    widget.onEventsUpdated(widget.eventsMap);
  }

  // box contenitori per l'orario cliccabile
  Widget _timeBox(String label, TimeOfDay time, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            time.format(ctx),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // funzione di salvataggio eventi
  void _save(
    String t,
    String cat,
    TimeOfDay start,
    TimeOfDay end,
    Color c,
    String r,
  ) {
    final gid = DateTime.now().toString();
    int count = 1;
    if (r == 'Giornaliera') count = 30;
    if (r == 'Settimanale') count = 12;
    if (r == 'Mensile') count = 6;

    // scelta ripetizione
    setState(() {
      for (int i = 0; i < count; i++) {
        DateTime d = _selectedDay!;
        if (r == 'Giornaliera') d = d.add(Duration(days: i));
        if (r == 'Settimanale') d = d.add(Duration(days: 7 * i));
        if (r == 'Mensile') d = DateTime(d.year, d.month + i, d.day);

        final key = DateTime(d.year, d.month, d.day);
        widget.eventsMap.putIfAbsent(key, () => []);
        widget.eventsMap[key]!.add(
          MyEvent(
            id: "$gid-$i",
            groupId: gid,
            title: t,
            category: cat,
            startTime: start,
            endTime: end,
            color: c,
            isRecurring: r != 'Singolo',
          ),
        );
      }
    });
    widget.onEventsUpdated(widget.eventsMap);
  }

  // finestra per eliminazione dell'evento
  void _showDeleteDialog(MyEvent ev) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Elimina attività"),
        content: Text(
          ev.isRecurring
              ? "Questa è un'attività ricorrente."
              : "Vuoi eliminare questa attività?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ANNULLA"),
          ),
          TextButton(
            onPressed: () {
              setState(
                () => widget
                    .eventsMap[DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    )]
                    ?.removeWhere((e) => e.id == ev.id),
              );
              widget.onEventsUpdated(widget.eventsMap);
              Navigator.pop(ctx);
            },
            child: const Text("SOLO QUESTA"),
          ),
          if (ev.isRecurring)
            TextButton(
              onPressed: () {
                setState(() {
                  widget.eventsMap.values.forEach(
                    (list) => list.removeWhere((e) => e.groupId == ev.groupId),
                  );
                });
                widget.onEventsUpdated(widget.eventsMap);
                Navigator.pop(ctx);
              },
              // appare solo nel caso l'evento sia ripetuto
              child: const Text("TUTTE", style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
