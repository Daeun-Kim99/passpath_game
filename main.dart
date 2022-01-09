import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); //메인페이지 연결
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PassPath', home: MyGamePage(),
    );
  }
}

class MyGamePage extends StatefulWidget {
  const MyGamePage({Key? key}) : super(key: key);

  @override
  _MyGamePageState createState() => _MyGamePageState();
}

double deviceWidth = 0;
double deviceHeight = 0;

class _MyGamePageState extends State<MyGamePage> {
  @override
  Widget build(BuildContext context) {
    deviceWidth = 400*(MediaQuery.of(context).size.width/500);
    deviceHeight = 400*(MediaQuery.of(context).size.height/800);
    return Scaffold(
        //appBar: AppBar(),
        body: Center(
          child: Container(
            width: deviceWidth, height: deviceHeight,//Canvas크기 정하기
            child: CustomPaint(painter: GameStage(),),
          ),
        ),
        bottomNavigationBar: const BottomAppBar(),
    );
  }
}

double _column = 4, _row = 4; //행과 열 개수
List xList = [], yList = [];

class GameStage extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    try {
      var myPaint = Paint();
      myPaint.color = Colors.black; //사각형 색? 테두리는 어케 바꾸는지 아직 몰으겠어연
      myPaint.style = PaintingStyle.stroke;
      myPaint.strokeWidth = 2;
      double X = 0, Y = 0; //사각형의 좌표
      double width = deviceWidth / _column; //canvas크기에 열 개수만큼 나눠서 박스 크기구하기
      double height = deviceHeight / _row;
      for (int i = 0; i < _row; i++) { //행
        for (int j = 0; j < _column; j++) { //열
          canvas.drawRect(Offset(X, Y) & Size(width, height), myPaint); //사각형 그리기
          xList.add(X);
          yList.add(Y);
          X += width; //2열에 사각형 그리기
        }
        Y += height ; //2행에 사각형 그리기
        X = 0; //2행으로 넘어갔을때 x좌표 초기화
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
