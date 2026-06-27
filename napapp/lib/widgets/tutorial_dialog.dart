import 'package:flutter/material.dart';

// =============================================================================
// TUTORIAL DIALOG
// =============================================================================

class TutorialDialog extends StatefulWidget {
  final List<Map<String, String>> pages;
  const TutorialDialog({required this.pages});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _current = 0;

  void _prev() {
    if (_current > 0) setState(() => _current--);
  }

  void _next() {
    if (_current < widget.pages.length - 1) setState(() => _current++);
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[_current];
    final total = widget.pages.length;
    final isFirst = _current == 0;
    final isLast = _current == total - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Stack(
        children: [
          // ---- Contenuto principale ----
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji grande
                Text(page['emoji']!, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 16),

                // Titolo
                Text(
                  page['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Testo descrittivo
                Text(
                  page['body']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ---- Frecce + pallini indicatori ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Freccia sinistra (grigia alla prima pagina)
                    IconButton(
                      onPressed: isFirst ? null : _prev,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: isFirst ? Colors.grey.shade300 : Colors.black87,
                      ),
                    ),

                    // Pallini: quello attivo è più grande e scuro
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(total, (i) {
                        final isActive = i == _current;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 10 : 7,
                          height: isActive ? 10 : 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.black87
                                : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),

                    // Freccia destra (grigia all'ultima pagina)
                    IconButton(
                      onPressed: isLast ? null : _next,
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: isLast ? Colors.grey.shade300 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---- Tasto X in alto a destra ----
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
