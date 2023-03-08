import 'package:cloud_firestore/cloud_firestore.dart';
import 'machine_class.dart';

class FirebaseHelper {
  // Variables to store machine data
  String tableName = 'Machines';

  //Creates a machine table that is to be sent to the firebase database, before it is sent it converts it to JSON format
  Future addMachine(Machine machine) async {
    final docMachine = FirebaseFirestore.instance.collection(tableName).doc();
    final machineTable = Machine(
        id: docMachine.id,
        name: machine.name,
        desc: machine.desc,
        lat: machine.lat,
        lon: machine.lon,
        imagePath: machine.imagePath,
        icon: machine.icon,
        card: machine.card,
        cash: machine.cash,
        operational: machine.operational);
    final json = machineTable.toJson();
    //Create document and write data to firestore
    await docMachine.set(json);
  }

  //Makes a Firestore instance, gets a snapshot fo the data inside the Machine collection
  //Returns a list of machines and the data inside them
  Future<List<Machine>> getAllMachines() async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.get();
    return querySnapshot.docs.map((doc) => Machine.fromJson(doc.data())).toList();
  }

  //Creates instance, gets snapshot
  //Returns size of snapshot (number of total machines)
  Future<int> getMachineCount() async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.get();
    return querySnapshot.size;
  }

  //Creates instance, gets snapshot, queries for machines that have card payments.
  //Returns list of machines with card payments enabled
  Future<int> getMachineCardValue(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).get();
    final machineData = querySnapshot.docs.first.data();
    return machineData['card'];
  }

  Future<Machine?> getMachineById(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).limit(1).get();
    if (querySnapshot.size == 0) {
      return null; // No machine with the given ID found
    } else {
      return Machine.fromJson(querySnapshot.docs.first.data());
    }
  }

  Future<void> deleteMachineById(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection('Machines');
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).get();
    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      await machineDoc.delete();
      print("Machine deleted");
    }
  }

  Future<void> updateMachine(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection('Machines');
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).get();
    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      await machineDoc.update({
        'imagePath': machine.imagePath,
        'operational': machine.operational,
        // add more fields as needed
      });
      print('Machine updated');
    }
  }
}
