import 'package:flutter/material.dart';

// =============================================================================
// TUTORIAL DIALOG
// =============================================================================

// Pagine del tutorial. Il testo SDS elenca i quattro stati possibili.
const List<Map<String, String>> tutorialPages = [
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
        '🟡 Gialla — pisolino di emergenza\n'
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
        '🥱 Debito moderato — stai accumulando stanchezza\n'
        '🚨 Debito severo — recupero urgente',
  },
  {
    'emoji': '⏱️',
    'title': 'Durata del Pisolino',
    'body':
        'Tre tipologie di pisolino:\n\n'
        '⚡ 10–15 min — boost immediato dei riflessi\n'
        '🧠 20–30 min — consolidamento memoria\n'
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
        'Vai in Calendario e premi "+ Aggiungi Attività" per inserire un impegno. ',
  },
  {
    'emoji': '⏰',
    'title': 'Impostare la Sveglia',
    'body':
        'Dalla home puoi avviare una sveglia direttamente nell\'app: '
        'scegli la durata desiderata per il pisolino e premi "Avvia". '
        'Riceverai una notifica allo scadere del tempo.',
  },
  {
    'emoji': '📊',
    'title': 'Statistiche',
    'body':
        'In Statistiche trovi il riepilogo del tuo sonno settimanale '
        'e l\'andamento del debito di sonno nel tempo. ',
  },
  {
    'emoji': '🚀',
    'title': 'Pronto a iniziare?',
    'body':
        'Configura i tuoi orari, monitora il tuo riposo e migliora la tua produttività quotidiana. Buon pisolino!',
  },
];

class TutorialDialog extends StatefulWidget {
  final List<Map<String, String>> pages;
  const TutorialDialog({Key? key, required this.pages}) : super(key: key);

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  // Controller per gestire lo scroll ORIZZONTALE
  final PageController _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Colori calibrati sul tema
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final fadedColor = isDark ? Colors.white30 : Colors.black26;

    final total = widget.pages.length;
    final isLast = _current == total - 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // Rende la Card nettamente più grande (80% dell'altezza dello schermo)
        height: size.height * 0.8,
        width: size.width * 0.9,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenuto principale con Scroll Orizzontale
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                children: [
                  // Area scorrevole orizzontalmente (PageView)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _current = index;
                        });
                      },
                      itemCount: total,
                      itemBuilder: (ctx, i) {
                        final p = widget.pages[i];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Emoji leggermente ridimensionata
                            Text(
                              p['emoji'] ?? '✨',
                              style: const TextStyle(fontSize: 54),
                            ),
                            const SizedBox(height: 24),
                            // Titolo più piccolo (20 anziché 24)
                            Text(
                              p['title'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Corpo del testo più piccolo (13.5 anziché 16)
                            Text(
                              p['body'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textColor.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Elementi inferiori: Indicatori e pulsante Inizia (se ultima pagina)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pallini indicatori delle pagine
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(total, (i) {
                          final isActive = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 10 : 6,
                            height: isActive ? 10 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? theme.colorScheme.primary : fadedColor,
                            ),
                          );
                        }),
                      ),
                      
                      // Spazio dinamico o Pulsante Inizia
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isLast ? 70 : 20,
                        child: isLast
                            ? Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Inizia',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tasto X in alto a destra per chiudere in qualsiasi momento
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(Icons.close, color: fadedColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
