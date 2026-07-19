import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

enum CelestialBody {
  earth('Trái Đất', '🌍', 9.8),
  moon('Mặt Trăng', '🌙', 1.62),
  mars('Sao Hỏa', '🔴', 3.72),
  jupiter('Sao Mộc', '🟠', 24.79),
  sun('Mặt Trời', '☀️', 274.0);

  final String label;
  final String emoji;
  final double g;
  const CelestialBody(this.label, this.emoji, this.g);
}

enum FormulaType {
  uniformMotion,
  acceleratedMotion,
  newtonSecondLaw,
  workFormula,
  freeFall,
  energyConversion,
  momentOfForce,
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

  // Free fall state
  CelestialBody _selectedBody = CelestialBody.earth;
  double _height = 50;
  double _time = 0;
  bool _isRunning = false;
  bool _isFinished = false;
  Timer? _timer;

  // Energy conversion state
  double _totalEnergy = 500;
  final double _mass = 1;

  // Moment of force state
  double _fulcrum = 3.0;

  double get _uniformDistance => _v * _t;
  double get _finalVelocity => _v0 + _a * _t;
  double get _displacement => _v0 * _t + 0.5 * _a * _t * _t;
  double get _forceResult => _m * _a;
  double get _workResult => _force * _s * math.cos(_angle * math.pi / 180);

  // Free fall computed
  double get _currentHeight => math.max(0, _height - 0.5 * _selectedBody.g * _time * _time);
  double get _currentVelocity => _selectedBody.g * _time;
  double get _fallTime => math.sqrt(2 * _height / _selectedBody.g);

  // Energy conversion computed
  double get _energyHeight => _totalEnergy / (_mass * 9.8);

  // Moment of force computed
  static const double _seesawLength = 16.0;
  static const double _totalMass = 20.0;
  double get _d1 => _fulcrum;
  double get _d2 => _seesawLength - _fulcrum;
  double get _balancedM1 => _totalMass * _d2 / _seesawLength;
  double get _balancedM2 => _totalMass * _d1 / _seesawLength;
  double get _moment1 => _balancedM1 * 9.8 * _d1;
  double get _moment2 => _balancedM2 * 9.8 * _d2;
  double get _tiltAngle => (_moment1 - _moment2) / 200;
  double get _energyPotential => _mass * 9.8 * _currentHeight;
  double get _energyKinetic => _totalEnergy - _energyPotential;
  double get _energyNormalized => _energyHeight > 0 ? (_currentHeight / _energyHeight).clamp(0, 1) : 0;

  void _startDrop() {
    _reset();
    if (widget.formulaType == FormulaType.energyConversion) {
      _height = _energyHeight;
      _selectedBody = CelestialBody.earth;
    }
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _time += 0.016;
        if (_currentHeight <= 0) {
          _time = _fallTime;
          timer.cancel();
          _isRunning = false;
          _isFinished = true;
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _time = 0;
      _isRunning = false;
      _isFinished = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
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
          _buildHeader(),
          const SizedBox(height: 4),
          Text(_buildSubtitle(),
              style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          if (widget.formulaType == FormulaType.freeFall)
            ..._buildFreeFallContent()
          else if (widget.formulaType == FormulaType.energyConversion)
            ..._buildEnergyContent()
          else if (widget.formulaType == FormulaType.momentOfForce)
            ..._buildSeesawContent()
          else ...[
            _buildFormulaDisplay(),
            const SizedBox(height: 20),
            ..._buildSliders(),
          ],
        ],
      ),
      ),
    );
  }

  String _buildSubtitle() {
    switch (widget.formulaType) {
      case FormulaType.freeFall:
        return 'Mô phỏng vật rơi tự do - Chọn hành tinh và thả bóng';
      case FormulaType.energyConversion:
        return 'Chuyển hóa giữa động năng và thế năng - Điều chỉnh tổng năng lượng';
      case FormulaType.momentOfForce:
        return 'Cân bằng mô men lực - Điều chỉnh điểm tựa và khối lượng';
      default:
        return 'Thay đổi thông số để xem kết quả trực quan';
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(colors: [
              AppColors.accent,
              Color(0xFF06B6D4),
            ]),
          ),
          child: const Icon(Icons.science,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text('Phòng thí nghiệm ảo',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain)),
      ],
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
      case FormulaType.freeFall:
        formula = 'h = \u00BD \u00D7 g \u00D7 t\u00B2';
        result = _isFinished ? _fallTime.toStringAsFixed(1) : _time.toStringAsFixed(1);
        unit = 's';
        break;
      case FormulaType.energyConversion:
        formula = 'E = W\u2091 + W\u0111 = const';
        result = _totalEnergy.toStringAsFixed(0);
        unit = 'J';
        break;
      case FormulaType.momentOfForce:
        formula = 'M = F \u00D7 d';
        result = 'M\u2081=${_moment1.toStringAsFixed(0)} M\u2082=${_moment2.toStringAsFixed(0)}';
        unit = '';
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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: AppColors.textMain)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Kết quả: ',
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
      case FormulaType.freeFall:
        return [];
      case FormulaType.energyConversion:
        return [];
      case FormulaType.momentOfForce:
        return [];
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
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
              Text(value.toStringAsFixed(1),
                  style: TextStyle(
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
              onChanged: (v) => setState(() => onChanged(v)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFreeFallContent() {
    final normalized = _height > 0 ? _currentHeight / _height : 0.0;
    return [
      _buildPlanetSelector(),
      const SizedBox(height: 16),
      Tooltip(
        message:
            '${_selectedBody.emoji} ${_selectedBody.label} — g = ${_selectedBody.g} m/s²',
        preferBelow: true,
        child: SizedBox(
        width: double.infinity,
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _FreeFallPainter(
              normalizedHeight: normalized,
              emoji: _selectedBody.emoji,
              heightLabel: '${_currentHeight.toStringAsFixed(1)} m',
            ),
          ),
        ),
      ),
      ),
      const SizedBox(height: 10),
      _buildFreeFallValues(),
      const SizedBox(height: 10),
      _buildSlider('Độ cao ban đầu h (m)', _height, 5, 200, (v) {
        _reset();
        _height = v;
      }),
      const SizedBox(height: 8),
      Center(child: _buildActionButton()),
    ];
  }

  List<Widget> _buildEnergyContent() {
    final normalized = _energyNormalized;
    final potRatio = _totalEnergy > 0 ? (_energyPotential / _totalEnergy).clamp(0.0, 1.0) : 1.0;
    final kinRatio = 1.0 - potRatio;
    return [
      SizedBox(
        width: double.infinity,
        height: 240,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _EnergyBarPainter(
              normalizedHeight: normalized,
              potentialRatio: potRatio,
              kineticRatio: kinRatio,
              heightLabel: '${_currentHeight.toStringAsFixed(1)} m',
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      _buildEnergyValues(),
      const SizedBox(height: 10),
      _buildSlider('Tổng cơ năng E (J)', _totalEnergy, 100, 2000, (v) {
        _totalEnergy = v;
        _reset();
      }),
      const SizedBox(height: 8),
      Center(child: _buildActionButton()),
    ];
  }

  Widget _buildEnergyValues() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildValueItem('Wt', '${_energyPotential.toStringAsFixed(0)} J',
              color: const Color(0xFF4ADE80)),
          _buildValueItem('Wđ', '${_energyKinetic.toStringAsFixed(0)} J',
              color: const Color(0xFFFB7185)),
          _buildValueItem('E', '${_totalEnergy.toStringAsFixed(0)} J',
              color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildValueItem(String symbol, String value, {Color? color}) {
    return Column(
      children: [
        Text(symbol,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        ShaderMask(
          shaderCallback: (bounds) =>
              (color != null ? LinearGradient(colors: [color, color]) : AppColors.gradientAccent)
                  .createShader(bounds),
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      ],
    );
  }

  List<Widget> _buildSeesawContent() {
    return [
      SizedBox(
        width: double.infinity,
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _SeesawPainter(
              fulcrum: _fulcrum,
              seesawLength: _seesawLength,
              tiltAngle: _tiltAngle,
              m1: _balancedM1,
              m2: _balancedM2,
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      _buildSeesawValues(),
      const SizedBox(height: 10),
      _buildSlider('Vị trí điểm tựa (m)', _fulcrum, 0.1, 15.9, (v) {
        _fulcrum = v;
      }),
    ];
  }

  Widget _buildSeesawValues() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildValueItem('m\u2081', '${_balancedM1.toStringAsFixed(1)} kg',
              color: const Color(0xFF60A5FA)),
          Text('L = ${_seesawLength.toStringAsFixed(0)}m',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain)),
          _buildValueItem('m\u2082', '${_balancedM2.toStringAsFixed(1)} kg',
              color: const Color(0xFFFB7185)),
        ],
      ),
    );
  }

  Widget _buildPlanetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: CelestialBody.values.map((body) {
              final selected = _selectedBody == body;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: 'g = ${body.g} m/s²',
                  preferBelow: false,
                  child: GestureDetector(
                    onTap: _isRunning
                        ? null
                        : () {
                            _reset();
                            setState(() => _selectedBody = body);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.glassFill,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.glassBorder,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: Text(body.emoji,
                        style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedBody.emoji} ${_selectedBody.label} — g = ${_selectedBody.g} m/s²',
          style: TextStyle(
              fontSize: 13,
              color: AppColors.textMain,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFreeFallValues() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildValueItem('t', '${_time.toStringAsFixed(2)} s'),
          _buildValueItem('v', '${_currentVelocity.toStringAsFixed(2)} m/s'),
          _buildValueItem('h', '${_currentHeight.toStringAsFixed(2)} m'),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    String label;
    VoidCallback? onPressed;

    if (_isFinished) {
      label = 'Thả lại';
      onPressed = _reset;
    } else if (_isRunning) {
      label = 'Đang rơi...';
    } else {
      label = 'Thả bóng';
      onPressed = _startDrop;
    }

    final isActive = onPressed != null;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isActive
            ? AppColors.gradientPrimary
            : LinearGradient(colors: [
                AppColors.textMuted.withValues(alpha: 0.3),
                AppColors.textMuted.withValues(alpha: 0.2),
              ]),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 28),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white)),
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
              style: TextStyle(
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

class _FreeFallPainter extends CustomPainter {
  final double normalizedHeight;
  final String emoji;
  final String heightLabel;

  _FreeFallPainter({
    required this.normalizedHeight,
    required this.emoji,
    required this.heightLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 24.0;
    final groundY = size.height - padding;
    final topY = padding;
    final usableH = groundY - topY;
    final ballY = groundY - normalizedHeight * usableH;
    final centerX = size.width / 2;

    // Sky gradient background
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1a1a3e), Color(0xFF2d2d5e)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Ground
    final groundPaint = Paint()..color = const Color(0xFF1B4332);
    canvas.drawRect(
        Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
        groundPaint);

    // Grass line
    final grassPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), grassPaint);

    // Height reference line at top
    final refPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX - 40, topY), Offset(centerX + 40, topY), refPaint);

    // Ball shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(centerX + 2, ballY + 2), 18, shadowPaint);

    // Ball glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(centerX, ballY), 24, glowPaint);

    // Ball
    final ballPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE0E7FF), Color(0xFF6366F1)],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, ballY),
        radius: 18,
      ));
    canvas.drawCircle(Offset(centerX, ballY), 18, ballPaint);

    // Emoji
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 20)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(centerX - tp.width / 2, ballY - tp.height / 2));

    // Height label on the left
    final labelTP = TextPainter(
      text: TextSpan(
        text: heightLabel,
        style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTP.paint(canvas, Offset(8, ballY - labelTP.height / 2));
  }

  @override
  bool shouldRepaint(covariant _FreeFallPainter oldDelegate) =>
      oldDelegate.normalizedHeight != normalizedHeight;
}

class _EnergyBarPainter extends CustomPainter {
  final double normalizedHeight;
  final double potentialRatio;
  final double kineticRatio;
  final String heightLabel;

  _EnergyBarPainter({
    required this.normalizedHeight,
    required this.potentialRatio,
    required this.kineticRatio,
    required this.heightLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 24.0;
    final groundY = size.height - padding;
    final topY = padding;
    final usableH = groundY - topY;
    final ballY = groundY - normalizedHeight * usableH;
    final centerX = size.width * 0.5;
    final barRight = size.width - 4.0;
    final barLeft = barRight - 20;
    final barHeight = usableH;

    // Sky background
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1a1a3e), Color(0xFF2d2d5e)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Ground
    final groundPaint = Paint()..color = const Color(0xFF1B4332);
    canvas.drawRect(
        Rect.fromLTWH(0, groundY, size.width, size.height - groundY), groundPaint);

    // Grass line
    final grassPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), grassPaint);

    // Ball shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(centerX + 2, ballY + 2), 18, shadowPaint);

    // Ball glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(centerX, ballY), 24, glowPaint);

    // Ball
    final ballPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE0E7FF), Color(0xFF6366F1)],
      ).createShader(Rect.fromCircle(center: Offset(centerX, ballY), radius: 18));
    canvas.drawCircle(Offset(centerX, ballY), 18, ballPaint);

    // Energy bar background
    final barBgPaint = Paint()..color = AppColors.bgDark.withValues(alpha: 0.6);
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft, topY, barRight - barLeft, barHeight),
      const Radius.circular(10),
    );
    canvas.drawRRect(barRect, barBgPaint);

    // Kinetic energy bar (bottom, red)
    if (kineticRatio > 0) {
      final kinHeight = barHeight * kineticRatio;
      final kinPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFB7185), const Color(0xFFE11D48)],
        ).createShader(Rect.fromLTWH(barLeft, groundY - kinHeight, barRight - barLeft, kinHeight));
      final kinRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, groundY - kinHeight, barRight - barLeft, kinHeight),
        const Radius.circular(0),
      );
      canvas.drawRRect(kinRect, kinPaint);
    }

    // Potential energy bar (top, green)
    if (potentialRatio > 0) {
      final potHeight = barHeight * potentialRatio;
      final potPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF4ADE80), const Color(0xFF16A34A)],
        ).createShader(Rect.fromLTWH(barLeft, topY, barRight - barLeft, potHeight));
      final potRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, topY, barRight - barLeft, potHeight),
        const Radius.circular(10),
      );
      canvas.drawRRect(potRect, potPaint);
    }

    // Bar border
    final barBorderPaint = Paint()
      ..color = AppColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(barRect, barBorderPaint);

    // Divider between Wt and Wđ
    final divY = groundY - barHeight * kineticRatio;
    if (potentialRatio > 0 && kineticRatio > 0) {
      final divPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(barLeft, divY), Offset(barRight, divY), divPaint);
    }

    // Label "Wt" at top of bar
    final wtLabel = TextPainter(
      text: TextSpan(
        text: 'Wt',
        style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF4ADE80),
            fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    wtLabel.paint(canvas, Offset(barLeft, topY - 16));

    // Label "Wđ" at bottom of bar
    final wdLabel = TextPainter(
      text: TextSpan(
        text: 'Wđ',
        style: TextStyle(
            fontSize: 11,
            color: const Color(0xFFFB7185),
            fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    wdLabel.paint(canvas, Offset(barLeft, groundY + 4));

    // Height label
    final hLabel = TextPainter(
      text: TextSpan(
        text: heightLabel,
        style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hLabel.paint(canvas, Offset(barLeft - 4 - hLabel.width, ballY - hLabel.height / 2));
  }

  @override
  bool shouldRepaint(covariant _EnergyBarPainter oldDelegate) =>
      oldDelegate.normalizedHeight != normalizedHeight ||
      oldDelegate.potentialRatio != potentialRatio;
}

class _SeesawPainter extends CustomPainter {
  final double fulcrum;
  final double seesawLength;
  final double tiltAngle;
  final double m1;
  final double m2;

  _SeesawPainter({
    required this.fulcrum,
    required this.seesawLength,
    required this.tiltAngle,
    required this.m1,
    required this.m2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 24.0;
    final beamY = size.height - padding;
    final left = padding;
    final right = size.width - padding;
    final beamWidth = right - left;

    // Background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1a1a3e), Color(0xFF2d2d5e)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Scale: map seesaw length to pixel width
    final scale = beamWidth / seesawLength;
    final pivotX = left + fulcrum * scale;
    final pivotY = beamY;

    // Draw ground
    final groundPaint = Paint()..color = const Color(0xFF1B4332);
    canvas.drawRect(
        Rect.fromLTWH(0, beamY + 20, size.width, size.height - beamY - 20),
        groundPaint);

    // Draw fulcrum triangle
    final fulcrumPaint = Paint()..color = const Color(0xFF94A3B8);
    final path = Path()
      ..moveTo(pivotX - 10, pivotY + 2)
      ..lineTo(pivotX, pivotY + 20)
      ..lineTo(pivotX + 10, pivotY + 2)
      ..close();
    canvas.drawPath(path, fulcrumPaint);

    final d1 = fulcrum;
    final d2 = seesawLength - fulcrum;

    // Save and rotate around fulcrum
    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(tiltAngle);

    // Beam
    final beamPaint = Paint()
      ..color = const Color(0xFFD4A574)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-d1 * scale, 0), Offset(d2 * scale, 0), beamPaint);

    // Mass blocks
    final blockSize = 16.0;
    final m1RelY = -blockSize / 2 - 4;
    final m2RelY = -blockSize / 2 - 4;

    // Left mass (blue)
    final m1Paint = Paint()..color = const Color(0xFF3B82F6);
    final m1Size = 8.0 + (m1 / 20) * 28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-d1 * scale, m1RelY),
          width: m1Size,
          height: m1Size,
        ),
        const Radius.circular(3),
      ),
      m1Paint,
    );

    // Right mass (red)
    final m2Paint = Paint()..color = const Color(0xFFEF4444);
    final m2Size = 8.0 + (m2 / 20) * 28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(d2 * scale, m2RelY),
          width: m2Size,
          height: m2Size,
        ),
        const Radius.circular(3),
      ),
      m2Paint,
    );

    // Labels on masses
    final m1TP = TextPainter(
      text: TextSpan(
        text: 'm\u2081',
        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    m1TP.paint(canvas, Offset(-d1 * scale - m1TP.width / 2, m1RelY - m1TP.height - 2));

    final m2TP = TextPainter(
      text: TextSpan(
        text: 'm\u2082',
        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    m2TP.paint(canvas, Offset(d2 * scale - m2TP.width / 2, m2RelY - m2TP.height - 2));

    canvas.restore();

    // Distance labels (not rotated)
    final d1Label = TextPainter(
      text: TextSpan(
        text: 'd\u2081=${d1.toStringAsFixed(1)}m',
        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    d1Label.paint(canvas, Offset(left, pivotY + 24));

    final d2Label = TextPainter(
      text: TextSpan(
        text: 'd\u2082=${d2.toStringAsFixed(1)}m',
        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    d2Label.paint(canvas, Offset(right - d2Label.width, pivotY + 24));
  }

  @override
  bool shouldRepaint(covariant _SeesawPainter oldDelegate) =>
      oldDelegate.fulcrum != fulcrum ||
      oldDelegate.tiltAngle != tiltAngle ||
      oldDelegate.m1 != m1 ||
      oldDelegate.m2 != m2;
}

