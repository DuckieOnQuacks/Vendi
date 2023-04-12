import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/backend/machine_class.dart';

void main()
{
  //////////////////////////////////////////
  //First Unit Test Start
  //////////////////////////////////////////
  test('Making sure the machine class is correctly converting from json', () {
    // Setup
    Map<String, dynamic> jsonData = {
      'id': 'testId',
      'name': 'testPlace',
      'description': 'testDescription',
      'latitude': 32.01,
      'longitude': 80.99,
      'imagePath': 'localPath',
      'favorite': 1,
      'icon': 'iconPath',
      'card': 1,
      'cash': 1,
      'operational': 1,
    };

    // Do
    Machine machineTest = Machine.fromJson(jsonData);

    // Test
    expect(machineTest.id, 'testId');
    expect(machineTest.name, 'testPlace');
    expect(machineTest.desc, 'testDescription');
    expect(machineTest.lat, 32.01);
    expect(machineTest.lon, 80.99);
    expect(machineTest.imagePath, 'localPath');
    expect(machineTest.isFavorited, 1);
    expect(machineTest.icon, 'iconPath');
    expect(machineTest.card, 1);
    expect(machineTest.cash, 1);
    expect(machineTest.operational, 1);
  });


  //////////////////////////////////////////
  //Second Unit Test Start
  //////////////////////////////////////////
  test("Making sure that the machine class correctly converts to json", () {
    // Setup
    Machine machineData = Machine(
      id: 'testId',
      name: 'testPlace',
      desc: 'testDescription',
      lat: 32.44,
      lon: 22.95,
      imagePath: 'pathToImage',
      isFavorited: 0,
      icon: 'pathToIcon',
      card: 0,
      cash: 1,
      operational: 1,

    );

    // Do
    Map<String, dynamic> jsonTest = machineData.toJson();

    // Test
    expect(jsonTest['id'], 'testId');
    expect(jsonTest['name'], 'testPlace');
    expect(jsonTest['description'], 'testDescription');
    expect(jsonTest['latitude'], 32.44);
    expect(jsonTest['longitude'], 22.95);
    expect(jsonTest['imagePath'], 'pathToImage');
    expect(jsonTest['favorite'], 0);
    expect(jsonTest['icon'], 'pathToIcon');
    expect(jsonTest['card'], 0);
    expect(jsonTest['cash'], 1);
    expect(jsonTest['operational'], 1);
  });


  //////////////////////////////////////////
  //Third Unit Test Start
  //////////////////////////////////////////
  WidgetsFlutterBinding.ensureInitialized();
  test('Making sure the firebase_helper class is correctly storing and retrieving data', () async {
    await Firebase.initializeApp();
    //Create mock machine
    Machine machineData = Machine(
        id: '1',
        name: 'The Highlands',
        desc: 'floor 4',
        lat: 31.77,
        lon: 25.76,
        imagePath: 'cloud storage path',
        isFavorited: null,
        icon: 'iconPath',
        card: 0,
        cash: 1,
        operational: 1,
    );
    //Do
    //Add the machine to the firestore database
    await FirebaseHelper().addMachine(machineData);
    //Retrieve the machine from the database
    Machine? test = await FirebaseHelper().getMachineById(machineData);

    // Test
    expect(test?.id, '1');
    expect(test?.name, 'The Highlands');
    expect(test?.desc, 'floor 4');
    expect(test?.lat, 31.77);
    expect(test?.lon, 25.76);
    expect(test?.imagePath, 'cloud storage path');
    expect(test?.isFavorited, null);
    expect(test?.icon, 'iconPath');
    expect(test?.card, 0);
    expect(test?.cash, 1);
    expect(test?.operational, 1);

    //Cleanup by deleting the machine from the database.
    FirebaseHelper().deleteMachineById(test!);
  });

//////////////////////////////////////////
//Fourth Unit Test Start
//////////////////////////////////////////
  WidgetsFlutterBinding.ensureInitialized();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isAuthorized = false;

  test('Making sure the user is authenticated', () async {
    //Setup
    await Firebase.initializeApp();
    final FirebaseAuth auth = FirebaseAuth.instance;
    emailController.text = "test1234@gmail.com";
    passwordController.text = "mangotree32";

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      User user = userCredential.user!;
      print('Created user: ${user.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('Failed to create user: $e');
      }
    } catch (e) {
      print('Failed to create user: $e');
    }

    //Do
    try {
      await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text);
      isAuthorized = true;
    } on FirebaseAuthException catch (e) {
      isAuthorized = false;
    }

// Test
    expect(isAuthorized, true);

//Cleanup
    try {
      User user = auth.currentUser!;
      await user.delete();
      print('User deleted successfully');
    } on FirebaseAuthException catch (e) {
      print('Failed to delete user: $e');
    }
  });
}