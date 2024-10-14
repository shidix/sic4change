import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

//--------------------------------------------------------------
//                       DIAGRAM VALUES
//--------------------------------------------------------------
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

Widget pieDiagram(List<DiagramValues> diagList) {
  return Row(
    children: [
      SizedBox(
          width: 200,
          height: 200,
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
            sections: showingSections(diagList),
          ))),
      Container(
        width: 200,
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

List<PieChartSectionData> showingSections(List diagList) {
  List<PieChartSectionData> pList = [];
  for (DiagramValues dv in diagList) {
    PieChartSectionData section = PieChartSectionData(
      color: dv.color,
      value: double.parse(dv.percent),
      title: '${dv.percent}%',
      //radius: radius,
      titleStyle: const TextStyle(
        //fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
    pList.add(section);
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
          titleStyle: TextStyle(
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
          titleStyle: TextStyle(
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
          titleStyle: TextStyle(
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
          titleStyle: TextStyle(
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
