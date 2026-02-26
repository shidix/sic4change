import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSeriesLineChart extends StatelessWidget {
  const TimeSeriesLineChart({
    super.key,
    required this.series,
    this.isInteger = false, // por si quieres formatear el eje Y sin decimales
  });

  /// Datos: (fecha, valor)
  final List<MapEntry<DateTime, double>> series;
  final bool isInteger;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }

    // Ordena por fecha por seguridad
    final data = [...series]..sort((a, b) => a.key.compareTo(b.key));

    final spots = data
        .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
        .toList();

    final minX = spots.first.x;
    final maxX = spots.last.x;

    final ys = spots.map((s) => s.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    final xInterval = _niceTimeIntervalMs(minX, maxX);

    final dfAxis = DateFormat('dd/MM/yyyy');       // etiquetas eje X
    final dfTooltip = DateFormat('dd/MM/yyyy'); // tooltip

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,

          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: xInterval,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dfAxis.format(dt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  // Ajusta formato a tu gusto
                  return Text(
                    isInteger ? value.toStringAsFixed(0) : value.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ),
          ),

          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.blueAccent.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((ts) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(ts.x.toInt());
                  return LineTooltipItem(
                    '${dfTooltip.format(dt)}\n${isInteger ? ts.y.toStringAsFixed(0) : ts.y.toStringAsFixed(2)}',
                    Theme.of(context).textTheme.bodySmall!,
                  );
                }).toList();
              },
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,

              dashArray: [8, 6],

              dotData: const FlDotData(show: true),

              barWidth: 3,
              isCurved: false,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  /// Elige un intervalo “bonito” para no saturar el eje X.
  /// Devuelve milisegundos.
  double _niceTimeIntervalMs(double minX, double maxX) {
    final rangeMs = (maxX - minX).abs();
    const minute = 60 * 1000.0;
    const hour = 60 * minute;
    const day = 24 * hour;

    if (rangeMs <= 2 * hour) return 15 * minute;   // cada 15 min
    if (rangeMs <= 12 * hour) return hour;         // cada 1h
    if (rangeMs <= 7 * day) return day;            // cada 1 día
    if (rangeMs <= 30 * day) return 7 * day;       // cada 1 semana
    return 30 * day;                               // cada ~mes
  }
}