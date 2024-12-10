import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4a662d),
      surfaceTint: Color(0xff4a662d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffcbeda5),
      onPrimaryContainer: Color(0xff0e2000),
      secondary: Color(0xff57624a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdbe7c8),
      onSecondaryContainer: Color(0xff151e0b),
      tertiary: Color(0xff386664),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbbece8),
      onTertiaryContainer: Color(0xff00201f),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff1a1c16),
      onSurfaceVariant: Color(0xff44483d),
      outline: Color(0xff75796c),
      outlineVariant: Color(0xffc4c8ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffb0d18b),
      primaryFixed: Color(0xffcbeda5),
      onPrimaryFixed: Color(0xff0e2000),
      primaryFixedDim: Color(0xffb0d18b),
      onPrimaryFixedVariant: Color(0xff334e17),
      secondaryFixed: Color(0xffdbe7c8),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff404a34),
      tertiaryFixed: Color(0xffbbece8),
      onTertiaryFixed: Color(0xff00201f),
      tertiaryFixedDim: Color(0xffa0cfcc),
      onTertiaryFixedVariant: Color(0xff1f4e4c),
      surfaceDim: Color(0xffd9dbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f5e9),
      surfaceContainer: Color(0xffedefe4),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff304a13),
      surfaceTint: Color(0xff4a662d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff607d41),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3c4630),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6d785f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1a4a48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4f7c7a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff1a1c16),
      onSurfaceVariant: Color(0xff40443a),
      outline: Color(0xff5c6155),
      outlineVariant: Color(0xff787c70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffb0d18b),
      primaryFixed: Color(0xff607d41),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff48642a),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6d785f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff556048),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4f7c7a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff366361),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd9dbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f5e9),
      surfaceContainer: Color(0xffedefe4),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff132700),
      surfaceTint: Color(0xff4a662d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff304a13),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1c2512),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff3c4630),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002726),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1a4a48),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff21251c),
      outline: Color(0xff40443a),
      outlineVariant: Color(0xff40443a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffd5f7ae),
      primaryFixed: Color(0xff304a13),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff1a3300),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff3c4630),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff26301b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff1a4a48),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003331),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd9dbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f5e9),
      surfaceContainer: Color(0xffedefe4),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 139, 209, 171),
      surfaceTint: Color.fromARGB(255, 139, 209, 162),
      onPrimary: Color.fromARGB(255, 2, 55, 33),
      primaryContainer: Color.fromARGB(255, 23, 78, 52),
      onPrimaryContainer: Color.fromARGB(255, 165, 237, 183),
      secondary: Color.fromARGB(255, 173, 203, 184),
      onSecondary: Color.fromARGB(255, 31, 51, 39),
      secondaryContainer: Color.fromARGB(255, 52, 74, 61),
      onSecondaryContainer: Color.fromARGB(255, 200, 231, 212),
      tertiary: Color(0xffa0cfcc),
      onTertiary: Color(0xff003735),
      tertiaryContainer: Color(0xff1f4e4c),
      onTertiaryContainer: Color(0xffbbece8),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color.fromARGB(255, 14, 20, 17),
      onSurface: Color.fromARGB(255, 216, 227, 221),
      onSurfaceVariant: Color.fromARGB(255, 186, 200, 192),
      outline: Color.fromARGB(255, 133, 146, 138),
      outlineVariant: Color.fromARGB(255, 61, 72, 65),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color.fromARGB(255, 216, 227, 224),
      inversePrimary: Color.fromARGB(255, 45, 102, 71),
      primaryFixed: Color(0xffcbeda5),
      onPrimaryFixed: Color(0xff0e2000),
      primaryFixedDim: Color(0xffb0d18b),
      onPrimaryFixedVariant: Color(0xff334e17),
      secondaryFixed: Color(0xffdbe7c8),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff404a34),
      tertiaryFixed: Color(0xffbbece8),
      onTertiaryFixed: Color(0xff00201f),
      tertiaryFixedDim: Color(0xffa0cfcc),
      onTertiaryFixedVariant: Color(0xff1f4e4c),
      surfaceDim: Color.fromARGB(255, 14, 20, 18),
      surfaceBright: Color.fromARGB(255, 51, 58, 54),
      surfaceContainerLowest: Color.fromARGB(255, 9, 15, 12),
      surfaceContainerLow: Color.fromARGB(255, 22, 28, 25),
      surfaceContainer: Color.fromARGB(255, 26, 33, 30),
      surfaceContainerHigh: Color.fromARGB(255, 36, 43, 41),
      surfaceContainerHighest: Color(0xff33362e),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb4d58f),
      surfaceTint: Color(0xffb0d18b),
      onPrimary: Color(0xff0b1a00),
      primaryContainer: Color(0xff7b9a5a),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc3cfb1),
      onSecondary: Color(0xff101907),
      secondaryContainer: Color(0xff89957a),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffa4d4d0),
      onTertiary: Color(0xff001a19),
      tertiaryContainer: Color(0xff6b9996),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff12140e),
      onSurface: Color(0xfffafcf0),
      onSurfaceVariant: Color(0xffc9ccbe),
      outline: Color(0xffa1a497),
      outlineVariant: Color(0xff818578),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inversePrimary: Color(0xff344f18),
      primaryFixed: Color(0xffcbeda5),
      onPrimaryFixed: Color(0xff071400),
      primaryFixedDim: Color(0xffb0d18b),
      onPrimaryFixedVariant: Color(0xff233d07),
      secondaryFixed: Color(0xffdbe7c8),
      onSecondaryFixed: Color(0xff0b1404),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff2f3924),
      tertiaryFixed: Color(0xffbbece8),
      onTertiaryFixed: Color(0xff001413),
      tertiaryFixedDim: Color(0xffa0cfcc),
      onTertiaryFixedVariant: Color(0xff083d3b),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff373a33),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e211a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362e),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff4ffe1),
      surfaceTint: Color(0xffb0d18b),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffb4d58f),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff4ffe1),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc3cfb1),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffeafffd),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa4d4d0),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff12140e),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff9fced),
      outline: Color(0xffc9ccbe),
      outlineVariant: Color(0xffc9ccbe),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inversePrimary: Color(0xff183000),
      primaryFixed: Color(0xffd0f2a9),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb4d58f),
      onPrimaryFixedVariant: Color(0xff0b1a00),
      secondaryFixed: Color(0xffdfebcc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc3cfb1),
      onSecondaryFixedVariant: Color(0xff101907),
      tertiaryFixed: Color(0xffc0f0ed),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa4d4d0),
      onTertiaryFixedVariant: Color(0xff001a19),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff373a33),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e211a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362e),
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
        scaffoldBackgroundColor: colorScheme.surface,
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
