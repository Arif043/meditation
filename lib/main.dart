import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:meditation/PhaseWidget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final player = AudioPlayer();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meditation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'meditation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static var list = <PhaseWidget>[];
  Timer? timer;
  var displayStr = "";
  var isVisible = true;
  static bool submit = false;

  @override
  void initState() {
    super.initState();
    list.add(PhaseWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                    visible: !isVisible,
                    child: Text(displayStr,
                        style: Theme.of(context).textTheme.titleLarge)),
                Column(
                  children: list,
                ),
                const SizedBox(
                  height: 30,
                ),
                Visibility(
                  visible: isVisible,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(), elevation: 4),
                    onPressed: () {
                      setState(() {
                        list.add(PhaseWidget());
                      });
                    },
                    child: const Text('+'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: isVisible,
        child: FloatingActionButton(
          onPressed: () {
            submit = true;
            var missingField = false;
            for (var state in PhaseWidgetState.states) {
              state.setState(() {});
              if (state.isVisible && state.errorText != null) {
                missingField = true;
              }
            }
            if (!missingField) {
              WakelockPlus.enable();
              meditate();
            }
          },
          child: const Text('Start'),
        ),
      ),
    );
  }

  void meditate() async {
    var activeWidgets = <PhaseWidgetState>[];
    setState(() => isVisible = false);
    for (var state in PhaseWidgetState.states) {
      if (state.isVisible) {
        activeWidgets.add(state);
        state.setState(() => state.isVisible = false);
      }
    }
    var counter = 5;
    Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (counter != 0) setState(() => displayStr = counter.toString());
        if (counter-- < 1) {
          timer.cancel();

          for (var s in activeWidgets) {
            await player.stop();
            await player.play(AssetSource('audio/bowl.mp3'));
            setState(() => displayStr = s.descriptionController.text);
            await waitForPhase(int.parse(s.numberController.text), s.selectedTimeUnit);
          }

          // Reset
          AudioPlayer().play(AssetSource('audio/end.mp3'));
          for (var state in activeWidgets) {
            state.setState(() => state.isVisible = true);
          }
          setState(() => isVisible = true);
          displayStr = "";

          // Run the isolate and pass the phaseDataList
          // final result = await Isolate.run(meditateIsolate(p));

          // Use the result here
        }
      },
    );
  }

  static Future<void> waitForPhase(int time, TimeUnitLabel label) async {
    return Future.delayed(label == TimeUnitLabel.minute ? Duration(minutes: time) : Duration(seconds: time), () => null);
  }
}