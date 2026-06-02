import 'package:flutter/material.dart';

enum AppLogoVariant { logoOnly, textOnly, logoAndText }

class AppLogo extends StatelessWidget {
  final AppLogoVariant variant;
  final double height;
  final BoxFit fit;
  final Alignment alignment;

  const AppLogo({
    super.key,
    required this.variant,
    required this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
  });

  String get _assetPath => switch (variant) {
    AppLogoVariant.logoOnly => 'assets/images/logo/logoonly.png',
    AppLogoVariant.textOnly => 'assets/images/logo/textonly.png',
    AppLogoVariant.logoAndText => 'assets/images/logo/logoandtext.png',
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
