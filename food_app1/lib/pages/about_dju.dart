import 'package:flutter/material.dart';

class AboutDjuPage extends StatelessWidget {
  const AboutDjuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 55),
                child: Text('About DJU Cafe'),
              ),
            ),
          ),
        ),
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(225, 245, 93, 66),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Welcome to Dju!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Image(
                image: NetworkImage('https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhO8XkQDZkui_oOWfczWTT-tyVuIcbNUedzE86Um9LpxMBSEexNNfT3nNPU_b6TTCwj45hY80NTa-CTlLdi0Z0JfRcLXPaQa8iZ-8b3AYE89R7O5_uw83bXmnQ2dIvwn1LfU3uap7Qp99Oi/s1600/DSC_0127.JPG')
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Location:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '123 Dju Street, Cityville',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Service:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Dju offers a diverse menu featuring a blend of local and international cuisines. From savory to sweet, our chefs craft each dish with passion and creativity.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more information about Dju as needed
          ],
        ),
      ),
    );
  }
}
