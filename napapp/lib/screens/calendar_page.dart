import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'app_strings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// =============================================================================
// MODELLO DATI
// =============================================================================

/// Rappresenta un singolo evento nel calendario.
/// Gli eventi di una serie ricorrente condividono lo stesso [groupId];
/// ogni occorrenza ha però un [id] univoco (formato "timestamp-i").
class MyEvent {
  String id; // ID univoco della singola occorrenza (es. "2024-...-0")
  String groupId; // ID condiviso da tutte le ripetizioni dello stesso evento
  String title;
  String category; // Lezione | Pranzo | Studio | Allenamento | Altro
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;
  final bool isRecurring; // true se fa parte di una serie ricorrente

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

  /// Serializza l'evento in una mappa JSON-compatibile, usata da
  /// [EventsStorageService] per salvare gli eventi in SharedPreferences.
  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'title': title,
    'category': category,
    'startHour': startTime.hour,
    'startMinute': startTime.minute,
    'endHour': endTime.hour,
    'endMinute': endTime.minute,
    'color': color.value,
    'isRecurring': isRecurring,
  };

  /// Ricostruisce un [MyEvent] a partire dalla mappa prodotta da [toJson].
  factory MyEvent.fromJson(Map<String, dynamic> json) => MyEvent(
    id: json['id'] as String,
    groupId: json['groupId'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    startTime: TimeOfDay(
      hour: json['startHour'] as int,
      minute: json['startMinute'] as int,
    ),
    endTime: TimeOfDay(
      hour: json['endHour'] as int,
      minute: json['endMinute'] as int,
    ),
    color: Color(json['color'] as int),
    isRecurring: json['isRecurring'] as bool? ?? false,
  );
}

// =============================================================================
// WIDGET PRINCIPALE
// =============================================================================

/// Pagina del calendario. Riceve la mappa degli eventi da HomePage tramite
/// [eventsMap] e notifica ogni modifica tramite [onEventsUpdated], così
/// HomePage può ricalcolare immediatamente la predizione del pisolino.
class CalendarPage extends StatefulWidget {
  final Map<DateTime, List<MyEvent>> eventsMap;
  final Function(Map<DateTime, List<MyEvent>>) onEventsUpdated;
  final bool isEnglish;

  const CalendarPage({
    super.key,
    required this.eventsMap,
    required this.onEventsUpdated,
    this.isEnglish = false,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now().subtract(
    Duration(days: 1),
  ); // giorno visibile al centro del calendario
  DateTime? _selectedDay; // giorno selezionato dall'utente

  /// Palette colori assegnabili agli eventi
  final List<Color> _colors = [
    Colors.blue,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.purple,
    Colors.teal,
    const Color.fromARGB(255, 243, 115, 222),
  ];

  /// Categorie disponibili per gli eventi
  final List<String> _categories = [
    "Lezione",
    "Pranzo",
    "Studio",
    "Allenamento",
    "Altro",
  ];

  @override
  void initState() {
    super.initState();
    // Al primo avvio il giorno selezionato coincide con oggi
    _selectedDay = _focusedDay;
  }

  // ---------------------------------------------------------------------------
  // UTILITY
  // ---------------------------------------------------------------------------

  /// Formatta un [TimeOfDay] come "HH:MM" con zero padding (formato 24h)
  String _formatTime24h(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  /// Restituisce gli eventi del giorno [day] ordinati per orario di inizio.
  /// Usato sia da [eventLoader] (marker sul calendario) sia da [_buildEventList].
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

  // ---------------------------------------------------------------------------
  // BUILD PRINCIPALE
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isEnglish);
    return Column(
      children: [
        SizedBox(height: 50),
        // --- Calendario (TableCalendar) ---
        TableCalendar<MyEvent>(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,

          startingDayOfWeek: StartingDayOfWeek
              .monday, //vogliamo che il calendario inizi da lunedì
          //due possibili formati (settimanale e mensile)
          availableCalendarFormats: {
            CalendarFormat.month: s.monthFormat,
            CalendarFormat.week: s.weekFormat,
          },

          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            formatButtonTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontWeight: FontWeight.bold,
            ),
            formatButtonPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            leftChevronPadding: const EdgeInsets.all(4.0),
            rightChevronPadding: const EdgeInsets.all(4.0),
          ),

          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

          onDaySelected: (sel, foc) => setState(() {
            _selectedDay = sel;
            _focusedDay = foc;
          }),

          onFormatChanged: (format) => setState(() => _calendarFormat = format),

          eventLoader: _getSortedEvents,

          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final text = s.weekdays[day.weekday - 1];
              return Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color:
                        day.weekday == DateTime.sunday ||
                            day.weekday == DateTime.saturday
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },

            headerTitleBuilder: (context, day) {
              return Text(
                "${s.monthNames[day.month - 1]} ${day.year}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },

            //visualizzare i puntini evento sotto al giorno corrispondente (ne visualizza al massimo 4)
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
            label: Text(s.addActivity),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LISTA EVENTI
  // ---------------------------------------------------------------------------

  /// Lista cronologica degli eventi del giorno selezionato.
  /// Ogni riga mostra: pallino colorato | titolo | categoria e orari | modifica/elimina.
  Widget _buildEventList() {
    final s = AppStrings(widget.isEnglish);
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
            "${s.categoryDisplay(ev.category)} • ${_formatTime24h(ev.startTime)} - ${_formatTime24h(ev.endTime)}",
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Apre il foglio di modifica pre-compilato con i dati dell'evento
              //(non posso variare la tipologia di evento, nè la ripetizione)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => _showAddSheet(eventToEdit: ev),
              ),
              // Apre il dialog di conferma eliminazione
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

  // ---------------------------------------------------------------------------
  // FOGLIO DI INSERIMENTO / MODIFICA
  // ---------------------------------------------------------------------------

  /// Mostra il bottom sheet per creare o modificare un evento.
  ///
  /// Modalità creazione ([eventToEdit] == null):
  ///   - tutti i campi vuoti/default
  ///   - selettore ripetizione visibile
  ///   - bottone "SALVA ATTIVITÀ"
  ///
  /// Modalità modifica ([eventToEdit] != null):
  ///   - campi pre-compilati con i dati esistenti
  ///   - categoria bloccata (non modificabile)
  ///   - selettore ripetizione nascosto
  ///   - bottone "AGGIORNA"
  void _showAddSheet({MyEvent? eventToEdit}) {
    final strings = AppStrings(widget.isEnglish);
    final bool isEditing = eventToEdit != null;
    String selectedCat = isEditing ? eventToEdit.category : _categories[0];
    final tCtrl = TextEditingController(
      text: isEditing ? eventToEdit.title : "",
    );
    TimeOfDay startTime = isEditing ? eventToEdit.startTime : TimeOfDay.now();
    // Fine di default = inizio + 1 ora (con wrap alle 24h tramite % 24)
    TimeOfDay endTime = isEditing
        ? eventToEdit.endTime
        : TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute);
    Color selCol = isEditing ? eventToEdit.color : _colors[0];
    String repetition = 'Singola'; // chiave interna, sempre in italiano

    // --- NUOVO: Lista colori temporanea per questa singola apertura del foglio ---
    List<Color> localColors = List.from(_colors);
    // Se stiamo modificando un evento con un colore custom, lo aggiungiamo temporaneamente
    if (isEditing && !localColors.contains(selCol)) {
      localColors.add(selCol);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // permette al foglio di crescere con la tastiera
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        // StatefulBuilder necessario: il foglio gestisce il proprio stato interno
        // (categoria, orari, colore, ripetizione) separato da quello della pagina
        builder: (ctx, setSt) => Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  ctx,
                ).viewInsets.bottom, // evita la tastiera
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo del foglio
                    Center(
                      child: Text(
                        isEditing ? strings.editDetails : strings.newActivity,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- Selezione categoria (chip) ---
                    // In modifica i chip sono disabilitati: la categoria non può cambiare
                    Text(
                      strings.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: _categories.map((cat) {
                        final isSelected = selectedCat == cat;
                        return ChoiceChip(
                          // cat è la chiave interna in italiano; la label è tradotta
                          label: Text(strings.categoryDisplay(cat)),
                          selected: isSelected,
                          onSelected: isEditing
                              ? null // null disabilita il chip in modifica
                              : (selected) {
                                  if (selected) setSt(() => selectedCat = cat);
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // --- Titolo opzionale ---
                    // Se lasciato vuoto, al salvataggio viene usato il nome della categoria
                    Text(
                      strings.titleOpt,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tCtrl,
                      decoration: InputDecoration(
                        hintText: strings.titleHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Selezione orari inizio / fine (time picker 24h) ---
                    // Toccare "Inizio" aggiorna automaticamente "Fine" a +1h
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: startTime,
                                builder: (context, child) => MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                ),
                              );
                              if (t != null) {
                                setSt(() {
                                  startTime = t;
                                  // Aggiorna fine automaticamente a inizio + 1h
                                  endTime = TimeOfDay(
                                    hour: (t.hour + 1) % 24,
                                    minute: t.minute,
                                  );
                                });
                              }
                            },
                            child: _timeBox(strings.startTime, startTime),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: endTime,
                                builder: (context, child) => MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                ),
                              );
                              if (t != null) setSt(() => endTime = t);
                            },
                            child: _timeBox(strings.endTime, endTime),
                          ),
                        ),
                      ],
                    ),

                    // --- Ripetizione (solo in creazione, nascosto in modifica) ---
                    // Singola | Giornaliera (30gg) | Settimanale (12 sett.) | Mensile (6 mesi)
                    if (!isEditing) ...[
                      const SizedBox(height: 20),
                      Text(
                        strings.repetition,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      DropdownButton<String>(
                        value: repetition,
                        isExpanded: true,
                        items: ['Singola', 'Giornaliera', 'Settimanale', 'Mensile']
                            .map(
                              // value resta la chiave italiana (usata da _save),
                              // il testo mostrato è tradotto
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(strings.repetitionDisplay(key)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setSt(() => repetition = v!),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // --- Selezione colore (riga di pallini scrollabile) ---
                    // Il pallino selezionato ha un bordo nero
                    Text(
                      strings.colorLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // 1. Usa localColors invece di _colors
                          ...localColors.map(
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
                          ),

                          // 2. Cerchio arcobaleno per il Color Picker
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: ctx,
                                builder: (BuildContext dialogContext) {
                                  Color tempColor = selCol;
                                  return AlertDialog(
                                    title: Text(strings.colorLabel),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: selCol,
                                        onColorChanged: (Color color) {
                                          tempColor = color;
                                        },
                                        pickerAreaHeightPercent: 0.8,
                                        enableAlpha: false,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(strings.cancel),
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
                                      ),
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          setSt(() {
                                            selCol = tempColor;
                                            // Aggiungiamo il colore alla lista LOCALE, non a quella globale
                                            if (!localColors.contains(
                                              tempColor,
                                            )) {
                                              localColors.add(tempColor);
                                            }
                                          });
                                          Navigator.of(dialogContext).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.cyan,
                                    Colors.blue,
                                    Colors.red,
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ), //parte rifatta
                    const SizedBox(height: 25),

                    // --- Bottone SALVA / AGGIORNA ---
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Validazione 1: fine deve essere strettamente dopo inizio
                        final startMin = startTime.hour * 60 + startTime.minute;
                        final endMin = endTime.hour * 60 + endTime.minute;
                        if (endMin <= startMin) {
                          _showErrorDialog(ctx, strings.endBeforeStart);
                          return;
                        }

                        // Validazione 2: Pranzo può essere inserito una sola volta per giorno.
                        // Controlla tutti i giorni coperti dalla ripetizione scelta.
                        if (selectedCat == "Pranzo") {
                          bool conflictFound = false;
                          int daysToCheck = 1;
                          if (!isEditing) {
                            if (repetition == 'Giornaliera') daysToCheck = 30;
                            if (repetition == 'Settimanale') daysToCheck = 12;
                            if (repetition == 'Mensile') daysToCheck = 6;
                          }

                          for (int i = 0; i < daysToCheck; i++) {
                            DateTime d = _selectedDay!;
                            if (!isEditing) {
                              if (repetition == 'Giornaliera')
                                d = d.add(Duration(days: i));
                              if (repetition == 'Settimanale')
                                d = d.add(Duration(days: 7 * i));
                              if (repetition == 'Mensile')
                                d = DateTime(d.year, d.month + i, d.day);
                            }
                            final key = DateTime(d.year, d.month, d.day);
                            final existingEvents = widget.eventsMap[key] ?? [];

                            // Esclude l'evento corrente dal controllo duplicati
                            // (altrimenti in modifica troverebbe sé stesso come conflitto)
                            if (existingEvents.any(
                              (e) =>
                                  e.category == "Pranzo" &&
                                  e.id != (eventToEdit?.id ?? ""),
                            )) {
                              conflictFound = true;
                              break;
                            }
                          }

                          if (conflictFound) {
                            _showErrorDialog(ctx, strings.lunchDuplicate);
                            return;
                          }
                        }

                        // Se il titolo è vuoto usa il nome della categoria (tradotto) come fallback
                        String finalTitle = tCtrl.text.trim().isEmpty
                            ? strings.categoryDisplay(selectedCat)
                            : tCtrl.text;

                        if (isEditing) {
                          if (eventToEdit.isRecurring) {
                            // Evento ricorrente → chiede se aggiornare solo questo o tutti
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
                      child: Text(
                        isEditing ? strings.updateBtn : strings.saveActivity,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ), // SingleChildScrollView
            ),

            // Bottone X in alto a destra per chiudere il foglio senza salvare
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

  // ---------------------------------------------------------------------------
  // DIALOGS
  // ---------------------------------------------------------------------------

  /// Dialog di errore generico con un solo bottone "HO CAPITO" / "GOT IT".
  void _showErrorDialog(BuildContext ctx, String message) {
    final s = AppStrings(widget.isEnglish);
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Text(s.attention),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.understood),
          ),
        ],
      ),
    );
  }

  /// Dialog per eventi ricorrenti in modifica.
  /// L'utente sceglie se applicare la modifica solo a questa occorrenza o a tutte.
  void _showUpdateOptionDialog(
    MyEvent ev,
    String title,
    TimeOfDay start,
    TimeOfDay end,
    Color col,
  ) {
    final s = AppStrings(widget.isEnglish);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editRecurring),
        content: Text(s.editRecurringMsg),
        actions: [
          TextButton(
            onPressed: () {
              _applySingleUpdate(ev, title, start, end, col);
              Navigator.pop(ctx); // chiude il dialog
              Navigator.pop(context); // chiude il bottom sheet
            },
            child: Text(s.thisOne),
          ),
          TextButton(
            onPressed: () {
              _applyGroupUpdate(ev.groupId, title, start, end, col);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(s.allBtn),
          ),
        ],
      ),
    );
  }

  /// Dialog di eliminazione.
  /// Per eventi ricorrenti mostra il bottone "TUTTE" (in rosso) che rimuove
  /// tutte le occorrenze con lo stesso [groupId].
  void _showDeleteDialog(MyEvent ev) {
    final s = AppStrings(widget.isEnglish);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteActivity),
        content: Text(ev.isRecurring ? s.isRecurringMsg : s.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          // Elimina solo l'occorrenza corrente (per id)
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
            child: Text(s.thisActivity),
          ),
          // Mostrato solo per eventi ricorrenti: elimina tutte le occorrenze
          if (ev.isRecurring)
            TextButton(
              onPressed: () {
                setState(() {
                  // Scorre tutta la mappa e rimuove ogni evento con lo stesso groupId
                  widget.eventsMap.values.forEach(
                    (list) => list.removeWhere((e) => e.groupId == ev.groupId),
                  );
                });
                widget.onEventsUpdated(widget.eventsMap);
                Navigator.pop(ctx);
              },
              child: Text(
                s.allOccurrences,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPERAZIONI SUGLI EVENTI
  // ---------------------------------------------------------------------------

  /// Aggiorna titolo, orari e colore di un singolo evento (per [id]).
  /// Usato sia per eventi singoli sia per la scelta "SOLO QUESTO" nei ricorrenti.
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

  /// Aggiorna titolo, orari e colore di tutti gli eventi con lo stesso [gId].
  /// Usato per la scelta "TUTTI" negli eventi ricorrenti.
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

  Widget _timeBox(String label, TimeOfDay time) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime24h(time),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Salva uno o più eventi in base alla [repetition] scelta.
  /// Tutti gli eventi di una serie condividono lo stesso [groupId] (= timestamp).
  ///
  /// Contatori di ripetizione:
  ///   Giornaliera  → 30 occorrenze (~1 mese)
  ///   Settimanale  → 12 occorrenze (~3 mesi)
  ///   Mensile      → 6  occorrenze (~6 mesi)
  void _save(
    String t,
    String cat,
    TimeOfDay start,
    TimeOfDay end,
    Color c,
    String r,
  ) {
    final gid = DateTime.now()
        .subtract(Duration(days: 1))
        .toString(); // groupId univoco basato sul timestamp
    int count = 1;
    if (r == 'Giornaliera') count = 30;
    if (r == 'Settimanale') count = 12;
    if (r == 'Mensile') count = 6;

    setState(() {
      for (int i = 0; i < count; i++) {
        // Calcola la data dell'i-esima occorrenza
        DateTime d = _selectedDay!;
        if (r == 'Giornaliera') d = d.add(Duration(days: i));
        if (r == 'Settimanale') d = d.add(Duration(days: 7 * i));
        if (r == 'Mensile') d = DateTime(d.year, d.month + i, d.day);

        // Normalizza la chiave a mezzanotte (senza ore/minuti/secondi)
        final key = DateTime(d.year, d.month, d.day);
        widget.eventsMap.putIfAbsent(key, () => []);
        widget.eventsMap[key]!.add(
          MyEvent(
            id: "$gid-$i", // id univoco per ogni occorrenza della serie
            groupId: gid,
            title: t,
            category: cat,
            startTime: start,
            endTime: end,
            color: c,
            isRecurring: r != 'Singola',
          ),
        );
      }
    });
    widget.onEventsUpdated(widget.eventsMap);
  }
}
