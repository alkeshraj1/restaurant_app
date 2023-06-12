import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RestaurantState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant App'),
      ),
      body: Consumer<RestaurantState>(
        builder: (context, state, child) {
          return Column(
            children: <Widget>[
              Text('Username: ${state.user['username']}'),
              Text('Balance: ${state.user['balance']}'),
              // Show order information
              for (var order in state.orders)
                ListTile(
                  title: Text('Quantity: ${order['quantity']}'),
                  subtitle: Text('Total: ${order['total']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Delete order
                      state.deleteOrder(order['id']);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add new order
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderPage()),
          );
        },
      ),
    );
  }
}

class OrderPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _quantityController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter quantity';
                }
                return null;
              },
            ),
            RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  // Save order
                  Provider.of<RestaurantState>(context, listen: false)
                      .addOrder(int.parse(_quantityController.text));
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantState extends ChangeNotifier {
  Map user;
  List orders = [];

  RestaurantState() {
    getUser();
    getOrders();
  }

  Future getUser() async {
    var response = await http
        .get('https://64870a89beba6297278fc0e6.mockapi.io/api/v1/users/1');
    user = json.decode(response.body);
    notifyListeners();
  }

  Future getOrders() async {
    var response = await http
        .get('https://64870a89beba6297278fc0e6.mockapi.io/api/v1/orders');
    orders = json.decode(response.body);
    notifyListeners();
  }

  Future addOrder(int quantity) async {
    var response = await http.post(
      'https://64870a89beba6297278fc0e6.mockapi.io/api/v1/orders',
      body: json.encode({
        'quantity': quantity,
        'total': quantity * 10, // Assume each item costs 10
      }),
      headers: {'Content-Type': 'application/json'},
    );
    var newOrder = json.decode(response.body);
    orders.add(newOrder);
    notifyListeners();
  }

  Future deleteOrder(int id) async {
    await http.delete(
        'https://64870a89beba6297278fc0e6.mockapi.io/api/v1/orders/$id');
    orders.removeWhere((order) => order['id'] == id);
    notifyListeners();
  }
}
