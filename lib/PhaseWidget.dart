import 'package:flutter/material.dart';
import 'package:meditation/main.dart';
import 'package:string_validator/string_validator.dart';

class PhaseWidget extends StatefulWidget {
  PhaseWidget({super.key});

  @override
  State<StatefulWidget> createState() => PhaseWidgetState();
}

class PhaseWidgetState extends State<PhaseWidget> {
  static var states = <PhaseWidgetState>[];
  final numberController = TextEditingController(),
      descriptionController = TextEditingController();
  var selectedTimeUnit = TimeUnitLabel.minute;
  var isVisible = true;

  String? get errorText {
    // at any time, we can get the text from _controller.value.text
    final text = numberController.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Dauer fehlt';
    }
    if (!isNumeric(text)) {
      return 'Keine Zahl';
    }
    // return null if the text is valid
    return null;
  }

  @override
  void initState() {
    super.initState();
    states.add(this);
  }

  @override
  void dispose() {
    super.dispose();
    numberController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 275,
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.red,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: numberController,
                        builder: (BuildContext context, TextEditingValue value,
                            Widget? child) {
                          return Expanded(
                            child: TextField(
                              controller: numberController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  fillColor: Colors.red,
                                  border: OutlineInputBorder(),
                                  errorText: MyHomePageState.submit
                                      ? errorText
                                      : null),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      DropdownMenu<TimeUnitLabel>(
                        onSelected: (TimeUnitLabel? unit) {
                          setState(() {
                            selectedTimeUnit = unit!;
                          });
                        },
                        initialSelection: selectedTimeUnit,
                        requestFocusOnTap: true,
                        dropdownMenuEntries: TimeUnitLabel.values
                            .map<DropdownMenuEntry<TimeUnitLabel>>(
                                (TimeUnitLabel color) {
                          return DropdownMenuEntry<TimeUnitLabel>(
                            value: color,
                            label: color.label,
                            // enabled: color.label != 'Grey',
                          );
                        }).toList(),
                      ),
                      IconButton(
                        alignment: Alignment.centerRight,
                        onPressed: () {},
                        icon: SizedBox(
                          width: 20,
                          height: 20,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isVisible = false;
                                states.remove(this);
                              });
                            },
                            child: const ImageIcon(
                              AssetImage("assets/images/icons8-trash-24.png"),
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Atmen, Luft anhalten, ...',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum TimeUnitLabel {
  second('Sekunden'),
  minute('Minuten');

  const TimeUnitLabel(this.label);

  final String label;
}

class PhaseData {
  final String description;
  final int number;

  PhaseData(this.description, this.number);
}