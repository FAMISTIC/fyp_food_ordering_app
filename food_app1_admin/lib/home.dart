import 'package:flutter/material.dart';
import 'package:food_app1_admin/food_item.dart';
import 'package:food_app1_admin/order_page.dart';
import 'package:food_app1_admin/user_account.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends  State<HomePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ElevatedButton.icon(
            icon: const Icon(
            Icons.note,
            size: 24.0,
            ),
            label: const Text('Order Account'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderPage()),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(
            Icons.note,
            size: 24.0,
            ),
            label: const Text('Table Reservation'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(
            Icons.person,
            size: 24.0,
            ),
            label: const Text('User Account'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(
            Icons.rate_review,
            size: 24.0,
            ),
            label: const Text('Customer Feedback'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(
            Icons.fastfood,
            size: 24.0,
            ),
            label: const Text('Food Availability'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodPage()),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(
            Icons.star,
            size: 24.0,
            ),
            label: const Text('Recommendation'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            },
          ),
        ],
        ),   
      ),
    );
  }
}