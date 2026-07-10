import 'package:flutter/material.dart';

class LatexRenderer extends StatelessWidget {
  final String formula;
  final double fontSize;

  const LatexRenderer(this.formula, {super.key, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    final parsed = _parseFormula(formula);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: parsed,
        ),
      ),
    );
  }

  List<Widget> _parseFormula(String formula) {
    final widgets = <Widget>[];
    final buffer = StringBuffer();
    bool inSubscript = false;
    bool inSuperscript = false;

    for (int i = 0; i < formula.length; i++) {
      final char = formula[i];

      if (char == '_') {
        if (buffer.isNotEmpty) {
          widgets.add(_textWidget(buffer.toString()));
          buffer.clear();
        }
        inSubscript = true;
        continue;
      }

      if (char == '^') {
        if (buffer.isNotEmpty) {
          widgets.add(_textWidget(buffer.toString()));
          buffer.clear();
        }
        inSuperscript = true;
        continue;
      }

      if (inSubscript || inSuperscript) {
        final subBuffer = StringBuffer();
        while (i < formula.length && formula[i] != ' ') {
          subBuffer.write(formula[i]);
          i++;
        }
        i--;
        widgets.add(
          Text(
            subBuffer.toString(),
            style: TextStyle(
              fontSize: fontSize * 0.65,
              fontFamily: 'monospace',
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        );
        inSubscript = false;
        inSuperscript = false;
        continue;
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      widgets.add(_textWidget(buffer.toString()));
    }

    return widgets;
  }

  Widget _textWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple[700],
      ),
    );
  }
}

String? extractLatex(String text) {
  final regex = RegExp(r'`([^`]+)`');
  final match = regex.firstMatch(text);
  return match?.group(1);
}
