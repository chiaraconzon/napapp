import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyEvent {
  final String id, groupId, title;
  final int duration;
  final TimeOfDay startTime;
  final bool isRecurring;
  final Color color;

  MyEvent({
    required this.id,
    required this.groupId,
    required this.title,
    required this.duration,
    required this.startTime,
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
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
          eventLoader: (day) =>
              widget.eventsMap[DateTime(day.year, day.month, day.day)] ?? [],
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
            label: const Text("Aggiungi Evento"),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    final list =
        widget.eventsMap[DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        )] ??
        [];
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) => ListTile(
        leading: Icon(Icons.circle, color: list[i].color, size: 14),
        title: Text(list[i].title),
        subtitle: Text(
          "${list[i].startTime.format(context)} (${list[i].duration} min)",
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteDialog(list[i]),
        ),
      ),
    );
  }

  void _showDeleteDialog(MyEvent ev) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text("Elimina solo questo"),
              onTap: () {
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
                Navigator.pop(context);
              },
            ),
            if (ev.isRecurring)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Elimina TUTTE le ripetizioni"),
                onTap: () {
                  setState(
                    () => widget.eventsMap.values.forEach(
                      (l) => l.removeWhere((e) => e.groupId == ev.groupId),
                    ),
                  );
                  widget.onEventsUpdated(widget.eventsMap);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet() {
    final tCtrl = TextEditingController();
    final dCtrl = TextEditingController(text: "30");
    TimeOfDay time = TimeOfDay.now();
    Color selCol = _colors[0];
    String rep = 'Singolo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tCtrl,
                decoration: const InputDecoration(
                  labelText: "Titolo Evento",
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // RIGA COMPATTA: DURATA + ORARIO
              Row(
                children: [
                  Expanded(
                    flex: 2, // La durata occupa meno spazio
                    child: TextField(
                      controller: dCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Durata",
                        suffixText: "min",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3, // L'orario occupa più spazio
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime: time,
                        );
                        if (t != null) setSt(() => time = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              time.format(ctx),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // SELETTORE RIPETIZIONE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: rep,
                    isExpanded: true,
                    items: ['Singolo', 'Giornaliera', 'Settimanale', 'Mensile']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text("Ripetizione: $s"),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSt(() => rep = v!),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SELETTORE COLORE
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _colors
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setSt(() => selCol = c),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 30,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: selCol == c
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  int dur = int.tryParse(dCtrl.text) ?? 30;
                  _save(tCtrl.text, dur, time, rep, selCol);
                  Navigator.pop(context);
                },
                child: const Text(
                  "SALVA EVENTO",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _save(String t, int dur, TimeOfDay tm, String r, Color c) {
    final gid = DateTime.now().toString();
    int count = r == 'Singolo'
        ? 1
        : (r == 'Giornaliera' ? 365 : (r == 'Settimanale' ? 52 : 12));
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
            duration: dur, // Usiamo il valore passato
            startTime: tm,
            color: c,
            isRecurring: r != 'Singolo',
          ),
        );
      }
    });
    widget.onEventsUpdated(widget.eventsMap);
  }
}
