import 'package:cloud_firestore/cloud_firestore.dart';
import 'machine.dart';
import 'user.dart';

class FirebaseHelper {
  // Variables to store machine data
  String tableName = 'Machines';
  String userTable = 'Users';

  // Cache for machines to avoid redundant Firestore queries
  List<Machine>? _cachedMachines;
  DateTime? _lastCacheUpdate;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Check if cache is valid
  bool get _isCacheValid =>
      _cachedMachines != null &&
      _lastCacheUpdate != null &&
      DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration;

  // Getter for cache data with validity check
  Future<List<Machine>> getCachedMachines() async {
    if (_isCacheValid) {
      return _cachedMachines!;
    }

    // If cache is invalid, refresh it
    _cachedMachines = await _fetchAllMachines();
    _lastCacheUpdate = DateTime.now();
    return _cachedMachines!;
  }

  // Private method to fetch all machines from Firestore
  Future<List<Machine>> _fetchAllMachines() async {
    final useTestMachines = await getTestMachinesSetting();
    final collectionName = useTestMachines ? 'TestMachines' : tableName;

    final machinesCollection =
        FirebaseFirestore.instance.collection(collectionName);
    final querySnapshot = await machinesCollection.get();
    return querySnapshot.docs
        .map((doc) => Machine.fromJson(doc.data()))
        .toList();
  }

  //Creates a machine table that is to be sent to the firebase database
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

    // Update cache immediately with the new machine
    if (_cachedMachines != null) {
      _cachedMachines!.add(machineTable);
    }
  }

  //Makes a Firestore instance, gets a snapshot fo the data inside the Machine collection
  //Returns a list of machines and the data inside them
  Future<List<Machine>> getAllMachines() async {
    return getCachedMachines();
  }

  //Creates instance, gets snapshot
  //Returns size of snapshot (number of total machines)
  Future<int> getMachineCount() async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection.get();
    return querySnapshot.size;
  }

  // Get filtered machines from cache rather than running multiple Firestore queries
  Future<List<Machine>> getFilteredMachines(
      bool snack, bool drink, bool supply) async {
    // Get all machines from cache
    final allMachines = await getCachedMachines();

    // If no filters are active, return an empty list
    if (!snack && !drink && !supply) {
      return [];
    }

    // Filter the cached machines in memory instead of querying Firestore repeatedly
    return allMachines.where((machine) {
      if (snack && machine.icon == "assets/images/BlueMachine.png") {
        return true;
      }
      if (drink && machine.icon == "assets/images/PinkMachine.png") {
        return true;
      }
      if (supply && machine.icon == "assets/images/YellowMachine.png") {
        return true;
      }
      return false;
    }).toList();
  }

  //Creates instance, gets snapshot, queries for machines that have card payments.
  //Returns list of machines with card payments enabled
  Future<int> getMachineCardValue(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machine.id).get();
    final machineData = querySnapshot.docs.first.data();
    return machineData['card'];
  }

  //Helper to get a machine based on its id.
  Future<Machine?> getMachineById(Machine machine) async {
    final useTestMachines = await getTestMachinesSetting();
    final collectionName = useTestMachines ? 'TestMachines' : tableName;

    final machinesCollection =
        FirebaseFirestore.instance.collection(collectionName);
    final querySnapshot = await machinesCollection
        .where('id', isEqualTo: machine.id)
        .limit(1)
        .get();

    if (querySnapshot.size == 0) {
      return null; // No machine with the given ID found
    } else {
      final data = querySnapshot.docs.first.data();
      // Map the field names to match what Machine.fromJson expects and handle null values
      final mappedData = {
        'id': data['id'] ?? '',
        'name': data['name'] ?? '',
        'description': data['desc'] ?? '',
        'latitude': data['lat']?.toDouble() ?? 0.0,
        'longitude': data['lon']?.toDouble() ?? 0.0,
        'imagePath': data['imagePath'] ?? '',
        'icon': data['icon'] ?? '',
        'card': data['card'] ?? false,
        'cash': data['cash'] ?? false,
        'operational': data['operational'] ?? true,
        'upvotes': data['upvotes'] ?? 0,
        'dislikes': data['dislikes'] ?? 0,
        'rating': data['rating']?.toDouble() ?? 0.0,
        'ratingCount': data['ratingCount'] ?? 0,
        'reports': data['reports'] ?? [],
        'reportCount': data['reportCount'] ?? 0,
      };
      return Machine.fromJson(mappedData);
    }
  }

  // Helper to get a machine based on its id.
  Future<Machine?> getMachineByIdString(String id) async {
    // First check cache
    if (_cachedMachines != null) {
      final cachedMachine = _cachedMachines!.firstWhere(
        (machine) => machine.id == id,
        orElse: () => Machine(
          id: '',
          name: '',
          desc: '',
          lat: 0,
          lon: 0,
          imagePath: '',
          icon: '',
          card: false,
          cash: false,
          operational: false,
          upvotes: 0,
          dislikes: 0,
        ),
      );
      if (cachedMachine.id.isNotEmpty) {
        return cachedMachine;
      }
    }

    // If not in cache, query Firestore
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: id).limit(1).get();
    if (querySnapshot.size == 0) {
      return null;
    }
    return Machine.fromJson(querySnapshot.docs.first.data());
  }

  //Helper to delete a machine base on its id.
  Future<void> deleteMachineById(Machine machine) async {
    final machinesCollection =
        FirebaseFirestore.instance.collection('Machines');
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machine.id).get();
    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      await machineDoc.delete();
      print("Machine deleted");
    }
  }

  //Updates a machine with another machine.
  Future<void> updateMachine(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machine.id).get();
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

  // Update machine status properties (card, cash, operational)
  Future<void> updateMachineStatus(Machine machine) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machine.id).get();
    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      await machineDoc.update({
        'card': machine.card,
        'cash': machine.cash,
        'operational': machine.operational,
      });

      // Invalidate cache when updating a machine
      _cachedMachines = null;
      print('Machine status updated');
    }
  }

  // Add a new rating to a machine and update the average rating
  Future<void> addRating(String machineId, double newRating) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machineId).get();

    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      final machineData = querySnapshot.docs.first.data();

      final double currentRating = machineData['rating'] ?? 0.0;
      final int currentCount = machineData['ratingCount'] ?? 0;

      // Calculate new average rating
      final double totalRating = (currentRating * currentCount) + newRating;
      final int newCount = currentCount + 1;
      final double newAverageRating = totalRating / newCount;

      await machineDoc.update({
        'rating': newAverageRating,
        'ratingCount': newCount,
      });
      print('Machine rating updated');
    }
  }

  // Add a new report to a machine
  Future<void> addReport(String machineId, String reportText) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machineId).get();

    if (querySnapshot.size > 0) {
      final machineDoc = querySnapshot.docs.first.reference;
      final machineData = querySnapshot.docs.first.data();

      final List<String> currentReports = machineData['reports'] != null
          ? List<String>.from(machineData['reports'])
          : [];
      final int currentReportCount = machineData['reportCount'] ?? 0;

      currentReports.add(reportText);

      await machineDoc.update({
        'reports': currentReports,
        'reportCount': currentReportCount + 1,
      });
      print('Machine report added');
    }
  }

  // Get all reports for a machine
  Future<List<String>> getMachineReports(String machineId) async {
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot =
        await machinesCollection.where('id', isEqualTo: machineId).get();

    if (querySnapshot.size > 0) {
      final machineData = querySnapshot.docs.first.data();
      final List<String> reports = machineData['reports'] != null
          ? List<String>.from(machineData['reports'])
          : [];
      return reports;
    }
    return [];
  }

  Future<String?> getMachineIdByLocation(
      double latitude, double longitude) async {
    // First check cache
    if (_cachedMachines != null) {
      final cachedMachine = _cachedMachines!.firstWhere(
        (machine) => machine.lat == latitude && machine.lon == longitude,
        orElse: () => Machine(
          id: '',
          name: '',
          desc: '',
          lat: 0,
          lon: 0,
          imagePath: '',
          icon: '',
          card: false,
          cash: false,
          operational: false,
          upvotes: 0,
          dislikes: 0,
        ),
      );
      if (cachedMachine.id.isNotEmpty) {
        return cachedMachine.id;
      }
    }

    // If not in cache, query Firestore
    final machinesCollection = FirebaseFirestore.instance.collection(tableName);
    final querySnapshot = await machinesCollection
        .where('latitude', isEqualTo: latitude)
        .where('longitude', isEqualTo: longitude)
        .limit(1)
        .get();
    if (querySnapshot.size == 0) {
      return null;
    }
    return querySnapshot.docs.first.data()['id'] as String?;
  }

  // Method to get test machines
  Future<List<Machine>> getTestMachines() async {
    final testMachinesCollection =
        FirebaseFirestore.instance.collection('TestMachines');
    final querySnapshot = await testMachinesCollection.get();
    return querySnapshot.docs
        .map((doc) => Machine.fromJson(doc.data()))
        .toList();
  }
}
//Gets the image metadata and returns the time that the image was created
//We use this to determine when the user is able to upload another machine
//By taking the time of the last image they can upload in a day, we can add 24 hours to
//it and then not let them upload until then
