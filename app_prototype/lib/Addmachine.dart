import 'package:flutter/material.dart';

class AddMachinePage extends StatefulWidget {
  const AddMachinePage({Key? key}) : super(key: key);

  @override
  _AddMachinePageState createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  bool _isSnackSelected = false;
  bool _isDrinkSelected = false;
  bool _isSupplySelected = false;
  bool _isCashSelected = false;
  bool _isWorkingSelected = false;

  @override
  void dispose() {
    _buildingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Machine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Building Number'),
            TextField(
              controller: _buildingController,
            ),
            SizedBox(height: 16.0),
            Text('Floor Number'),
            TextField(
              controller: _floorController,
            ),
            SizedBox(height: 16.0),
            Text('Select Machine Type(s)'),
            CheckboxListTile(
              title: Text('Snack'),
              value: _isSnackSelected,
              onChanged: (value) {
                setState(() {
                  _isSnackSelected = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Drink'),
              value: _isDrinkSelected,
              onChanged: (value) {
                setState(() {
                  _isDrinkSelected = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Supply'),
              value: _isSupplySelected,
              onChanged: (value) {
                setState(() {
                  _isSupplySelected = value!;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text('Select Machine Options'),
            CheckboxListTile(
              title: Text('Cash/No Cash'),
              value: _isCashSelected,
              onChanged: (value) {
                setState(() {
                  _isCashSelected = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Working/Not Working'),
              value: _isWorkingSelected,
              onChanged: (value) {
                setState(() {
                  _isWorkingSelected = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
