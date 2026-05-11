import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final Map<DateTime, List<MyEvent>> eventsMap;
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

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
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events
                    .take(4)
                    .map(
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
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
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

  void _showAddSheet({MyEvent? eventToEdit}) {
    final bool isEditing = eventToEdit != null;
    String selectedCat = isEditing ? eventToEdit.category : _categories[0];
    final tCtrl = TextEditingController(
      text: isEditing ? eventToEdit.title : "",
    );
    TimeOfDay startTime = isEditing ? eventToEdit.startTime : TimeOfDay.now();
    TimeOfDay endTime = isEditing
        ? eventToEdit.endTime
        : TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute);
    Color selCol = isEditing ? eventToEdit.color : _colors[0];
    String repetition = 'Singolo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Stack(
          // Uso Stack per posizionare la X in alto a destra
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
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: startTime,
                            );
                            if (t != null) setSt(() => startTime = t);
                          },
                          child: _timeBox("Inizio", startTime, ctx),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                              onTap: () => setSt(() => selCol = c),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                width: 30,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // --- NUOVA GESTIONE ERRORE ---
                      final startMin = startTime.hour * 60 + startTime.minute;
                      final endMin = endTime.hour * 60 + endTime.minute;

                      if (endMin <= startMin) {
                        _showErrorDialog(
                          ctx,
                          "L'orario di fine deve essere dopo l'orario di inizio. Per favore, seleziona un orario corretto.",
                        );
                        return; // Non chiude il foglio, l'utente può correggere
                      }

                      String finalTitle = tCtrl.text.trim().isEmpty
                          ? selectedCat
                          : tCtrl.text;

                      if (isEditing) {
                        if (eventToEdit.isRecurring) {
                          _showUpdateOptionDialog(
                            eventToEdit,
                            finalTitle,
                            startTime,
                            endTime,
                            selCol,
                          );
                        } else {
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
            // --- PULSANTE X DI USCITA ---
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

  // --- FUNZIONE DI ERRORE DEDICATA ---
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

  // LOGICA MODIFICHE E RIPETIZIONI (Invariata)
  void _showUpdateOptionDialog(
    MyEvent ev,
    String title,
    TimeOfDay start,
    TimeOfDay end,
    Color col,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifica evento ricorrente"),
        content: const Text(
          "Vuoi applicare le modifiche solo a questo evento o a tutte le ripetizioni?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              _applySingleUpdate(ev, title, start, end, col);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("SOLO QUESTO"),
          ),
          TextButton(
            onPressed: () {
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
          ), //questo VALE SIA PER RIPETIZIONI CHE SENZA, VEDERE SE FARE DUE COSE DIVERSE O LASCIARE COSì
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
              child: const Text("TUTTE", style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
