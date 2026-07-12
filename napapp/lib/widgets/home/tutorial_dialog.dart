import 'package:flutter/material.dart';

// Tutorial dialog that displays multiple pages using horizontal swipe
class TutorialDialog extends StatefulWidget {
  final List<Map<String, String>> pages;
  const TutorialDialog({Key? key, required this.pages}) : super(key: key);

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  // Controls horizontal page navigation
  final PageController _pageController = PageController();
  // Stores the currently displayed page index
  int _current = 0;

  @override
  void dispose() {
    // Dispose controller to release resources
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size and current theme
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Adjust colors according to light/dark mode
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.colorScheme.surface;
    final textColor = isDark ? Colors.white : Colors.black87;
    final fadedColor = isDark ? Colors.white30 : Colors.black26;

    final total = widget.pages.length;
    // Check whether user reached the last tutorial page
    final isLast = _current == total - 1;

    return Dialog(
      // Main tutorial card container
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // Tutorial card size and appearance
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
            // Main tutorial content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                children: [
                  // Horizontal swipeable tutorial pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      // Updates current page indicator
                      onPageChanged: (index) {
                        setState(() {
                          _current = index;
                        });
                      },
                      itemCount: total,
                      // Builds each tutorial page
                      itemBuilder: (ctx, i) {
                        final p = widget.pages[i];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Tutorial icon
                            Text(
                              p['emoji'] ?? '✨',
                              style: const TextStyle(fontSize: 54),
                            ),
                            const SizedBox(height: 24),
                            // Tutorial title
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
                            // Tutorial description text
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

                  // Bottom section with indicators and start button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page progress indicators
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
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : fadedColor,
                            ),
                          );
                        }),
                      ),

                      // Shows start button on final page
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isLast ? 70 : 20,
                        child: isLast
                            ? Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  //Closes tutorial dialog (INIZIA button)
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
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

            // Close button available on every tutorial page (X)
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
