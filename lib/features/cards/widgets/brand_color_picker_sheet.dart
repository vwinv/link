import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

/// Palette style macOS — rangée primaire, niveaux de gris, spectre 12×10.
abstract final class BrandColorPalette {
  static const primaryRow = [
    Color(0xFFFF3B30),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF32D74B),
    Color(0xFF5AC8FA),
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFFF2D55),
    Color(0xFFAC8E68),
    Color(0xFFFFFFFF),
    Color(0xFF8E8E93),
  ];

  static const columns = 12;
  static const rows = 10;

  static List<Color> get grayscaleRow {
    return List<Color>.generate(11, (index) {
      final value = 255 - (index * 255 ~/ 10);
      return Color.fromARGB(255, value, value, value);
    });
  }

  static List<Color> get spectrumGrid {
    final colors = <Color>[];
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final hue = col * 30.0;
        final t = row / (rows - 1);
        final lightness = 0.24 + t * 0.68;
        final saturation = (0.92 - t * 0.5).clamp(0.18, 1.0);
        colors.add(
          HSLColor.fromAHSL(1, hue, saturation, lightness).toColor(),
        );
      }
    }
    return colors;
  }
}

Future<Color?> showBrandColorPicker(
  BuildContext context, {
  required Rect anchor,
  Color? initialColor,
}) {
  return showGeneralDialog<Color>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer la palette',
    barrierColor: Colors.transparent,
    pageBuilder: (dialogContext, _, _) {
      return _BrandColorPickerPopover(
        anchor: anchor,
        initialColor: initialColor,
      );
    },
  );
}

class _BrandColorPickerPopover extends StatefulWidget {
  const _BrandColorPickerPopover({
    required this.anchor,
    this.initialColor,
  });

  final Rect anchor;
  final Color? initialColor;

  @override
  State<_BrandColorPickerPopover> createState() =>
      _BrandColorPickerPopoverState();
}

class _BrandColorPickerPopoverState extends State<_BrandColorPickerPopover> {
  static const _popoverWidth = 296.0;
  static const _swatchSize = 20.0;
  static const _swatchGap = 2.0;
  static const _panelColor = Color(0xFF323232);
  static const _panelBorder = Color(0xFF4A4A4C);

  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  void _select(Color color) {
    setState(() => _selectedColor = color);
    Navigator.of(context).pop(color);
  }

  Future<void> _openAdvancedPicker() async {
    final advanced = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => _AdvancedColorSheet(initialColor: _selectedColor),
    );
    if (advanced != null && mounted) {
      Navigator.of(context).pop(advanced);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final popoverHeight = _estimateHeight();
    var left = widget.anchor.center.dx - _popoverWidth / 2;
    left = left.clamp(AppSpacing.md, screen.width - _popoverWidth - AppSpacing.md);

    var top = widget.anchor.bottom + 10;
    if (top + popoverHeight > screen.height - AppSpacing.lg) {
      top = widget.anchor.top - popoverHeight - 10;
    }

    final arrowLeft =
        (widget.anchor.center.dx - left - 8).clamp(12.0, _popoverWidth - 24);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: _popoverWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: arrowLeft),
                  child: const _PopoverArrow(color: _panelColor),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _panelColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _panelBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SwatchRow(
                          colors: BrandColorPalette.primaryRow,
                          selectedColor: _selectedColor,
                          onSelect: _select,
                          swatchSize: _swatchSize,
                          gap: _swatchGap,
                        ),
                        const SizedBox(height: _swatchGap),
                        _GrayscaleRow(
                          selectedColor: _selectedColor,
                          onSelect: _select,
                          swatchSize: _swatchSize,
                          gap: _swatchGap,
                        ),
                        const SizedBox(height: _swatchGap),
                        _SpectrumGrid(
                          colors: BrandColorPalette.spectrumGrid,
                          selectedColor: _selectedColor,
                          onSelect: _select,
                          swatchSize: _swatchSize,
                          gap: _swatchGap,
                        ),
                        const SizedBox(height: 8),
                        _ShowColorsButton(onPressed: _openAdvancedPicker),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _estimateHeight() {
    const footer = 36.0;
    const padding = 18.0;
    const arrow = 8.0;
    return arrow +
        padding +
        _swatchSize +
        _swatchGap +
        _swatchSize +
        _swatchGap +
        BrandColorPalette.rows * _swatchSize +
        (BrandColorPalette.rows - 1) * _swatchGap +
        footer;
  }
}

class _PopoverArrow extends StatelessWidget {
  const _PopoverArrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 8),
      painter: _PopoverArrowPainter(color),
    );
  }
}

class _PopoverArrowPainter extends CustomPainter {
  _PopoverArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PopoverArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SwatchRow extends StatelessWidget {
  const _SwatchRow({
    required this.colors,
    required this.selectedColor,
    required this.onSelect,
    required this.swatchSize,
    required this.gap,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onSelect;
  final double swatchSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < colors.length; i++) ...[
          _ColorSwatch(
            color: colors[i],
            isSelected: _isSame(colors[i], selectedColor),
            onTap: () => onSelect(colors[i]),
            size: swatchSize,
          ),
          if (i < colors.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _GrayscaleRow extends StatelessWidget {
  const _GrayscaleRow({
    required this.selectedColor,
    required this.onSelect,
    required this.swatchSize,
    required this.gap,
  });

  final Color? selectedColor;
  final ValueChanged<Color> onSelect;
  final double swatchSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final grays = BrandColorPalette.grayscaleRow;

    return Row(
      children: [
        _NoColorSwatch(
          size: swatchSize,
          onTap: () => onSelect(Colors.transparent),
        ),
        SizedBox(width: gap),
        for (var i = 0; i < grays.length; i++) ...[
          _ColorSwatch(
            color: grays[i],
            isSelected: _isSame(grays[i], selectedColor),
            onTap: () => onSelect(grays[i]),
            size: swatchSize,
          ),
          if (i < grays.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _SpectrumGrid extends StatelessWidget {
  const _SpectrumGrid({
    required this.colors,
    required this.selectedColor,
    required this.onSelect,
    required this.swatchSize,
    required this.gap,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onSelect;
  final double swatchSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < BrandColorPalette.rows; row++) ...[
          Row(
            children: [
              for (var col = 0; col < BrandColorPalette.columns; col++) ...[
                _ColorSwatch(
                  color: colors[row * BrandColorPalette.columns + col],
                  isSelected: _isSame(
                    colors[row * BrandColorPalette.columns + col],
                    selectedColor,
                  ),
                  onTap: () =>
                      onSelect(colors[row * BrandColorPalette.columns + col]),
                  size: swatchSize,
                ),
                if (col < BrandColorPalette.columns - 1) SizedBox(width: gap),
              ],
            ],
          ),
          if (row < BrandColorPalette.rows - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.size,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isSelected
                ? AppColors.onPrimary
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _NoColorSwatch extends StatelessWidget {
  const _NoColorSwatch({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: CustomPaint(
          painter: _NoColorStrikePainter(),
        ),
      ),
    );
  }
}

class _NoColorStrikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF3B30)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShowColorsButton extends StatelessWidget {
  const _ShowColorsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3A3A3C),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: const SizedBox(
          height: 28,
          child: Center(
            child: Text(
              'Show Colors...',
              style: TextStyle(
                color: Color(0xFFE5E5EA),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedColorSheet extends StatefulWidget {
  const _AdvancedColorSheet({this.initialColor});

  final Color? initialColor;

  @override
  State<_AdvancedColorSheet> createState() => _AdvancedColorSheetState();
}

class _AdvancedColorSheetState extends State<_AdvancedColorSheet> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor ?? AppColors.bleu_primaire);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.lg + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _hsv.toColor(),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SliderRow(
              label: 'Teinte',
              value: _hsv.hue,
              max: 360,
              onChanged: (value) => setState(() => _hsv = _hsv.withHue(value)),
            ),
            _SliderRow(
              label: 'Saturation',
              value: _hsv.saturation,
              max: 1,
              onChanged: (value) =>
                  setState(() => _hsv = _hsv.withSaturation(value)),
            ),
            _SliderRow(
              label: 'Luminosité',
              value: _hsv.value,
              max: 1,
              onChanged: (value) => setState(() => _hsv = _hsv.withValue(value)),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_hsv.toColor()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bleu_primaire,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text(
                  'Appliquer',
                  style: TextStyle(fontWeight: AppFontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(0, max),
              max: max,
              onChanged: onChanged,
              activeColor: AppColors.bleu_primaire,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isSame(Color a, Color? b) {
  if (b == null) return false;
  return a.toARGB32() == b.toARGB32();
}
