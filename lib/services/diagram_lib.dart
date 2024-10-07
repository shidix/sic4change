import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget pieDiagram(List<KeyValue> diagList) {
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
            sections: showingSections(),
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
                    color: Colors.blue,
                  ),
                  customText(diagList[index].value, 14)
                ],
              );
            }),
      )
    ],
  );
}

//List<PieChartSectionData> showingSections(int touchedIndex) {
List<PieChartSectionData> showingSections() {
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
