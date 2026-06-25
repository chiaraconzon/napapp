/// Tutte le stringhe dell'app in italiano e inglese.
/// Le categorie degli eventi ('Pranzo', 'Studio', ecc.) NON sono qui:
/// sono chiavi interne dell'algoritmo e restano sempre in italiano.
class AppStrings {
  final bool isEnglish;
  const AppStrings(this.isEnglish);

  // ---------------------------------------------------------------------------
  // DRAWER
  // ---------------------------------------------------------------------------
  String hello(String name) => isEnglish ? 'Hello $name' : 'Ciao $name';
  String get logout        => isEnglish ? 'Logout'    : 'Logout';

  // ---------------------------------------------------------------------------
  // BOTTOM NAV
  // ---------------------------------------------------------------------------
  String get navHome     => 'Home';
  String get navCalendar => isEnglish ? 'Calendar'   : 'Calendario';
  String get navStats    => isEnglish ? 'Statistics'  : 'Statistiche';

  // ---------------------------------------------------------------------------
  // HOME
  // ---------------------------------------------------------------------------
  String get todaySchedule => isEnglish ? "Today's Schedule" : 'Impegni di oggi';
  String get noEvents      => isEnglish ? 'No events today'  : 'Nessun impegno per oggi';

  // ---------------------------------------------------------------------------
  // SDS REWARD
  // ---------------------------------------------------------------------------
  String get sdsGreat    => isEnglish ? 'Great shape'    : 'Ottima forma';
  String get sdsLight    => isEnglish ? 'Slight deficit' : 'Leggero deficit';
  String get sdsModerate => isEnglish ? 'Moderate debt'  : 'Debito moderato';
  String get sdsSevere   => isEnglish ? 'Severe debt'    : 'Debito severo';

  // ---------------------------------------------------------------------------
  // SCOPO PISOLINO (le chiavi 'Energie','Memoria','Riflessi' vengono da NapAlgorithm)
  // ---------------------------------------------------------------------------
  String translateScope(String key) {
    if (!isEnglish) return key;
    switch (key) {
      case 'Energie':  return 'Energy';
      case 'Memoria':  return 'Memory';
      case 'Riflessi': return 'Reflexes';
      default:         return key;
    }
  }

  // ---------------------------------------------------------------------------
  // DEBUG ZONE
  // ---------------------------------------------------------------------------
  String get zoneGreen  => isEnglish ? '🟢 Green'  : '🟢 Verde';
  String get zoneYellow => isEnglish ? '🟡 Yellow' : '🟡 Gialla';
  String get zoneOrange => isEnglish ? '🟠 Orange' : '🟠 Arancione';
  String get zoneRed    => isEnglish ? '🔴 Red'    : '🔴 Rossa';
  String get zoneBeyond => isEnglish ? 'beyond'    : 'oltre';

  // ---------------------------------------------------------------------------
  // STRINGA PREDIZIONE
  // ---------------------------------------------------------------------------
  String get redZoneMsg  => isEnglish
      ? 'Red Zone • Too late to sleep'
      : 'Zona Rossa • Troppo tardi per dormire';
  String get orangeMsg   => isEnglish
      ? 'Emergency window — only to reduce momentary drowsiness'
      : 'Finestra di emergenza — solo per ridurre la sonnolenza momentanea';
  String get idealNap    => isEnglish ? 'Ideal Nap'       : 'Pisolino ideale';
  String get emergencyNapPrediction => isEnglish ? 'Emergency Nap' : 'Pisolino di Emergenza';
  String get fromTime    => isEnglish ? 'from'            : 'dalle';

  // ---------------------------------------------------------------------------
  // CARD PISOLINO
  // ---------------------------------------------------------------------------
  String get napLabel          => isEnglish ? 'Nap'           : 'Pisolino';
  String get napEmergencyLabel => isEnglish ? 'Emergency Nap' : 'Pisolino di emergenza';

  String napDetails( int total, String scope) => isEnglish
      ? '  $total min total  •  $scope'
      : '  $total min totali  •  $scope';

  String get inertiaWarning => isEnglish
      ? "You may feel drowsiness in the first ~10 min of the next activity"
      : "Potresti avvertire stanchezza nei primi ~10 min dell'attività successiva";

  // ---------------------------------------------------------------------------
  // DIALOG SVEGLIA
  // ---------------------------------------------------------------------------
  String get chooseNapTime => isEnglish ? 'Choose nap time:' : 'Scegli tempo pisolino:';
  String get startAlarm    => isEnglish ? 'Start'            : 'Avvia';

  String alarmSet(int hours, int minutes) {
    if (isEnglish) {
      if (hours > 0 && minutes > 0) return 'Alarm set in ${hours}h and ${minutes}m';
      if (hours > 0)                return 'Alarm set in $hours hours';
      return 'Alarm set in $minutes minutes';
    } else {
      if (hours > 0 && minutes > 0) return 'Sveglia impostata tra ${hours}h e ${minutes}m';
      if (hours > 0)                return 'Sveglia impostata tra $hours ore';
      return 'Sveglia impostata tra $minutes minuti';
    }
  }

  // ---------------------------------------------------------------------------
  // CALENDARIO – BOTTONE E HEADER
  // ---------------------------------------------------------------------------
  String get addActivity  => isEnglish ? 'Add Activity'   : 'Aggiungi Attività';
  String get monthFormat  => isEnglish ? 'Month'          : 'Mese';
  String get weekFormat   => isEnglish ? 'Week'           : 'Sett.';

  List<String> get weekdays => isEnglish
      ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      : ['lun', 'mar', 'mer', 'gio', 'ven', 'sab', 'dom'];

  List<String> get monthNames => isEnglish
      ? ['January','February','March','April','May','June',
         'July','August','September','October','November','December']
      : ['Gennaio','Febbraio','Marzo','Aprile','Maggio','Giugno',
         'Luglio','Agosto','Settembre','Ottobre','Novembre','Dicembre'];

  // ---------------------------------------------------------------------------
  // CALENDARIO – BOTTOM SHEET
  // ---------------------------------------------------------------------------
  String get newActivity  => isEnglish ? 'New Activity'    : 'Nuova Attività';
  String get editDetails  => isEnglish ? 'Edit Details'    : 'Modifica Dettagli';
  String get category     => isEnglish ? 'Category'        : 'Categoria';
  String get titleOpt     => isEnglish ? 'Title (optional)': 'Titolo (opzionale)';
  String get titleHint    => isEnglish ? 'e.g. Swimming, Art, ...' : 'es. Nuoto, Arte, ...';
  String get startTime    => isEnglish ? 'Start'           : 'Inizio';
  String get endTime      => isEnglish ? 'End'             : 'Fine';
  String get repetition   => isEnglish ? 'Repetition'      : 'Ripetizione';
  String get colorLabel   => isEnglish ? 'Color'           : 'Colore';
  String get saveActivity => isEnglish ? 'SAVE ACTIVITY'   : 'SALVA ATTIVITÀ';
  String get updateBtn    => isEnglish ? 'UPDATE'          : 'AGGIORNA';

  // Categorie: le chiavi interne restano in italiano (usate dall'algoritmo).
  // Questa funzione traduce solo la label visualizzata.
  String categoryDisplay(String key) {
    if (!isEnglish) return key;
    switch (key) {
      case 'Lezione':    return 'Lesson';
      case 'Pranzo':     return 'Lunch';
      case 'Studio':     return 'Study';
      case 'Allenamento':return 'Training';
      case 'Altro':      return 'Other';
      default:           return key;
    }
  }

  // Ripetizione: la chiave interna resta in italiano (usata da _save()).
  // La label mostrata nel dropdown è tradotta.
  String repetitionDisplay(String key) {
    if (!isEnglish) return key;
    switch (key) {
      case 'Singola':     return 'Single';
      case 'Giornaliera': return 'Daily';
      case 'Settimanale': return 'Weekly';
      case 'Mensile':     return 'Monthly';
      default:            return key;
    }
  }

  // ---------------------------------------------------------------------------
  // DIALOGS ERRORE / CONFERMA
  // ---------------------------------------------------------------------------
  String get attention       => isEnglish ? 'Warning'       : 'Attenzione';
  String get understood      => isEnglish ? 'GOT IT'        : 'HO CAPITO';
  String get endBeforeStart  => isEnglish
      ? 'End time cannot be before start time.'
      : "L'orario di fine non può essere oltre l'orario di inizio.";
  String get lunchDuplicate  => isEnglish
      ? 'Cannot save: Lunch activity already added on one of the selected days'
      : 'Impossibile salvare: attività Pranzo già inserita in uno dei giorni selezionati';

  // Dialog evento ricorrente (modifica)
  String get editRecurring    => isEnglish ? 'Edit recurring event'    : 'Modifica evento ricorrente';
  String get editRecurringMsg => isEnglish
      ? 'Do you want to apply changes to this event only or all occurrences?'
      : 'Vuoi applicare le modifiche solo a questo evento o a tutte le ripetizioni?';
  String get thisOne => isEnglish ? 'THIS ONE' : 'SOLO QUESTO';
  String get allBtn  => isEnglish ? 'ALL'      : 'TUTTI';

  // Dialog eliminazione
  String get deleteActivity => isEnglish ? 'Delete activity'              : 'Elimina attività';
  String get isRecurringMsg => isEnglish ? 'This is a recurring activity.': "Questa è un'attività ricorrente.";
  String get deleteConfirm  => isEnglish ? 'Do you want to delete this activity?' : 'Vuoi eliminare questa attività?';
  String get cancel         => isEnglish ? 'CANCEL'        : 'ANNULLA';
  String get thisActivity   => isEnglish ? 'THIS ACTIVITY' : "QUESTA ATTIVITA'";
  String get allOccurrences => isEnglish ? 'ALL'           : 'TUTTE';

  // ---------------------------------------------------------------------------
  // DIALOG SELEZIONE LINGUA (nel drawer)
  // ---------------------------------------------------------------------------
  String get selectLanguage => isEnglish ? 'Select Language' : 'Seleziona Lingua';
}
