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
Offset touchedOffset = const Offset(0,0);
Offset startOffset = const Offset(0,0);
List <Offset> pathOffsets = <Offset> [];
int levelNum = 1;

class _MyGamePageState extends State<MyGamePage> {

  @override
  Widget build(BuildContext context) {
    deviceWidth = 400 * (MediaQuery
        .of(context)
        .size
        .width / 500); //작업공간의 크기 500*800 에서 400*400크기를 디바이스 크기에 맞춰 비율 설정
    deviceHeight = 400 * (MediaQuery
        .of(context)
        .size
        .height / 800);

    return Scaffold(
      body: Center(
        child: Container(margin: const EdgeInsets.fromLTRB(0, 50, 0, 50),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              /*Container( //배경 어케 넣나요
        child: Image.asset('/image/bg.jpg'),
        width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height,
      ),*/
              Container(
                width: deviceWidth, height: 50,
                color: Colors.lightBlueAccent.withOpacity(0.3),
                child: Row( mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container( width: deviceWidth*0.2, alignment: Alignment.centerLeft,
                        child: Row(
                            children: const <Widget>[
                              Icon(
                                Icons.pause, color: Colors.black, size: 20.0,
                              ),
                              Icon(
                                Icons.apps, color: Colors.black, size: 20.0,
                              ),
                            ]),
                      ),
                      Container( width: deviceWidth*0.5, alignment: Alignment.center,
                        child: Text('LEVEL $levelNum',
                          style: const TextStyle(fontSize: 30.0,),
                          textAlign: TextAlign.center,
                        ), //글씨체도 추가하기
                      ),
                      Container( width: deviceWidth*0.2, alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.replay, size: 20.0,
                        ),
                      ),
                    ]),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  //=Container?
                  //width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, //캔버스 크기
                  width: deviceWidth,
                  height: deviceHeight,
                  child: CustomPaint(painter: GameStagePainter(),
                      child: GestureDetector(
                          onTapDown: (details) {
                            /*final renderBox = context
                                .findRenderObject() as RenderBox;
                            final localPosition = renderBox.globalToLocal(
                                details.globalPosition);*/
                            setState(() {
                              touchedOffset = Offset((details.globalPosition.dx - 50) ~/
                                  stageWidth * stageWidth, (details.globalPosition.dy -
                                  170) ~/ stageHeight *
                                  stageHeight);  //비율 문제로 아래에 색칠되는 경우 있음
                              print('touchedOffset: $touchedOffset');
                            });
                          },
                          child: CustomPaint(
                            painter: TouchedRectPainter(),
                          )
                      )
                  )
              ),
            ],),
        ),
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}

//여기 넘 많은데 좀 줄일 수 있을까 고민해볼 것
double _stageColumn = 4, _stageRow = 4; //행과 열 개수
double stageX = 0, stageY = 0; //사각형의 좌표
double stageWidth = deviceWidth / _stageColumn; //캔버스크기에 열 개수만큼 나눠서 사각형 크기구하기
double stageHeight = deviceHeight / _stageRow;
List<Offset> stageOffsets = <Offset>[]; //스테이지 네모 좌표

class GameStagePainter extends CustomPainter { //기본 스테이지
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var rectBorderPaint = Paint();
    rectBorderPaint.color = Colors.black;
    rectBorderPaint.style = PaintingStyle.stroke;
    rectBorderPaint.strokeWidth = 2;

    var rectFillPaint = Paint();
    rectFillPaint.color = Colors.white.withOpacity(0.6);
    rectFillPaint.style = PaintingStyle.fill;

    stageX = 0;
    stageY = 0;
    for (int i = 0; i < _stageRow; i++) { //행
      for (int j = 0; j < _stageColumn; j++) { //열
        canvas.drawRect(Offset(stageX, stageY) & Size(stageWidth, stageHeight), rectBorderPaint);
        canvas.drawRect(Offset(stageX, stageY) & Size(stageWidth, stageHeight), rectFillPaint);

        if (stageOffsets.contains(Offset(stageX, stageY)) == false) { //중복없이 리스트에 넣기
          stageOffsets.add(Offset(stageX, stageY));
        }
        stageX += stageWidth; //다음열에 사각형 그리기
      }
      stageY += stageHeight; //다음행에 사각형 그리기
      stageX = 0; //다음행으로 넘어갔을때 x좌표 초기화
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TouchedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var touchRectPaint = Paint();
    touchRectPaint.color = Colors.lightGreen.withOpacity(0.3);
    touchRectPaint.style = PaintingStyle.fill;
    if (((touchedOffset.dx - startOffset.dx).abs() <= stageWidth &&
        (touchedOffset.dy - startOffset.dy).abs() == 0) ||
        ((touchedOffset.dx - startOffset.dx).abs() == 0 &&
            (touchedOffset.dy - startOffset.dy).abs() <= stageHeight)) { //시작좌표에서 터치좌표의 거리가 대각선이 아닌 1칸일때
      if(startOffset != const Offset(0,0) && touchedOffset == startOffset) { //터치했던 곳 다시 터치했을 시 좌표 삭제
        pathOffsets.removeLast();
        touchedOffset = pathOffsets.last;
        startOffset = pathOffsets.last;
      } else if(pathOffsets.contains(touchedOffset) == false){ //색칠했던 경로가 아닐 때 좌표추가
        startOffset = touchedOffset;
        pathOffsets.add(touchedOffset);
      }
      print('터치한 x좌표: $touchedOffset, 시작점 x좌표: $startOffset');
      print('색칠한 경로리스트: $pathOffsets'); //두번 색칠되는거 그냥 크롬 껐다켜니까 됨
    } else { //1칸 이상일 때
      print("앙 틀렸디");
    }
    for (var offset in pathOffsets) { //경로 색칠
      canvas.drawRect(offset & Size(stageWidth, stageHeight), touchRectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}