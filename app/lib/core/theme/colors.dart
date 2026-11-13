import 'package:flutter/painting.dart';

/// Fixed colors that are not theme tokens: flame drawing (DESIGN.md §9.20),
/// gradients (§3.3), brand mark (§2.3), shadows (§6) and button text (§9.1).
abstract final class FsFixedColors {
  // FlameTwin ramp, space value → Earth value (lerped by buoyancy b).
  static const glowSpace = Color(0xFF2F6BFF), glowEarth = Color(0xFFFF6A1A);
  static const coreSpace = Color(0xFFDCEBFF), coreEarth = Color(0xFFFFF4CF);
  static const midSpace = Color(0xFF5AA0FF), midEarth = Color(0xFFFFA640);
  static const edgeSpace = Color(0xFF2F5BFF), edgeEarth = Color(0xFFFF5A14);
  static const innerSpace = Color(0xFFF2F8FF), innerEarth = Color(0xFFFFFBEA);
  static const sootHalo = Color(0xFFFFC46B);
  static const fuelSample = Color(0xFF3B4A6E);

  /// Glow alpha at the flame centre (§3.3 chamberGlow*).
  static const glowAlpha = 0.28;

  // Brand mark (§2.3): dark-background and light-background variants.
  static const markStrokeDark = Color(0xFFFF8A3D),
      markCircleDark = Color(0xFF6CB6FF);
  static const markStrokeLight = Color(0xFFE2621B),
      markCircleLight = Color(0xFF1F66D6);

  // Shadows and highlights (§6).
  static const panelHighlightDark = Color(0x0AFFFFFF); // #FFFFFF @ 4%
  static const panelShadowLight = Color(0x0F0D1526); // rgba(13,21,38,.06)
  static const raisedShadowLight = Color(0x1F0D1526); // rgba(13,21,38,.12)
  static const chamberInnerShadow = Color(0x99000000); // rgba(0,0,0,.6)

  // Danger button text (§9.1).
  static const onDangerDark = Color(0xFF1A0006),
      onDangerLight = Color(0xFFFFFFFF);

  // Mission Fire Brief PDF (§11.13), as 0xRRGGBB ints for the pdf package.
  static const pdfText = 0x0D1526, pdfSpace = 0x1F66D6, pdfEarth = 0xB4480C;
}
