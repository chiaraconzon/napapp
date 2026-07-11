import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'app_strings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

//DATA MODEL

// Represents a single calendar event.
// Recurring events share the same [groupId], but each occurrence has a unique [id].
class MyEvent {
  String id; // ID univoco
  String groupId; // ID condiviso
  String title;
  String category; // Lezione | Pranzo | Studio | Allenamento | Altro
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;
  final bool isRecurring; // true if it is a recurring event

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

  // JSON Serialization: Required to save/load events via SharedPreferences.
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

  // Deserializes JSON back into a MyEvent object.
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

// MAIN WIDGET
// Calendar UI. Receives [eventsMap] and triggers [onEventsUpdated] 
// on changes to recalculate the Nap algorithm in HomePage.
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
  ); //focused day
  DateTime? _selectedDay; // selected day

  // Default color palette
  final List<Color> _colors = [
    Colors.blue,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.purple,
    Colors.teal,
    const Color.fromARGB(255, 243, 115, 222),
  ];

  // Core categories
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
    _selectedDay = _focusedDay; //default
  }


  // UTILITY
  // Formats TimeOfDay to "HH:MM" 24h string.
  String _formatTime24h(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  // Retrieves and chronologically sorts events for a specific day.
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

  // MAIN BUILD 
  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isEnglish);
    return Column(
      children: [
        SizedBox(height: 50),
        //Core calendar widget
        TableCalendar<MyEvent>(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,

          startingDayOfWeek: StartingDayOfWeek.monday, //calendar starts from monday
          
          //two possible formats (weekly and monthly)
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

          // Fixes text color for weekdays in dark mode
          calendarStyle: CalendarStyle(
            weekendTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
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

            // Draws up to 4 colored dots under days with events
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

        // Daily agenda list
        Expanded(child: _buildEventList()),

        // Add Activity button
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

  // EVENT LIST VIEW
  // Renders the chronological list of events for the selected day.
  // Each row displays: colored dot | title | category & times | edit/delete.
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
              // modify event button
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => _showAddSheet(eventToEdit: ev),
              ),
              // delete event button
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


  // ADD / EDIT BOTTOM SHEET
  // Shows the bottom sheet to Create (eventToEdit == null) or Edit events
  void _showAddSheet({MyEvent? eventToEdit}) {
    final strings = AppStrings(widget.isEnglish);
    final bool isEditing = eventToEdit != null;
    //Initialize form state
    String selectedCat = isEditing ? eventToEdit.category : _categories[0];
    final tCtrl = TextEditingController(
      text: isEditing ? eventToEdit.title : "",
    );
    TimeOfDay startTime = isEditing ? eventToEdit.startTime : TimeOfDay.now();
    // default end = start + 1h 
    TimeOfDay endTime = isEditing
        ? eventToEdit.endTime
        : TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute);
    Color selCol = isEditing ? eventToEdit.color : _colors[0];
    String repetition = 'Singola'; //key

    // Store custom colors picked during this session
    List<Color> localColors = List.from(_colors);
    if (isEditing && !localColors.contains(selCol)) {
      localColors.add(selCol);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // allow scrolling
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  ctx,
                ).viewInsets.bottom, 
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
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

                    // Category Selection (Disabled during edit)
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
                          // cat is a key
                          label: Text(strings.categoryDisplay(cat)),
                          selected: isSelected,
                          onSelected: isEditing
                              ? null // null disable modifing chip
                              : (selected) {
                                  if (selected) setSt(() => selectedCat = cat);
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Optional title 
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

                    // Time Pickers (Auto-updates end time based on start time (1h after))
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

                  // Repetition (Hidden during edit)
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

                    //Color Picker
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

                          // icon for colorpicker
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
                                            // Add the color to the local list
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
                    ), 
                    const SizedBox(height: 25),

                    // Save / Update Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Validate timeframe (end must be after start)
                        final startMin = startTime.hour * 60 + startTime.minute;
                        final endMin = endTime.hour * 60 + endTime.minute;
                        if (endMin <= startMin) {
                          _showErrorDialog(ctx, strings.endBeforeStart);
                          return;
                        }

                        // Ensure max 1 Lunch per day across all recurring dates (paying aldo attention to repetitive events)
                        if (selectedCat == "Pranzo") {
                          bool conflictFound = false;
                          int daysToCheck = 1;
                          if (!isEditing) {
                            if (repetition == 'Giornaliera') daysToCheck = 30; // 30 days
                            if (repetition == 'Settimanale') daysToCheck = 12; // 12 weeks
                            if (repetition == 'Mensile') daysToCheck = 6; // 6 months
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

                            // Don't consider the current event
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

                        // If title is empy, use the category
                        String finalTitle = tCtrl.text.trim().isEmpty
                            ? strings.categoryDisplay(selectedCat)
                            : tCtrl.text;

                        if (isEditing) {
                          if (eventToEdit.isRecurring) {
                            // reccurent event → ask if upload only this or all the repetitions
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
              ), 
            ),

            // X button to close the window
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


  // DIALOGS
  // Generic error pop-up "HO CAPITO" / "GOT IT".
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

  // Asks to update a single occurrence or the whole recurring series
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
              Navigator.pop(ctx); // close the dialog
              Navigator.pop(context); //close the bottom sheet
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

  // Deletes a single occurrence or the entire series (same groupID).
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
          // delete a single one (ID)
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
          // Show ongly for reccurent events: delete all the occurrences
          if (ev.isRecurring)
            TextButton(
              onPressed: () {
                setState(() {
                  // delete each event with the same groupId
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

  // STATE MUTATIONS & SAVE LOGIC
  // Updates a single event and triggers global refresh.
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

  // Updates all events sharing the same groupId.
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

  // Time Picker boxes.
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

  // Generates and saves single or multiple recurring events based on the repetition rule.
  void _save(
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
        .toString(); // groupId 
    int count = 1;
    if (r == 'Giornaliera') count = 30;
    if (r == 'Settimanale') count = 12;
    if (r == 'Mensile') count = 6;

    setState(() {
      for (int i = 0; i < count; i++) {
        // Calculate the date
        DateTime d = _selectedDay!;
        if (r == 'Giornaliera') d = d.add(Duration(days: i));
        if (r == 'Settimanale') d = d.add(Duration(days: 7 * i));
        if (r == 'Mensile') d = DateTime(d.year, d.month + i, d.day);

        // Normalized the key
        final key = DateTime(d.year, d.month, d.day);
        widget.eventsMap.putIfAbsent(key, () => []);
        widget.eventsMap[key]!.add(
          MyEvent(
            id: "$gid-$i", // unique id for each occorrence of the repetition
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
