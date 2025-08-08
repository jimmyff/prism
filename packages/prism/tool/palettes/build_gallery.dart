import 'dart:io';
import 'package:path/path.dart' as p;

// Import your actual library classes to use their logic.
// The relative path is crucial here.
import 'package:prism/prism.dart';

// Import the generated palette enums
import 'package:prism/palettes/rgb/spectrum.dart';
import 'package:prism/palettes/oklch/spectrum.dart';
import 'package:prism/palettes/rgb/css.dart';
import 'package:prism/palettes/oklch/css.dart';
import 'package:prism/palettes/rgb/material.dart';
import 'package:prism/palettes/oklch/material.dart';
import 'package:prism/palettes/rgb/open_color.dart';
import 'package:prism/palettes/oklch/open_color.dart';
// import '../lib/palettes/catppuccin_latte.dart';
// import '../lib/palettes/catppuccin_frappe.dart';
// import '../lib/palettes/catppuccin_macchiato.dart';
// import '../lib/palettes/catppuccin_mocha.dart';
// import '../lib/palettes/solarized.dart';

// Import the generators
import 'palette_image_generator.dart';
import 'palette_html_generator.dart';

void main() {
  print('Generating gallery...');

  _generateGallery<SpectrumRgb, SpectrumOklch>(
    className: 'Spectrum',
    rgbEnum: SpectrumRgb.values,
    oklchEnum: SpectrumOklch.values,
    preferredEnum: SpectrumOklch.values,
    cssClassName: 'spectrum',
  );

  _generateGallery<CssRgb, CssOklch>(
    className: 'Css',
    rgbEnum: CssRgb.values,
    oklchEnum: CssOklch.values,
    preferredEnum: CssRgb.values,
    cssClassName: 'css',
  );

  _generateGallery<MaterialRgb, MaterialOklch>(
    className: 'Material',
    rgbEnum: MaterialRgb.values,
    oklchEnum: MaterialOklch.values,
    preferredEnum: MaterialRgb.values,
    cssClassName: 'material',
  );

  _generateGallery<OpenColorRgb, OpenColorOklch>(
    className: 'OpenColor',
    rgbEnum: OpenColorRgb.values,
    oklchEnum: OpenColorOklch.values,
    preferredEnum: OpenColorRgb.values,
    cssClassName: 'oc',
  );

  // _generateGallery(
  //   className: 'CatppuccinLatte',
  //   rgbEnum: CatppuccinLatteRgb.values,
  //   oklchEnum: CatppuccinLatteOklch.values,
  //   cssClassName: 'catppuccin-latte',
  // );

  // _generateGallery(
  //   className: 'CatppuccinFrappe',
  //   rgbEnum: CatppuccinFrappeRgb.values,
  //   oklchEnum: CatppuccinFrappeOklch.values,
  //   cssClassName: 'catppuccin-frappe',
  // );

  // _generateGallery(
  //   className: 'CatppuccinMacchiato',
  //   rgbEnum: CatppuccinMacchiatoRgb.values,
  //   oklchEnum: CatppuccinMacchiatoOklch.values,
  //   cssClassName: 'catppuccin-macchiato',
  // );

  // _generateGallery(
  //   className: 'CatppuccinMocha',
  //   rgbEnum: CatppuccinMochaRgb.values,
  //   oklchEnum: CatppuccinMochaOklch.values,
  //   cssClassName: 'catppuccin-mocha',
  // );

  // _generateGallery(
  //   className: 'Solarized',
  //   rgbEnum: SolarizedRgb.values,
  //   oklchEnum: SolarizedOklch.values,
  //   cssClassName: 'solarized',
  // );

  print('Gallery generated successfully!');
}

void _generateGallery<T extends PrismPalette, Q extends PrismPalette>({
  required String className,
  required List<T> rgbEnum,
  required List<Q> oklchEnum,
  required List<PrismPalette> preferredEnum,
  required String cssClassName,
  Map<String, String>? aliases,
}) {
  // Convert enum values to scheme maps
  final Map<String, RayScheme<RayWithLuminance>> schemesRgb = {};
  final Map<String, RayScheme<RayWithLuminance>> schemesOklch = {};

  for (final enumValue in rgbEnum) {
    final name = (enumValue as Enum).name;
    schemesRgb[name] = enumValue;
  }

  for (final enumValue in oklchEnum) {
    final name = (enumValue as Enum).name;
    schemesOklch[name] = enumValue;
  }

  final scriptDir = Directory(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.parent.parent.parent.parent; // Go up 4 levels
  final galleryDir = p.join(projectRoot.path, 'palette_gallery');

  // Generate gallery HTML and CSS
  PaletteHtmlGenerator.generateGalleryHtml(
    className: className,
    schemesRgb: schemesRgb,
    schemesOklch: schemesOklch,
    cssClassName: cssClassName,
    aliases: aliases,
    outputPath: galleryDir,
  );

  // Generate PNG image
  final imageOutputPath = p.join(galleryDir, '$className.png');
  PaletteImageGenerator.generatePaletteImage(
    className: className,
    schemes: schemesOklch,
    outputPath: imageOutputPath,
    aliases: aliases,
  );
}
