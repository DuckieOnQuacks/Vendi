import 'package:flutter/material.dart';
import 'package:vendi_app/bottom_bar.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

Map<List<String>, bool> filterValues = {
  ['Beverage', 'assets/images/BlueMachine.png']: true,
  ['Snack', 'assets/images/PinkMachine.png']: true,
  ['Supply', 'assets/images/YellowMachine.png']: true,
};

class _FilterPageState extends State<FilterPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/logo.png', fit: BoxFit.contain, height: 32),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const BottomBar()));
            },
            )
          ],
      ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: new ListView(
        children: filterValues.keys.map((List<String> key) 
        {
          return new CheckboxListTile(
            secondary: new Image.asset(key[1], fit: BoxFit.contain, height: 50),
            subtitle: new Text(key[0]),
            value: filterValues[key], 
            onChanged: (bool? value) {
              setState(() {
                filterValues[key] = value ?? true;
              });
            }
            );
        }).toList(),
      )
    );
  }
}