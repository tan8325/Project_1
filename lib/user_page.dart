import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Progress Indicator
            SizedBox(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Transform.scale(
                        // increases size of the progress indicator
                        scale: 4,
                        child: CircularProgressIndicator(
                          value: 0.8, // placeholder value
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurpleAccent,
                          ),
                          backgroundColor: Colors.grey,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 48,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Text('\$1,600'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
