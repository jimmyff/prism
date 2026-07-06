# Prism Packages 🌈

This repository contains the `prism`, `prism_flutter`, `prism_theme` and `prism_theme_flutter` packages, providing powerful color and theming tools for Dart and Flutter.

## Packages

| Package                                       | Description                                                  |
| --------------------------------------------- | ------------------------------------------------------------ |
| [**`prism`**](./packages/prism)               | An optimized, zero-dependency color manipulation library for Dart & Flutter with multiple color models, accessibility tools, and pre-built palettes. |
| [**`prism_flutter`**](./packages/prism_flutter) | Flutter-specific extensions for seamless Ray color ↔ Color conversions. |
| [**`prism_theme`**](./packages/prism_theme)   | An authored, compilable theme system built on Prism's perceptual colors — intent-based roles, contrast auditing, and light/dark + continuous transition interpolation. |
| [**`prism_theme_flutter`**](./packages/prism_theme_flutter) | Flutter bindings for `prism_theme` — a `ThemeExtension`, `ThemeData` mapping, and `context.prism`. |

Please see the `README.md` in each package's directory for more information.

## Repository Structure

```text
.
├── packages/
│   ├── prism/
│   ├── prism_flutter/
│   ├── prism_theme/
│   └── prism_theme_flutter/
├── palette_gallery/
└── README.md
```

## Palette Gallery

The color palettes can be previewed as PNG images or HTML files in the `palette_gallery/` directory. CSS versions are also available for web development use. Dart implementations of all palettes are included within the [prism](./packages/prism) package.

## License

This project is licensed under the MIT License.

**Author:** [Jimmy Forrester-Fellowes](https://github.com/jimmyff). For an introduction to Prism see [Jimmy's blog post](https://www.jimmyff.co.uk/blog/prism-dart-flutter-color-package/)
