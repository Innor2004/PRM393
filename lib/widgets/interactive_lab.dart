import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

enum FormulaType {
  uniformMotion,
  acceleratedMotion,
  newtonSecondLaw,
  workFormula,
}

class InteractiveLab extends StatefulWidget {
  final FormulaType formulaType;
  const InteractiveLab({super.key, required this.formulaType});

  @override
  State<InteractiveLab> createState() => _InteractiveLabState();
}

class _InteractiveLabState extends State<InteractiveLab> {
  double _v = 10;
  double _t = 5;
  double _v0 = 5;
  double _a = 2;
  double _m = 2;
  double _force = 20;
  double _s = 10;
  double _angle = 0;

  double get _uniformDistance => _v * _t;
  double get _finalVelocity => _v0 + _a * _t;
  double get _displacement => _v0 * _t + 0.5 * _a * _t * _t;
  double get _forceResult => _m * _a;
  double get _workResult => _force * _s * math.cos(_angle * math.pi / 180);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border(
          top: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [
                    AppColors.accent,
                    Color(0xFF06B6D4),
                  ]),
                ),
                child: const Icon(Icons.science,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Phòng thí nghiệm ảo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Thay đổi thông số để xem kết quả trực quan',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _buildFormulaDisplay(),
          const SizedBox(height: 20),
          ..._buildSliders(),
        ],
      ),
    );
  }

  Widget _buildFormulaDisplay() {
    String formula = '';
    String result = '';
    String unit = '';

    switch (widget.formulaType) {
      case FormulaType.uniformMotion:
        formula = 's = v \u00D7 t';
        result = _uniformDistance.toStringAsFixed(1);
        unit = 'm';
        break;
      case FormulaType.acceleratedMotion:
        formula = 'v = v\u2080 + a \u00D7 t';
        result = _finalVelocity.toStringAsFixed(1);
        unit = 'm/s';
        break;
      case FormulaType.newtonSecondLaw:
        formula = 'F = m \u00D7 a';
        result = _forceResult.toStringAsFixed(1);
        unit = 'N';
        break;
      case FormulaType.workFormula:
        formula = 'A = F \u00D7 s \u00D7 cos(\u03B1)';
        result = _workResult.toStringAsFixed(1);
        unit = 'J';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryGlow.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(formula,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: AppColors.textMain)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Kết quả: ',
                  style: TextStyle(
                      fontSize: 16, color: AppColors.textMuted)),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.gradientAccent.createShader(bounds),
                child: Text('$result ',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
              Text(unit,
                  style: TextStyle(
                      fontSize: 16, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSliders() {
    switch (widget.formulaType) {
      case FormulaType.uniformMotion:
        return [
          _buildSlider('V\u1EADn t\u1ED1c v (m/s)', _v, 1, 50, (v) => _v = v),
          _buildSlider('Th\u1EDDi gian t (s)', _t, 1, 30, (t) => _t = t),
          _buildResultRow('Quãng \u0111\u01B0\u1EDDng s',
              _uniformDistance, 'm'),
        ];
      case FormulaType.acceleratedMotion:
        return [
          _buildSlider(
              'V\u1EADn t\u1ED1c \u0111\u1EA7u v\u2080 (m/s)', _v0, 0, 30, (v) => _v0 = v),
          _buildSlider(
              'Gia t\u1ED1c a (m/s\u00B2)', _a, -5, 10, (a) => _a = a),
          _buildSlider(
              'Th\u1EDDi gian t (s)', _t, 1, 30, (t) => _t = t),
          _buildResultRow(
              'V\u1EADn t\u1ED1c cu\u1ED1i v', _finalVelocity, 'm/s'),
          _buildResultRow(
              'Quãng \u0111\u01B0\u1EDDng s', _displacement, 'm'),
        ];
      case FormulaType.newtonSecondLaw:
        return [
          _buildSlider(
              'Kh\u1ED1i l\u01B0\u1EE3ng m (kg)', _m, 0.5, 100, (m) => _m = m),
          _buildSlider(
              'Gia t\u1ED1c a (m/s\u00B2)', _a, 0.1, 20, (a) => _a = a),
          _buildResultRow('L\u1EF1c F', _forceResult, 'N'),
        ];
      case FormulaType.workFormula:
        return [
          _buildSlider('L\u1EF1c F (N)', _force, 1, 100, (f) => _force = f),
          _buildSlider(
              'Quãng \u0111\u01B0\u1EDDng s (m)', _s, 1, 50, (s) => _s = s),
          _buildSlider(
              'Góc \u03B1 (\u0111\u1ED9)', _angle, 0, 180, (a) => _angle = a),
          _buildResultRow('Công A', _workResult, 'J'),
        ];
    }
  }

  Widget _buildSlider(String label, double value, double min,
      double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
              Text(value.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textMain)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.glassBorder,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: ((max - min) / 0.5).round(),
              onChanged: (v) => setState(() => onChanged(v)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain)),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.gradientAccent.createShader(bounds),
            child: Text('${value.toStringAsFixed(2)} $unit',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
