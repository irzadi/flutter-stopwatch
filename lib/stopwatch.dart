import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Stopwatch extends StatefulWidget {
  const Stopwatch({super.key});

  @override
  State<Stopwatch> createState() => _StopwatchState();
}

class _StopwatchState extends State<Stopwatch> {
  int milliseconds = 0;
  late Timer timer;
  bool isTicking = false;
  final laps = <int>[];

  final itemheight = 60.0;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 100), _onTick);
  }

  void _onTick(Timer time) {
    if (mounted && isTicking) {
      setState(() {
        milliseconds += 100;
      });
    }
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 100;
    return "$seconds ${seconds < 2 ? 'second' : 'seconds'} ";
  }

  @override
  void dispose() {
    timer.cancel();
    scrollController.dispose();
    super.dispose();
  }

  void _lap() {
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });
    scrollController.animateTo(itemheight * laps.length,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
      child: ListView.builder(
        controller: scrollController,
        itemExtent: itemheight,
        itemCount: laps.length,
        itemBuilder: (context, index) {
          final milliseconds = laps[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 50),
            title: Text('Lap ${index + 1}'),
            trailing: Text(_secondsText(milliseconds)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: const Text('Stopwatch')),
          backgroundColor: Theme.of(context).colorScheme.primary),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildCounter()),
          Expanded(child: _buildLapDisplay())
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Lap ${laps.length + 1}"),
        Text(
          _secondsText(milliseconds),
          style: const TextStyle(fontSize: 25),
        ),
        const Padding(
          padding: EdgeInsets.all(10),
        ),
        Center(
          child: buildButtons(),
        ),
      ],
    );
  }

  Row buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
          onPressed: () {
            setState(() {
              laps.clear();
              milliseconds = 0;
              isTicking = false;
            });
          },
          child: const Text(
            "reset",
          ),
        ),
        const Padding(padding: EdgeInsets.all(10)),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ),
          onPressed: isTicking ? _stopTimer : _startTimer,
          child: const Text('Start/Stop'),
        ),
        const Padding(padding: EdgeInsets.all(10)),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
          ),
          onPressed: _lap,
          child: const Text('Lap'),
        ),
      ],
    );
  }

  void _startTimer() {
    setState(() {
      isTicking = true;
    });
  }

  void _stopTimer() {
    setState(() {
      isTicking = false;
    });
  }
}
