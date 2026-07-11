import 'package:flutter/material.dart';

//NAP ZONE
enum NapZone { green, yellow, orange, red }

// ALGORITHM RESULT
class NapResult {
  final NapZone zone;
  final int napEffectiveMin;
  final int totalDisplayMin;
  final TimeOfDay? suggestedStart;
  final TimeOfDay? suggestedEnd;
  final String scope;
  final String scopeEmoji;
  final bool hasInertiaWarning;
  NapStatus status;

  NapResult({
    required this.zone,
    required this.napEffectiveMin,
    required this.totalDisplayMin,
    this.suggestedStart,
    this.suggestedEnd,
    required this.scope,
    required this.scopeEmoji,
    this.hasInertiaWarning = false,
    this.status = NapStatus.suggested,
  });
}

// ZONE LIMITS
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

// NAP STATUS
enum NapStatus { suggested, running, completed, interrupted }
