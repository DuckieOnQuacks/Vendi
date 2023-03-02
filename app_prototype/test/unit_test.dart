import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vendi_app/backend/machine_class.dart';

void main()
{
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
      'stock': 0
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
    expect(machineTest.stock, 0);
  });

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
      stock: 1
    );

    // Do
    Map<String, dynamic> jsonTest = machineData.toJson();

    // Test
    expect(jsonTest['id'], 'testId');
    expect(jsonTest['name'], 'testPlace');
    expect(jsonTest['description'], 'testDescription');
    expect(jsonTest['latitude'], 32.44);
    expect(jsonTest['longitude'], 80.99);
    expect(jsonTest['imagePath'], 'pathToImage');
    expect(jsonTest['favorite'], 0);
    expect(jsonTest['icon'], 'pathToIcon');
    expect(jsonTest['card'], 0);
    expect(jsonTest['cash'], 1);
    expect(jsonTest['operational'], 1);
    expect(jsonTest['stock'], 1);
  });
}