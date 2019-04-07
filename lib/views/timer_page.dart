import 'dart:async';

import 'package:flutter/material.dart';


enum TimerState {
  running,
  paused,
  stopped,
}


class TimerText extends StatefulWidget {
  const TimerText({this.stopwatch});

  final Stopwatch stopwatch;

  @override
  TimerTextState createState() {
    return new TimerTextState();
  }
}

class TimerTextState extends State<TimerText> {

  Timer timer;
  bool needStartTimer = true;

  @override
  Widget build(BuildContext context) {
    print('TimerTextState.build');
    if (needStartTimer) {
      startTimer();
    }

    return Text(
      getTimerText(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 64.0,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  @override
  void initState() {
    print('TimerTextState.initState');
    super.initState();
  }

  @override
  void dispose() {
    print('TimerTextState.dispose');
    cancelTimer();
    super.dispose();
  }


  void startTimer() {
    needStartTimer = false;
    timer = Timer.periodic(Duration(seconds: 1), tick);
  }

  void cancelTimer() {
    needStartTimer = true;
    timer.cancel();
  }

  void tick(Timer timer) {
    print('Tick ${widget.stopwatch.elapsedMilliseconds}');
    if (widget.stopwatch.isRunning) {
      setState(() {
      });
    } else {
      cancelTimer();
    }
  }

  String getTimerText() {
    int totalSeconds = widget.stopwatch.elapsedMilliseconds ~/ 1000;
    int hours = totalSeconds ~/ 3600;
    int minutes = totalSeconds % 3600 ~/ 60;
    int seconds = totalSeconds % 3600 % 60;
    final text = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    // print('Timer text: $text');
    return text;
  }
}


class TimerPage extends StatefulWidget {
  static const String routeName = 'timer';
  final String title;

  const TimerPage({
    Key key,
    this.title}): super(key: key);

  @override
  TimerPageState createState() {
    return new TimerPageState();
  }
}

class TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  var state = TimerState.stopped;

  final stopwatch = Stopwatch();

  TimerText timerText;

  @override
  Widget build(BuildContext context) {
    print('TimerPageState.build');
    timerText = TimerText(stopwatch: stopwatch);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          timerText,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildControlButtonList(),
          )
        ],
      )
    );
  }

  List<Widget> buildControlButtonList() {
    final buttonList = <Widget>[];

    if (state == TimerState.running || state == TimerState.paused) {
      final stopButton = FloatingActionButton(
        child: Icon(
            Icons.stop
        ),
        onPressed: () {
          stopTimer();
          setState(() {
            state = TimerState.stopped;
          });
        },
        heroTag: 'stopButton',
      );
      buttonList.add(stopButton);
      buttonList.add(SizedBox(width: 16.0,));
    }

    final playOrPauseButton = FloatingActionButton(
      child: state == TimerState.running ? Icon(
          Icons.pause
      ) : Icon(
          Icons.play_arrow
      ),
      onPressed: () {
        pauseTimer();
        if (state == TimerState.running) {
          setState(() {
            state = TimerState.paused;
          });
        } else {
          startTimer();
          setState(() {
            state = TimerState.running;
          });
        }
      },
      heroTag: 'playOrPauseButton',
    );
    buttonList.add(playOrPauseButton);

    return buttonList;
  }

  void startTimer() {
    stopwatch.start();
  }

  void pauseTimer() {
    setState(() {
      timerText = null;
    });
    stopwatch.stop();
  }

  void stopTimer() {
    setState(() {
      timerText = null;
    });
    stopwatch.reset();
    stopwatch.stop();
  }


  @override
  void initState() {
    super.initState();
    timerText = TimerText(stopwatch: stopwatch);
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed: {
        print("App resumed");
        break;
      }
      case AppLifecycleState.paused: {
        print("App paused");
        break;
      }
      case AppLifecycleState.inactive: {
        print("App inactive");
        break;
      }
      case AppLifecycleState.suspending: {
        print("App suspending");
        break;
      }
    }
  }

}