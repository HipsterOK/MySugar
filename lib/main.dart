import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() {
  runApp(const MyApp());
}

class DiabetesEntry {
  final String date;
  final String time;
  final double glucoseLevel;

  DiabetesEntry({
    required this.date,
    required this.time,
    required this.glucoseLevel,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Diabetes Diary'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DiabetesEntry> entries = [];
  DateTime selectedDate = DateTime.now();
  String selectedTime = '';

  void addEntry(DiabetesEntry entry) {
    setState(() {
      entries.add(entry);
      entries.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  List<DiabetesEntry> getEntriesForSelectedDate() {
    final formattedDate = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    return entries.where((entry) => entry.date == formattedDate).toList();
  }

  void selectDate() {
    DatePicker.showDatePicker(
      context,
      onConfirm: (date) {
        setState(() {
          selectedDate = date;
        });
      },
    );
  }

  void selectTime() {
    DatePicker.showTimePicker(
      context,
      onConfirm: (time) {
        setState(() {
          selectedTime = time.toString().substring(11, 16);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: selectDate,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Дата: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'),
            subtitle: Text('Время: $selectedTime'),
            trailing: IconButton(
              icon: Icon(Icons.access_time),
              onPressed: selectTime,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getEntriesForSelectedDate().length,
              itemBuilder: (context, index) {
                final entry = getEntriesForSelectedDate()[index];
                return ListTile(
                  title: Text('Дата: ${entry.date} Время: ${entry.time}'),
                  subtitle: Text('Уровень глюкозы: ${entry.glucoseLevel} мг/дл'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiabetesEntryPage(
                onEntryAdded: addEntry,
                defaultDate: selectedDate,
                defaultTime: selectedTime,
              ),
            ),
          );
        },
        tooltip: 'Добавить запись',
        child: Icon(Icons.add),
      ),
    );
  }
}

class DiabetesEntryPage extends StatefulWidget {
  final Function(DiabetesEntry) onEntryAdded;
  final DateTime defaultDate;
  final String defaultTime;

  DiabetesEntryPage({
    required this.onEntryAdded,
    required this.defaultDate,
    required this.defaultTime,
  });

  @override
  _DiabetesEntryPageState createState() => _DiabetesEntryPageState();
}

class _DiabetesEntryPageState extends State<DiabetesEntryPage> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = '';
  final TextEditingController glucoseLevelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.defaultDate;
    selectedTime = widget.defaultTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить запись глюкозы'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text('Дата: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'),
              subtitle: Text('Время: $selectedTime'),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: selectTime,
              ),
            ),
            TextFormField(
              controller: glucoseLevelController,
              decoration: InputDecoration(labelText: 'Уровень глюкозы (мг/дл)'),
            ),
            ElevatedButton(
              onPressed: () {
                final glucoseLevel = double.parse(glucoseLevelController.text);

                final entry = DiabetesEntry(
                  date: "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                  time: selectedTime,
                  glucoseLevel: glucoseLevel,
                );

                widget.onEntryAdded(entry);
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void selectTime() {
    DatePicker.showTimePicker(
      context,
      onConfirm: (time) {
        setState(() {
          selectedTime = time.toString().substring(11, 16);
        });
      },
    );
  }
}
