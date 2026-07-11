import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5c5d72),
      surfaceTint: Color(0xff5c5d72),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffb8b8d1),
      onPrimaryContainer: Color(0xff47485d),
      secondary: Color(0xff43477d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b5f97),
      onSecondaryContainer: Color(0xffdedeff),
      tertiary: Color(0xff7e5700),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffc154),
      onTertiaryContainer: Color(0xff734f00),
      error: Color(0xffae2f35),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffff6b6c),
      onErrorContainer: Color(0xff6d0011),
      surface: Color(0xfffcf8f7),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff47464c),
      outline: Color(0xff77767d),
      outlineVariant: Color(0xffc8c5cd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffc4c4de),
      primaryFixed: Color(0xffe1e0fa),
      onPrimaryFixed: Color(0xff181a2d),
      primaryFixedDim: Color(0xffc4c4de),
      onPrimaryFixedVariant: Color(0xff44455a),
      secondaryFixed: Color(0xffe0e0ff),
      onSecondaryFixed: Color(0xff11144a),
      secondaryFixedDim: Color(0xffbec2ff),
      onSecondaryFixedVariant: Color(0xff3e4278),
      tertiaryFixed: Color(0xffffdeac),
      onTertiaryFixed: Color(0xff281900),
      tertiaryFixedDim: Color(0xfff9bc4f),
      onTertiaryFixedVariant: Color(0xff604100),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffcf8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff333549),
      surfaceTint: Color(0xff5c5d72),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6a6b82),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2d3166),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b5f97),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4a3100),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff916500),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff730013),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffc23e42),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f7),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff36363c),
      outline: Color(0xff525258),
      outlineVariant: Color(0xff6d6c73),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffc4c4de),
      primaryFixed: Color(0xff6a6b82),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff525368),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6468a1),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4c5087),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff916500),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff724e00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffcf8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xffebe7e6),
      surfaceContainerHigh: Color(0xffdfdcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff292b3e),
      surfaceTint: Color(0xff5c5d72),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff46485c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff23265b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff40447a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3d2800),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff634300),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff60000e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff901823),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f7),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2c2c31),
      outlineVariant: Color(0xff49484f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffc4c4de),
      primaryFixed: Color(0xff46485c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff303145),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff40447a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff292d62),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff634300),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff462e00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffcf8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd4d4ed),
      surfaceTint: Color(0xffc4c4de),
      onPrimary: Color(0xff2d2f43),
      primaryContainer: Color(0xffb8b8d1),
      onPrimaryContainer: Color(0xff47485d),
      secondary: Color(0xffbec2ff),
      onSecondary: Color(0xff272b60),
      secondaryContainer: Color(0xff5b5f97),
      onSecondaryContainer: Color(0xffdedeff),
      tertiary: Color(0xffffe4bd),
      onTertiary: Color(0xff432c00),
      tertiaryContainer: Color(0xffffc154),
      onTertiaryContainer: Color(0xff734f00),
      error: Color(0xffffb3b0),
      onError: Color(0xff680010),
      errorContainer: Color(0xffff6b6c),
      onErrorContainer: Color(0xff6d0011),

      // 🌙 NUOVA PALETTE NIGHT MODE
      surface: Color(0xff121326),
      onSurface: Color(0xffeeeef7),
      onSurfaceVariant: Color(0xffc7c5d8),
      outline: Color(0xff918fa8),
      outlineVariant: Color(0xff46445f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff5c5d72),
      primaryFixed: Color(0xffe1e0fa),
      onPrimaryFixed: Color(0xff181a2d),
      primaryFixedDim: Color(0xffc4c4de),
      onPrimaryFixedVariant: Color(0xff44455a),
      secondaryFixed: Color(0xffe0e0ff),
      onSecondaryFixed: Color(0xff11144a),
      secondaryFixedDim: Color(0xffbec2ff),
      onSecondaryFixedVariant: Color(0xff3e4278),
      tertiaryFixed: Color(0xffffdeac),
      onTertiaryFixed: Color(0xff281900),
      tertiaryFixedDim: Color(0xfff9bc4f),
      onTertiaryFixedVariant: Color(0xff604100),

      // 🌌 livelli delle card
      surfaceDim: Color(0xff101021),
      surfaceBright: Color(0xff3b3955),
      surfaceContainerLowest: Color(0xff0c0d1c),
      surfaceContainerLow: Color(0xff19182b),
      surfaceContainer: Color(0xff23213d),
      surfaceContainerHigh: Color(0xff2d2a4b),
      surfaceContainerHighest: Color(0xff38345b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdadaf4),
      surfaceTint: Color(0xffc4c4de),
      onPrimary: Color(0xff232437),
      primaryContainer: Color(0xffb8b8d1),
      onPrimaryContainer: Color(0xff2a2c3f),
      secondary: Color(0xffd9d9ff),
      onSecondary: Color(0xff1c2054),
      secondaryContainer: Color(0xff888cc7),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffe4bd),
      onTertiary: Color(0xff3f2900),
      tertiaryContainer: Color(0xffffc154),
      onTertiaryContainer: Color(0xff4f3500),
      error: Color(0xffffd2cf),
      onError: Color(0xff54000b),
      errorContainer: Color(0xffff6b6c),
      onErrorContainer: Color(0xff230002),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdedbe3),
      outline: Color(0xffb3b1b8),
      outlineVariant: Color(0xff918f97),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff45465b),
      primaryFixed: Color(0xffe1e0fa),
      onPrimaryFixed: Color(0xff0e1022),
      primaryFixedDim: Color(0xffc4c4de),
      onPrimaryFixedVariant: Color(0xff333549),
      secondaryFixed: Color(0xffe0e0ff),
      onSecondaryFixed: Color(0xff050740),
      secondaryFixedDim: Color(0xffbec2ff),
      onSecondaryFixedVariant: Color(0xff2d3166),
      tertiaryFixed: Color(0xffffdeac),
      onTertiaryFixed: Color(0xff1a0f00),
      tertiaryFixedDim: Color(0xfff9bc4f),
      onTertiaryFixedVariant: Color(0xff4a3100),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282827),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff0eeff),
      surfaceTint: Color(0xffc4c4de),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffc1c0da),
      onPrimaryContainer: Color(0xff080a1c),
      secondary: Color(0xfff0eeff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbabefc),
      onSecondaryContainer: Color(0xff00013b),
      tertiary: Color(0xffffedd7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffffc154),
      onTertiaryContainer: Color(0xff221500),
      error: Color(0xffffecea),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffadaa),
      onErrorContainer: Color(0xff220002),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff2eff7),
      outlineVariant: Color(0xffc4c1c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff45465b),
      primaryFixed: Color(0xffe1e0fa),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffc4c4de),
      onPrimaryFixedVariant: Color(0xff0e1022),
      secondaryFixed: Color(0xffe0e0ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbec2ff),
      onSecondaryFixedVariant: Color(0xff050740),
      tertiaryFixed: Color(0xffffdeac),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff9bc4f),
      onTertiaryFixedVariant: Color(0xff1a0f00),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
