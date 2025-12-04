import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'dart:developer' as dev;

//--------------------------------------------------------------
//                       DIAGRAM VALUES
//--------------------------------------------------------------
List diagramColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.lime,
  Colors.brown,
  Colors.cyan,
  Colors.amber,
  Colors.yellow,
  Colors.indigo,
  Colors.pink
];

class DiagramValues {
  String text;
  String percent;
  Color color;

  DiagramValues(this.text, this.percent, this.color);

  DiagramValues.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        percent = json['percent'],
        color = json['color'];

  Map<String, dynamic> toJson() => {
        'text': text,
        'percent': percent,
        'color': color,
      };
}

class DiagramValues2 {
  String text;
  double value;
  double value2;
  Color color;

  DiagramValues2(this.text, this.value, this.value2, this.color);

  DiagramValues2.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        value = json['value'],
        value2 = json['value2'],
        color = json['color'];

  Map<String, dynamic> toJson() => {
        'text': text,
        'value': value,
        'value2': value2,
        'color': color,
      };
}

/*
          PIE DIAGRAM
*/
Widget pieDiagram(context, List<DiagramValues> diagList, {percent = true}) {
  double totalSum = 0;
  for (DiagramValues dv in diagList) {
    try {
      totalSum = totalSum + double.parse(dv.percent);
    } catch (e) {
      // ignore exception
    }
  }
  if (totalSum == 0) {
    return const Center(child: Text("No data"));
  }

  return Row(
    children: [
      Container(
          width: MediaQuery.of(context).size.width * 0.20,
          height: 200,
          padding: const EdgeInsets.only(top: 20),
          child: PieChart(PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                /*setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });*/
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            //show values in percent
            sections: showingSections(diagList, percent: percent),
          ))),
      Container(
        width: MediaQuery.of(context).size.width * 0.12,
        height: 200,
        padding: const EdgeInsets.only(top: 100),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: diagList.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  Container(
                    height: 10.0,
                    width: 10.0,
                    color: diagList[index].color,
                  ),
                  customText(diagList[index].text, 14)
                ],
              );
            }),
      )
    ],
  );
}

List<PieChartSectionData> showingSections(List diagList, {percent = true}) {
  List<PieChartSectionData> pList = [];

  for (DiagramValues dv in diagList) {
    try {
      PieChartSectionData section = PieChartSectionData(
        color: dv.color,
        value: double.parse(dv.percent),
        title: (percent) ? '${dv.percent}%' : dv.percent,
        //radius: radius,
        titleStyle: const TextStyle(
          //fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
      pList.add(section);
    } catch (e) {
      // dev.log(e.toString());
    }
  }

  return pList;
}

//List<PieChartSectionData> showingSections(int touchedIndex) {
List<PieChartSectionData> showingSections1() {
  //print(touchedIndex);
  return List.generate(4, (i) {
    /*final isTouched = i == touchedIndex;
    final fontSize = isTouched ? 25.0 : 16.0;
    final radius = isTouched ? 60.0 : 50.0;*/
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: Colors.blue,
          value: 40,
          title: '40%',
          //radius: radius,
          titleStyle: const TextStyle(
            //fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            shadows: shadows,
          ),
        );
      case 1:
        return PieChartSectionData(
          color: Colors.yellow,
          value: 30,
          title: '30%',
          //radius: radius,
          titleStyle: const TextStyle(
            //fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            shadows: shadows,
          ),
        );
      case 2:
        return PieChartSectionData(
          color: Colors.purple,
          value: 15,
          title: '15%',
          //radius: radius,
          titleStyle: const TextStyle(
            //fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            shadows: shadows,
          ),
        );
      case 3:
        return PieChartSectionData(
          color: Colors.green,
          value: 15,
          title: '15%',
          //radius: radius,
          titleStyle: const TextStyle(
            //fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            shadows: shadows,
          ),
        );
      default:
        throw Error();
    }
  });
}

/*
          BAR DIAGRAM
*/
List btText = [];
Widget barDiagram(List<DiagramValues2> diagList) {
  const double barsSpace = 60;
  const double barsWidth = 20;
  diagList.sort((a, b) => a.text.compareTo(b.text));
  for (DiagramValues2 dv in diagList) {
    btText.add(dv.text);
  }
  return BarChart(BarChartData(
      alignment: BarChartAlignment.center,
      titlesData: const FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: bottomTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: leftTitles,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % 10 == 0,
        getDrawingHorizontalLine: (value) => const FlLine(
          //color: AppColors.borderColor.withOpacity(0.1),
          //strokeWidth: 1,
          color: Colors.grey,
          strokeWidth: 1,
        ),
        drawVerticalLine: false,
      ),
      barTouchData: BarTouchData(
        enabled: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      groupsSpace: barsSpace,
      barGroups: getData(barsWidth, barsSpace, diagList)));
}

Widget bottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(fontSize: 10);
  String text;
  switch (value.toInt()) {
    case 0:
      //text = 'Indicador 1';
      text = (btText.isNotEmpty) ? btText[0] : "";
      break;
    case 1:
      text = (btText.length > 1) ? btText[1] : "";
      break;
    case 2:
      text = (btText.length > 2) ? btText[2] : "";
      break;
    case 3:
      text = (btText.length > 3) ? btText[3] : "";
      break;
    case 4:
      text = (btText.length > 4) ? btText[4] : "";
      break;
    case 5:
      text = (btText.length > 5) ? btText[5] : "";
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text, style: style),
  );
}

Widget leftTitles(double value, TitleMeta meta) {
  if (value == meta.max) {
    return Container();
  }
  const style = TextStyle(
    fontSize: 10,
  );
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      meta.formattedValue,
      style: style,
    ),
  );
}

List<BarChartGroupData> getData(
    double barsWidth, double barsSpace, List<DiagramValues2> diagList) {
  List<BarChartGroupData> datas = [];
  int i = 0;
  for (DiagramValues2 dv in diagList) {
    BarChartGroupData bcgd = BarChartGroupData(
      x: i,
      barsSpace: barsSpace,
      barRods: [
        BarChartRodData(
          toY: dv.value,
          rodStackItems: [
            BarChartRodStackItem(0, dv.value2, Colors.blue),
            BarChartRodStackItem(dv.value2, dv.value, Colors.grey),
          ],
          borderRadius: BorderRadius.zero,
          width: barsWidth,
        ),
      ],
    );
    datas.add(bcgd);
    i = i + 1;
  }
  return datas;
}
