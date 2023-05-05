import 'package:flutter/material.dart';

class MachineHelpPage extends StatefulWidget {
  const MachineHelpPage({Key? key}) : super(key: key);

  @override
  _MachineHelpPageState createState() => _MachineHelpPageState();
}

class _MachineHelpPageState extends State<MachineHelpPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              leading: Image.asset('assets/images/PinkMachine.png'),
              title: const Text('This is a snack machine. Machines that appear like this will mostly contain snacks.'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              leading: Image.asset('assets/images/BlueMachine.png'),
              title: const Text('This is a beverage machine. Machines that appear like this will mostly contain beverages.'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              leading: Image.asset('assets/images/YellowMachine.png'),
              title: const Text('This is a supply machine. Machines that appear like this will mostly contain non-food and non-drink items.'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              leading: Icon(
                Icons.add,
                size: 40,
                color: Colors.pinkAccent,
              ),

              title: const Text('To add a new machine, simply click the plus icon on the top right corner on the maps page.'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              leading: Icon(
                Icons.filter_alt,
                size: 40,
                color: Colors.pinkAccent,
              ),

              title: const Text('This filter will sort machines by snack, beverage, or supply.'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListTile(
              leading: Icon(
                Icons.favorite,
                size: 40,
                color: Colors.red,
              ),
              title: const Text('This will favorite a machine. 10 machines can be favorited at a time. '
                  'All machines favorited will appear in the favorites tab at the bottom.'),
            ),
          ),

        ],
      ),
    );
  }
}

