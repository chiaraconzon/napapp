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
  String get themeLabel    => isEnglish ? 'THEME'     : 'TEMA';
  String get languageLabel => isEnglish ? 'LANGUAGE'  : 'LINGUA';
  String get tutorialLabel => isEnglish ? 'TUTORIAL'  : 'TUTORIAL';
  String get creditsLabel  => isEnglish ? 'CREDITS'   : 'CREDITS';

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
      case 'Focus':  return 'Focus';
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
  String get emergencyNapPrediction => isEnglish ? 'Valid Nap' : 'Pisolino Valido';
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
  String get selectAlarmTitle => isEnglish ? 'Select the timer:' : 'Seleziona la sveglia:';

  String alarmTimerStarted(int minutes) => isEnglish
      ? '$minutes-minute timer started'
      : 'Timer di $minutes minuti avviato';

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

  
  // Questa traduce la label visualizzata della tipologia di evento (chiave interna resta in italiano).
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

  // Ripetizione: la chiave interna resta in italiano.
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
  // DIALOG SELEZIONE TEMA (nel drawer)
  // ---------------------------------------------------------------------------
  String get selectTheme => isEnglish ? 'Select Theme' : 'Seleziona tema';
  String get themeSystem => isEnglish ? 'System'       : 'Sistema';
  String get themeLight  => isEnglish ? 'Light'        : 'Chiaro';
  String get themeDark   => isEnglish ? 'Dark'         : 'Scuro';

  // ---------------------------------------------------------------------------
  // DIALOG SELEZIONE LINGUA (nel drawer)
  // ---------------------------------------------------------------------------
  String get selectLanguage => isEnglish ? 'Select Language' : 'Seleziona Lingua';

  // ---------------------------------------------------------------------------
  // TUTORIAL PAGES
  // ---------------------------------------------------------------------------
  List<Map<String, String>> get tutorialPages => isEnglish
      ? _tutorialPagesEn
      : _tutorialPagesIt;

  static const List<Map<String, String>> _tutorialPagesIt = [
    {
      'emoji': '👋',
      'title': 'Benvenuto in NapApp',
      'body':
          'NapApp ti aiuta a pianificare il pisolino perfetto in base ai tuoi impegni e al tuo debito di sonno. Scorri per scoprire come funziona.',
    },
    {
      'emoji': '🟢',
      'title': 'Zone Temporali',
      'body':
          'Quattro zone indicano la qualità della fascia oraria per il pisolino:\n\n'
          '🟢 Verde — momento ideale\n'
          '🟡 Gialla — pisolino valido\n'
          '🟠 Arancione — finestra di emergenza ridotta\n'
          '🔴 Rossa — troppo tardi, nessun pisolino',
    },
    {
      'emoji': '🔋',
      'title': 'Debito di Sonno (SDS)',
      'body':
          'L\'app calcola il tuo Saldo Debito Sonno sulle ultime 7 notti e mostra uno di questi quattro stati:\n\n'
          '🔋 Ottima forma — hai dormito a sufficienza\n'
          '🙂 Leggero deficit — piccola carenza di sonno\n'
          '🥱 Debito moderato — accumulo stanchezza\n'
          '🚨 Debito severo — recupero urgente',
    },
    {
      'emoji': '⏱️',
      'title': 'Durata del Pisolino',
      'body':
          'Tre tipologie di pisolino:\n\n'
          '⚡ 10–15 min — boost immediato dei riflessi\n'
          '🧠 20–30 min — migliora concentrazione\n'
          '🔋 60–90 min — recupero energetico\n\n'
          'L\'app sceglie la durata migliore per te automaticamente in base al tuo debito di sonno e agli eventi programmati.',
    },
    {
      'emoji': '💤',
      'title': 'Collocazione del Pisolino',
      'body':
          'Dopo un pisolino il corpo ha bisogno di tempo per ristabilirsi. '
          'L\'app garantisce sempre una distanza adeguata tra la fine del pisolino e le tue attività successive.',
    },
    {
      'emoji': '📅',
      'title': 'Aggiungere Impegni',
      'body':
          'Vai in Calendario e premi "+ Aggiungi Attività" per inserire un impegno.',
    },
    {
      'emoji': '⏰',
      'title': 'Impostare la Sveglia',
      'body':
          'Dalla home puoi avviare una sveglia: '
          'scegli la durata desiderata per il pisolino e premi "Avvia". '
          'Riceverai una notifica allo scadere del tempo.',
    },
    {
      'emoji': '📊',
      'title': 'Statistiche',
      'body':
          'In Statistiche trovi il riepilogo del tuo sonno settimanale '
          'e l\'andamento del debito di sonno nel tempo.',
    },
    {
      'emoji': '🚀',
      'title': 'Pronto a iniziare?',
      'body':
          'Configura i tuoi orari, monitora il tuo riposo e migliora la tua produttività quotidiana. Buon pisolino!',
    },
  ];

  static const List<Map<String, String>> _tutorialPagesEn = [
    {
      'emoji': '👋',
      'title': 'Welcome to NapApp',
      'body':
          'NapApp helps you plan the perfect nap based on your schedule and sleep debt. Swipe to find out how it works.',
    },
    {
      'emoji': '🟢',
      'title': 'Time Zones',
      'body':
          'Four zones indicate the quality of the time slot for a nap:\n\n'
          '🟢 Green — ideal moment\n'
          '🟡 Yellow — valid nap\n'
          '🟠 Orange — reduced emergency window\n'
          '🔴 Red — too late, no nap',
    },
    {
      'emoji': '🔋',
      'title': 'Sleep Debt (SDS)',
      'body':
          'The app calculates your Sleep Debt Score over the last 7 nights and shows one of these four states:\n\n'
          '🔋 Great shape — you\'ve slept enough\n'
          '🙂 Slight deficit — small sleep shortage\n'
          '🥱 Moderate debt — fatigue is building up\n'
          '🚨 Severe debt — urgent recovery needed',
    },
    {
      'emoji': '⏱️',
      'title': 'Nap Duration',
      'body':
          'Three types of nap:\n\n'
          '⚡ 10–15 min — immediate reflex boost\n'
          '🧠 20–30 min — improve concentration\n'
          '🔋 60–90 min — energy recovery\n\n'
          'The app automatically picks the best duration based on your sleep debt and scheduled events.',
    },
    {
      'emoji': '💤',
      'title': 'Nap Placement',
      'body':
          'After a nap, your body needs time to recover. '
          'The app always ensures adequate distance between the end of your nap and your upcoming activities.',
    },
    {
      'emoji': '📅',
      'title': 'Adding Activities',
      'body':
          'Go to Calendar and press "+ Add Activity" to add an event.',
    },
    {
      'emoji': '⏰',
      'title': 'Setting the Alarm',
      'body':
          'From the home screen you can start a timer: '
          'choose the desired nap duration and press "Start". '
          'You\'ll receive a notification when time is up.',
    },
    {
      'emoji': '📊',
      'title': 'Statistics',
      'body':
          'In Statistics you\'ll find a summary of your weekly sleep '
          'and the trend of your sleep debt over time.',
    },
    {
      'emoji': '🚀',
      'title': 'Ready to start?',
      'body':
          'Set up your schedule, monitor your rest and improve your daily productivity. Happy napping!',
    },
  ];
}
