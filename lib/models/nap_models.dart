import 'package:flutter/material.dart';

// =============================================================================
// ENUM ZONA
// =============================================================================
enum NapZone { green, yellow, orange, red }

// =============================================================================
// RISULTATO ALGORITMO
// =============================================================================
class NapResult {
  final NapZone zone;
  final int napEffectiveMin;
  final int totalDisplayMin;
  final TimeOfDay? suggestedStart;
  final TimeOfDay? suggestedEnd;
  final String scope;
  final String scopeEmoji;
  final bool hasInertiaWarning;

  const NapResult({
    required this.zone,
    required this.napEffectiveMin,
    required this.totalDisplayMin,
    this.suggestedStart,
    this.suggestedEnd,
    required this.scope,
    required this.scopeEmoji,
    this.hasInertiaWarning = false,
  });
}

// =============================================================================
// LIMITI ZONE
// =============================================================================
class ZoneLimits {
  final int greenStart;
  final int greenEnd;
  final int yellowEnd;
  final int orangeEnd;
  const ZoneLimits({
    required this.greenStart,
    required this.greenEnd,
    required this.yellowEnd,
    required this.orangeEnd,
  });
}
