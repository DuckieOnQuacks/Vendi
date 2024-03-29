import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'machine_class.dart';


class FirebaseHelper {
  // Variables to store machine data
  String tableName = 'Machines';
  String userTable = 'Users';

  //Creates a machine table that is to be sent to the firebase database, before it is sent it converts it to JSON format
  Future<void> addMachine(Machine machine) async {
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
      operational: machine.operational,
      upvotes: machine.upvotes,
      dislikes: machine.dislikes,
    );
    final json = machineTable.toJson();
    // Create document and write data to Firestore
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

  //Grabs the machine instances based on the filtering
  Future<List<Machine>> getFilteredMachines(bool snack, bool drink, bool supply) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);

    List<QueryDocumentSnapshot<Map<String, dynamic>>> filterDocs = [];
    if (snack)
    {
      final snackSnapshot = await machinesCollection.where('icon', isEqualTo: "assets/images/BlueMachine.png").get();
      filterDocs.addAll(snackSnapshot.docs);
    }
    if (drink)
    {
      final drinkSnapshot = await machinesCollection.where('icon', isEqualTo: "assets/images/PinkMachine.png").get();
      filterDocs.addAll(drinkSnapshot.docs);
    }
    if (supply)
    {
      final supplySnapshot = await machinesCollection.where('icon', isEqualTo: "assets/images/YellowMachine.png").get();
      filterDocs.addAll(supplySnapshot.docs);
    }
    return filterDocs.map((doc) => Machine.fromJson(doc.data())).toList();
  }



  //Creates instance, gets snapshot, queries for machines that have card payments.
  //Returns list of machines with card payments enabled
  Future<int> getMachineCardValue(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).get();
    final machineData = querySnapshot.docs.first.data();
    return machineData['card'];
  }

  //Helper to get a machine based on its id.
  Future<Machine?> getMachineById(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).limit(1).get();
    if (querySnapshot.size == 0) {
      return null; // No machine with the given ID found
    } else {
      return Machine.fromJson(querySnapshot.docs.first.data());
    }
  }

  //Helper to get a machine based on its id.
  Future<Machine?> getMachineByIdString(String id) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.where('id', isEqualTo: id).limit(1).get();
    if (querySnapshot.size == 0) {
      return null; // No machine with the given ID found
    } else {
      return Machine.fromJson(querySnapshot.docs.first.data());
    }
  }

  //Helper to delete a machine base on its id.
  Future<void> deleteMachineById(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection('Machines');
    final querySnapshot = await machinesCollection.where('id', isEqualTo: machine.id).get();
    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      await machineDoc.delete();
      print("Machine deleted");
    }
  }

  //Updates a machine with another machine.
  Future<void> updateMachine(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
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

  Future<String?> getMachineIdByLocation(double latitude, double longitude) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection
        .where('latitude', isEqualTo: latitude)
        .where('longitude', isEqualTo: longitude)
        .limit(1)
        .get();
    if (querySnapshot.size == 0) {
      return null; // No machine with the given location found
    } else {
      final Map<String, dynamic> data = querySnapshot.docs.first.data();
      return data['id'] as String?;
    }
  }
}

//Gets the image metadata and returns the time that the image was created
//We use this to determine when the user is able to upload another machine
//By taking the time of the last image they can upload in a day, we can add 24 hours to
//it and then not let them upload until then
Future<DateTime?> getImageTakenTime(String imageUrl) async {
  try {
    // Create a reference to the image in Firebase Storage
    Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);

    // Get the metadata of the image
    FullMetadata metadata = await ref.getMetadata();

    // Get the time the image was taken
    DateTime? timeCreated = metadata.timeCreated;
    return timeCreated;
  } catch (e) {
    print("Error fetching image metadata: $e");
    return null;
  }
}

//Creates instance, gets snapshot
//Returns size of snapshot (number of total machines)
Future<int> getMachineCount() async {
  final machinesCollection = FirebaseFirestore.instance.collection('Machines');
  final querySnapshot = await machinesCollection.get();
  return querySnapshot.size;
}

