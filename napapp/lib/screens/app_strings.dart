// All the strings in italin and english.
class AppStrings {
  final bool isEnglish;
  const AppStrings(this.isEnglish);

  // ---------------------------------------------------------------------------
  // DRAWER
  // ---------------------------------------------------------------------------
  String hello(String name) => isEnglish ? 'Hello $name' : 'Ciao $name';
  String get logout => isEnglish ? 'Logout' : 'Logout';
  String get themeLabel => isEnglish ? 'THEME' : 'TEMA';
  String get languageLabel => isEnglish ? 'LANGUAGE' : 'LINGUA';
  String get tutorialLabel => isEnglish ? 'TUTORIAL' : 'TUTORIAL';
  String get creditsLabel => isEnglish ? 'CREDITS' : 'CREDITS';

  // ---------------------------------------------------------------------------
  // BOTTOM NAV
  // ---------------------------------------------------------------------------
  String get navHome => 'Home';
  String get navCalendar => isEnglish ? 'Calendar' : 'Calendario';
  String get navStats => isEnglish ? 'Statistics' : 'Statistiche';

  // ---------------------------------------------------------------------------
  // HOME
  // ---------------------------------------------------------------------------
  String get todaySchedule =>
      isEnglish ? "Today's Schedule" : 'Impegni di oggi';
  String get noEvents =>
      isEnglish ? 'No events today' : 'Nessun impegno per oggi';

  // Drawer greeting (two-line layout: "Hello," + name)
  String get greetingLabel => isEnglish ? 'Hello,' : 'Ciao,';
  String get userLabel => isEnglish ? 'USER' : 'UTENTE';

  // Alarm dialog recommendation box
  String get recommendedNap =>
      isEnglish ? 'Recommended nap' : 'Pisolino consigliato';
  String napMinutes(int minutes) =>
      isEnglish ? '$minutes minutes' : '$minutes minuti';

  // Alarm dialog preset buttons
  String get presetReflexes => isEnglish ? 'Reflexes' : 'Riflessi';
  String get presetFocus => 'Focus';
  String get presetRecovery => isEnglish ? 'Recovery' : 'Recupero';
  String get startNapButton => isEnglish ? 'Start nap' : 'Avvia pisolino';

  // ---------------------------------------------------------------------------
  // SDS REWARD
  // ---------------------------------------------------------------------------
  String get sdsGreat => isEnglish ? 'Great shape' : 'Ottima forma';
  String get sdsLight => isEnglish ? 'Slight deficit' : 'Leggero deficit';
  String get sdsModerate => isEnglish ? 'Moderate debt' : 'Debito moderato';
  String get sdsSevere => isEnglish ? 'Severe debt' : 'Debito severo';

  // ---------------------------------------------------------------------------
  // NAP SCOPE (the keys 'Recupero','Focus','Riflessi' come from NapAlgorithm)
  // ---------------------------------------------------------------------------
  String translateScope(String key) {
    if (!isEnglish) return key;
    switch (key) {
      case 'Recupero':
        return 'Recovery';
      case 'Focus':
        return 'Focus';
      case 'Riflessi':
        return 'Reflexes';
      default:
        return key;
    }
  }

  // ---------------------------------------------------------------------------
  // DEBUG ZONE
  // ---------------------------------------------------------------------------
  String get zoneGreen => isEnglish ? '🟢 Green' : '🟢 Verde';
  String get zoneYellow => isEnglish ? '🟡 Yellow' : '🟡 Gialla';
  String get zoneOrange => isEnglish ? '🟠 Orange' : '🟠 Arancione';
  String get zoneRed => isEnglish ? '🔴 Red' : '🔴 Rossa';
  String get zoneBeyond => isEnglish ? 'beyond' : 'oltre';

  // ---------------------------------------------------------------------------
  // PREDICTION STRING
  // ---------------------------------------------------------------------------
  String get redZoneMsg => isEnglish
      ? 'Red Zone • Too late to sleep'
      : 'Zona Rossa • Troppo tardi per dormire';
  String get orangeMsg => isEnglish
      ? 'Emergency window — only to reduce momentary drowsiness'
      : 'Finestra di emergenza — solo per ridurre la sonnolenza momentanea';
  String get idealNap => isEnglish ? 'Ideal Nap' : 'Pisolino ideale';
  String get emergencyNapPrediction =>
      isEnglish ? 'Valid Nap' : 'Pisolino Valido';
  String get fromTime => isEnglish ? 'from' : 'dalle';

  // ---------------------------------------------------------------------------
  // NAP CARD
  // ---------------------------------------------------------------------------
  String get napLabel => isEnglish ? 'Nap' : 'Pisolino';
  String get napEmergencyLabel =>
      isEnglish ? 'Emergency Nap' : 'Pisolino di emergenza';

  String napDetails(int total, String scope) => isEnglish
      ? '  $total min total  •  $scope'
      : '  $total min totali  •  $scope';

  String get inertiaWarning => isEnglish
      ? "You may feel drowsiness in the first ~10 min of the next activity"
      : "Potresti avvertire stanchezza nei primi ~10 min dell'attività successiva";

  // ---------------------------------------------------------------------------
  // DIALOG ALLARM
  // ---------------------------------------------------------------------------
  String get chooseNapTime =>
      isEnglish ? 'Choose nap time:' : 'Scegli tempo pisolino:';
  String get startAlarm => isEnglish ? 'Start' : 'Avvia';
  String get selectAlarmTitle =>
      isEnglish ? 'Select the timer:' : 'Seleziona la sveglia:';

  String alarmTimerStarted(int minutes) => isEnglish
      ? '$minutes-minute timer started'
      : 'Timer di $minutes minuti avviato';

  String alarmSet(int hours, int minutes) {
    if (isEnglish) {
      if (hours > 0 && minutes > 0)
        return 'Alarm set in ${hours}h and ${minutes}m';
      if (hours > 0) return 'Alarm set in $hours hours';
      return 'Alarm set in $minutes minutes';
    } else {
      if (hours > 0 && minutes > 0)
        return 'Sveglia impostata tra ${hours}h e ${minutes}m';
      if (hours > 0) return 'Sveglia impostata tra $hours ore';
      return 'Sveglia impostata tra $minutes minuti';
    }
  }

  // ---------------------------------------------------------------------------
  // CALENDAR- BUTTON AND HEADER
  // ---------------------------------------------------------------------------
  String get addActivity => isEnglish ? 'Add Activity' : 'Aggiungi Attività';
  String get monthFormat => isEnglish ? 'Month' : 'Mese';
  String get weekFormat => isEnglish ? 'Week' : 'Sett.';

  List<String> get weekdays => isEnglish
      ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      : ['lun', 'mar', 'mer', 'gio', 'ven', 'sab', 'dom'];

  List<String> get monthNames => isEnglish
      ? [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ]
      : [
          'Gennaio',
          'Febbraio',
          'Marzo',
          'Aprile',
          'Maggio',
          'Giugno',
          'Luglio',
          'Agosto',
          'Settembre',
          'Ottobre',
          'Novembre',
          'Dicembre',
        ];

  // ---------------------------------------------------------------------------
  // CALENDARIO – BOTTOM SHEET
  // ---------------------------------------------------------------------------
  String get newActivity => isEnglish ? 'New Activity' : 'Nuova Attività';
  String get editDetails => isEnglish ? 'Edit Details' : 'Modifica Dettagli';
  String get category => isEnglish ? 'Category' : 'Categoria';
  String get titleOpt => isEnglish ? 'Title (optional)' : 'Titolo (opzionale)';
  String get titleHint =>
      isEnglish ? 'e.g. Swimming, Art, ...' : 'es. Nuoto, Arte, ...';
  String get startTime => isEnglish ? 'Start' : 'Inizio';
  String get endTime => isEnglish ? 'End' : 'Fine';
  String get repetition => isEnglish ? 'Repetition' : 'Ripetizione';
  String get colorLabel => isEnglish ? 'Color' : 'Colore';
  String get saveActivity => isEnglish ? 'SAVE ACTIVITY' : 'SALVA ATTIVITÀ';
  String get updateBtn => isEnglish ? 'UPDATE' : 'AGGIORNA';

 // the key is in italian
  String categoryDisplay(String key) {
    if (!isEnglish) return key;
    switch (key) {
      case 'Lezione':
        return 'Lesson';
      case 'Pranzo':
        return 'Lunch';
      case 'Studio':
        return 'Study';
      case 'Allenamento':
        return 'Training';
      case 'Altro':
        return 'Other';
      default:
        return key;
    }
  }

  // The key is in italian
  String repetitionDisplay(String key) {
    if (!isEnglish) return key;
    switch (key) {
      case 'Singola':
        return 'Single';
      case 'Giornaliera':
        return 'Daily';
      case 'Settimanale':
        return 'Weekly';
      case 'Mensile':
        return 'Monthly';
      default:
        return key;
    }
  }

  // ---------------------------------------------------------------------------
  // DIALOGS 
  // ---------------------------------------------------------------------------
  String get attention => isEnglish ? 'Warning' : 'Attenzione';
  String get understood => isEnglish ? 'GOT IT' : 'HO CAPITO';
  String get endBeforeStart => isEnglish
      ? 'End time cannot be before start time.'
      : "L'orario di fine non può essere oltre l'orario di inizio.";
  String get lunchDuplicate => isEnglish
      ? 'Cannot save: Lunch activity already added on one of the selected days'
      : 'Impossibile salvare: attività Pranzo già inserita in uno dei giorni selezionati';

  // Dialog recurrent event 
  String get editRecurring =>
      isEnglish ? 'Edit recurring event' : 'Modifica evento ricorrente';
  String get editRecurringMsg => isEnglish
      ? 'Do you want to apply changes to this event only or all occurrences?'
      : 'Vuoi applicare le modifiche solo a questo evento o a tutte le ripetizioni?';
  String get thisOne => isEnglish ? 'THIS ONE' : 'SOLO QUESTO';
  String get allBtn => isEnglish ? 'ALL' : 'TUTTI';

  // Dialog delete
  String get deleteActivity =>
      isEnglish ? 'Delete activity' : 'Elimina attività';
  String get isRecurringMsg => isEnglish
      ? 'This is a recurring activity.'
      : "Questa è un'attività ricorrente.";
  String get deleteConfirm => isEnglish
      ? 'Do you want to delete this activity?'
      : 'Vuoi eliminare questa attività?';
  String get cancel => isEnglish ? 'CANCEL' : 'ANNULLA';
  String get thisActivity => isEnglish ? 'THIS ACTIVITY' : "QUESTA ATTIVITA'";
  String get allOccurrences => isEnglish ? 'ALL' : 'TUTTE';

  // ---------------------------------------------------------------------------
  // DIALOG THEME SELECTION (in the drawer)
  // ---------------------------------------------------------------------------
  String get selectTheme => isEnglish ? 'Select Theme' : 'Seleziona tema';
  String get themeSystem => isEnglish ? 'System' : 'Sistema';
  String get themeLight => isEnglish ? 'Light' : 'Chiaro';
  String get themeDark => isEnglish ? 'Dark' : 'Scuro';

  // ---------------------------------------------------------------------------
  // DIALOG LANGUAGE SELECTION (in the drawer)
  // ---------------------------------------------------------------------------
  String get selectLanguage =>
      isEnglish ? 'Select Language' : 'Seleziona Lingua';

  // Language names are self-referential and stay the same in both languages
  String get languageItalian => 'Italiano';
  String get languageEnglish => 'English';

  // ---------------------------------------------------------------------------
  // DIALOG BIBLIOGRAPHY (in the drawer)
  // ---------------------------------------------------------------------------
  String get bibliographyLabel =>
      isEnglish ? 'BIBLIOGRAPHY' : 'BIBLIOGRAFIA';
  String get bibliographyDialogTitle =>
      isEnglish ? 'Bibliography:' : 'Bibliografia:';

  // ---------------------------------------------------------------------------
  // PROFILE PAGE
  // ---------------------------------------------------------------------------
  String get profileTitle => isEnglish ? 'Profile' : 'Profilo';
  String get nicknameLabel => 'Nickname';
  String get enterNameHint => isEnglish ? 'Enter name' : 'Inserisci nome';
  String get chooseProfileImage =>
      isEnglish ? 'Choose profile image' : 'Scegli immagine profilo';
  String get saveButton => isEnglish ? 'Save' : 'Salva';

  // ---------------------------------------------------------------------------
  // STATS PAGE
  // ---------------------------------------------------------------------------
  String get statsHeaderTitle => isEnglish ? 'Statistics' : 'Statistiche';
  String get statsHeaderSubtitle =>
      isEnglish ? 'Your sleep journey' : 'Il tuo percorso del sonno';

  String get sleepTrendTitle => isEnglish ? 'Sleep Trend' : 'Andamento del sonno';

  String get sleepDebtTitle => isEnglish ? 'Sleep Debt' : 'Debito di Sonno';
  String get wellRestedMsg =>
      isEnglish ? "You're well rested" : 'Hai riposato bene';
  String get recoveryNeededMsg =>
      isEnglish ? 'Some recovery needed' : "Serve un po' di recupero";

  String get sleepScoreTitle =>
      isEnglish ? 'Sleep Score' : 'Punteggio del sonno';
  String get excellentSleepMsg =>
      isEnglish ? 'Excellent sleep' : 'Sonno eccellente';
  String get goodSleepMsg => isEnglish ? 'Good sleep' : 'Sonno buono';
  String get needsAttentionMsg =>
      isEnglish ? 'Needs attention' : 'Richiede attenzione';

  String get avgSleepTitle => isEnglish
      ? 'Average Sleep (last 7 days)'
      : 'Sonno medio (ultimi 7 giorni)';
  String get thisWeekTitle => isEnglish ? 'This Week' : 'Questa settimana';
  String napsCount(int n) => isEnglish
      ? '$n ${n == 1 ? 'nap' : 'naps'}'
      : '$n ${n == 1 ? 'pisolino' : 'pisolini'}';

  String get weeklyInsightTitle =>
      isEnglish ? 'Weekly Insight' : 'Analisi Settimanale';
  String get sleepImprovedMsg => isEnglish
      ? 'Your sleep consistency improved this week!'
      : 'La costanza del tuo sonno è migliorata questa settimana!';
  String get sleepDecreasedMsg => isEnglish
      ? 'Your sleep consistency decreased this week.'
      : 'La costanza del tuo sonno è diminuita questa settimana.';
  String get sleepUnchangedMsg => isEnglish
      ? 'Your sleep consistency did not change this week.'
      : 'La costanza del tuo sonno non è cambiata questa settimana.';
  String avgSleepIncrease(int minutes) => isEnglish
      ? '+$minutes min average sleep'
      : '+$minutes min sonno medio';
  String avgSleepDecrease(int minutes) => isEnglish
      ? '-$minutes min average sleep'
      : '-$minutes min sonno medio';
  String get avgSleepNoChange => isEnglish
      ? 'No change in average sleep'
      : 'Nessun cambiamento nel sonno medio';

  // ---------------------------------------------------------------------------
  // TUTORIAL PAGES
  // ---------------------------------------------------------------------------
  List<Map<String, String>> get tutorialPages =>
      isEnglish ? _tutorialPagesEn : _tutorialPagesIt;

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
          'e altre informazioni d\'interesse.',
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
      'body': 'Go to Calendar and press "+ Add Activity" to add an event.',
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
          'and other information of interest.',
    },
    {
      'emoji': '🚀',
      'title': 'Ready to start?',
      'body':
          'Set up your schedule, monitor your rest and improve your daily productivity. Happy napping!',
    },
  ];
}
