import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class NewtonSecondLawLab extends StatefulWidget {
  const NewtonSecondLawLab({super.key});

  @override
  State<NewtonSecondLawLab> createState() => _NewtonSecondLawLabState();
}

class _NewtonSecondLawLabState extends State<NewtonSecondLawLab> {
  static const double _gravity = 9.8;
  static const double _trackLength = 20.0;

  // Thông số người dùng điều chỉnh.
  double _force = 20.0;
  double _mass = 5.0;

  bool _frictionEnabled = false;
  double _frictionCoefficient = 0.15;

  // Thông số mô phỏng.
  double _time = 0.0;
  double _velocity = 0.0;
  double _distance = 0.0;

  bool _isRunning = false;

  Timer? _timer;
  DateTime? _lastTick;

  /// Lực ma sát: Fms = μmg.
  double get _frictionForce {
    if (!_frictionEnabled) {
      return 0.0;
    }

    return _frictionCoefficient * _mass * _gravity;
  }

  /// Hợp lực tác dụng lên xe.
  double get _netForce {
    if (!_frictionEnabled) {
      return _force;
    }

    // Xe đang đứng yên và lực kéo chưa thắng được ma sát.
    if (_velocity <= 0.001 && _force <= _frictionForce) {
      return 0.0;
    }

    return _force - _frictionForce;
  }

  /// Gia tốc: a = Fnet / m.
  double get _acceleration {
    final result = _netForce / _mass;

    // Không cho xe gia tốc ngược khi đã đứng yên.
    if (_velocity <= 0.001 && result < 0) {
      return 0.0;
    }

    return result;
  }

  void _startSimulation() {
    if (_isRunning) {
      return;
    }

    // Nếu xe đã đến cuối đường thì chạy lại từ đầu.
    if (_distance >= _trackLength) {
      _time = 0;
      _velocity = 0;
      _distance = 0;
    }

    setState(() {
      _isRunning = true;
      _lastTick = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) {
        return;
      }

      final now = DateTime.now();
      final previousTick = _lastTick ?? now;

      // Thời gian giữa hai khung hình.
      final dt = math.min(
        now.difference(previousTick).inMicroseconds / 1000000.0,
        0.05,
      );

      _lastTick = now;

      final oldVelocity = _velocity;

      // v = v0 + at.
      double newVelocity = oldVelocity + _acceleration * dt;

      if (newVelocity < 0) {
        newVelocity = 0;
      }

      // s = s0 + vận tốc trung bình × thời gian.
      double newDistance = _distance + ((oldVelocity + newVelocity) / 2) * dt;

      bool shouldStop = false;

      // Xe đi đến cuối đường.
      if (newDistance >= _trackLength) {
        newDistance = _trackLength;
        shouldStop = true;
      }

      // Lực kéo không thắng được ma sát.
      if (_frictionEnabled &&
          newVelocity <= 0.001 &&
          _force <= _frictionForce) {
        newVelocity = 0;
        shouldStop = true;
      }

      setState(() {
        _time += dt;
        _velocity = newVelocity;
        _distance = newDistance;
      });

      if (shouldStop) {
        _pauseSimulation();
      }
    });
  }

  void _pauseSimulation() {
    _timer?.cancel();
    _timer = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
      _lastTick = null;
    });
  }

  void _resetSimulation() {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _time = 0;
      _velocity = 0;
      _distance = 0;
      _isRunning = false;
      _lastTick = null;
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
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 950),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgDark.withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildFormulaBox(),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                // Hiển thị ngang trên Windows hoặc màn hình rộng.
                if (constraints.maxWidth >= 720) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildSimulationArea()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: _buildControlPanel()),
                    ],
                  );
                }

                // Hiển thị dọc trên Android hoặc màn hình nhỏ.
                return Column(
                  children: [
                    _buildSimulationArea(),
                    const SizedBox(height: 16),
                    _buildControlPanel(),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            _buildResultCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.science, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phòng thí nghiệm Định luật II Newton',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Thay đổi lực và khối lượng để quan sát gia tốc của xe.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.16),
            AppColors.accent.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.28)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            _frictionEnabled ? 'Fₙₑₜ = F − Fms = m × a' : 'F = m × a',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'a = ${_acceleration.toStringAsFixed(2)} m/s²',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationArea() {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.14), AppColors.bgDarker],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 26.0;

          final cartWidth = 80.0 + (_mass * 1.2);

          final availableWidth = math.max(
            0.0,
            constraints.maxWidth - cartWidth - horizontalPadding * 2,
          );

          final progress = (_distance / _trackLength).clamp(0.0, 1.0);

          final cartLeft = horizontalPadding + availableWidth * progress;

          final forceArrowLength = 70.0 + (_force / 100.0) * 110.0;

          final frictionArrowLength =
              55.0 +
              (_frictionForce / math.max(1.0, _force + _frictionForce)) * 90.0;

          return Stack(
            children: [
              // Trạng thái mô phỏng.
              Positioned(top: 16, right: 16, child: _buildStatusBadge()),

              // Mũi tên lực kéo.
              Positioned(
                top: 20,
                left: 20,
                child: _ForceArrow(
                  label: 'F = ${_force.toStringAsFixed(1)} N',
                  length: forceArrowLength,
                  color: AppColors.primary,
                  pointsRight: true,
                ),
              ),

              // Mũi tên ma sát.
              if (_frictionEnabled)
                Positioned(
                  top: 82,
                  left: 20,
                  child: _ForceArrow(
                    label: 'Fms = ${_frictionForce.toStringAsFixed(1)} N',
                    length: frictionArrowLength,
                    color: const Color(0xFFEF6C6C),
                    pointsRight: false,
                  ),
                ),

              // Thông tin vận tốc.
              Positioned(
                top: _frictionEnabled ? 145 : 92,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withOpacity(0.86),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    'v = ${_velocity.toStringAsFixed(2)} m/s',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Vạch đường.
              Positioned(
                left: 0,
                right: 0,
                bottom: 43,
                child: Container(
                  height: 7,
                  color: AppColors.primary.withOpacity(0.70),
                ),
              ),

              // Nền đường.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 44,
                  color: const Color(0xFF36363E),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(8, (index) {
                      return Container(
                        width: 36,
                        height: 3,
                        color: Colors.white.withOpacity(0.32),
                      );
                    }),
                  ),
                ),
              ),

              // Mốc quãng đường.
              Positioned(
                left: 18,
                bottom: 54,
                child: Text(
                  '0 m',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 54,
                child: Text(
                  '${_trackLength.toStringAsFixed(0)} m',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),

              // Xe chuyển động.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 16),
                curve: Curves.linear,
                left: cartLeft,
                bottom: 43,
                child: _CartWidget(
                  width: cartWidth,
                  mass: _mass,
                  velocity: _velocity,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge() {
    final Color statusColor;

    if (_isRunning) {
      statusColor = AppColors.success;
    } else if (_distance >= _trackLength) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.textMuted;
    }

    String statusText;

    if (_isRunning) {
      statusText = 'Đang chạy';
    } else if (_distance >= _trackLength) {
      statusText = 'Đã đến đích';
    } else {
      statusText = 'Đang dừng';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bảng điều khiển',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),

          _buildSlider(
            title: 'Lực tác dụng F',
            value: _force,
            min: 0,
            max: 100,
            divisions: 100,
            unit: 'N',
            onChanged: (value) {
              setState(() {
                _force = value;
              });
            },
          ),

          const SizedBox(height: 8),

          _buildSlider(
            title: 'Khối lượng m',
            value: _mass,
            min: 1,
            max: 20,
            divisions: 19,
            unit: 'kg',
            onChanged: (value) {
              setState(() {
                _mass = value;
              });
            },
          ),

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Bật lực ma sát',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'Fms = μ × m × g',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            value: _frictionEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _frictionEnabled = value;
              });
            },
          ),

          if (_frictionEnabled) ...[
            _buildSlider(
              title: 'Hệ số ma sát μ',
              value: _frictionCoefficient,
              min: 0.05,
              max: 0.50,
              divisions: 9,
              unit: '',
              decimalDigits: 2,
              onChanged: (value) {
                setState(() {
                  _frictionCoefficient = value;
                });
              },
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.28)),
              ),
              child: Text(
                'Fms = ${_frictionForce.toStringAsFixed(2)} N\n'
                'Fₙₑₜ = ${_netForce.toStringAsFixed(2)} N',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseSimulation : _startSimulation,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Tạm dừng' : 'Bắt đầu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              OutlinedButton.icon(
                onPressed: _resetSimulation,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Đặt lại'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMain,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  side: BorderSide(color: AppColors.glassBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
    int decimalDigits = 1,
  }) {
    final valueText = unit.isEmpty
        ? value.toStringAsFixed(decimalDigits)
        : '${value.toStringAsFixed(decimalDigits)} $unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultCards() {
    final results = <_ResultItem>[
      _ResultItem(
        label: 'Lực F',
        value: '${_force.toStringAsFixed(1)} N',
        icon: Icons.east,
      ),
      _ResultItem(
        label: 'Khối lượng m',
        value: '${_mass.toStringAsFixed(1)} kg',
        icon: Icons.scale,
      ),
      _ResultItem(
        label: 'Gia tốc a',
        value: '${_acceleration.toStringAsFixed(2)} m/s²',
        icon: Icons.speed,
      ),
      _ResultItem(
        label: 'Thời gian t',
        value: '${_time.toStringAsFixed(2)} s',
        icon: Icons.timer_outlined,
      ),
      _ResultItem(
        label: 'Vận tốc v',
        value: '${_velocity.toStringAsFixed(2)} m/s',
        icon: Icons.trending_up,
      ),
      _ResultItem(
        label: 'Quãng đường s',
        value: '${_distance.toStringAsFixed(2)} m',
        icon: Icons.straighten,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 760) {
          columns = 6;
        } else if (constraints.maxWidth >= 480) {
          columns = 3;
        } else {
          columns = 2;
        }

        const gap = 10.0;

        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: results.map((result) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  children: [
                    Icon(result.icon, size: 18, color: AppColors.primary),
                    const SizedBox(height: 5),
                    Text(
                      result.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ForceArrow extends StatelessWidget {
  final String label;
  final double length;
  final Color color;
  final bool pointsRight;

  const _ForceArrow({
    required this.label,
    required this.length,
    required this.color,
    required this.pointsRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Transform.rotate(
          angle: pointsRight ? 0 : math.pi,
          child: SizedBox(
            width: length,
            height: 25,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(Icons.arrow_right_alt, color: color),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartWidget extends StatelessWidget {
  final double mass;
  final double width;
  final double velocity;

  const _CartWidget({
    required this.mass,
    required this.width,
    required this.velocity,
  });

  @override
  Widget build(BuildContext context) {
    final speedLineCount = math.min(4, 1 + velocity ~/ 6);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (velocity > 0.5)
          Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 24),
            child: Column(
              children: List.generate(speedLineCount, (index) {
                return Container(
                  width: 12.0 + index * 5,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 4),
                  color: AppColors.primary.withOpacity(0.30),
                );
              }),
            ),
          ),
        SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: 50 + mass * 0.35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.24),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '${mass.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [_Wheel(), _Wheel()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: const Color(0xFF303038),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textMuted, width: 3),
      ),
    );
  }
}

class _ResultItem {
  final String label;
  final String value;
  final IconData icon;

  const _ResultItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
