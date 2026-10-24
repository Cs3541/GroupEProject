import 'package:flutter/material.dart';

class MainAlarmScreen extends StatelessWidget {
    const MainAlarmScreen({super.key});
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                actions: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.settings)
                    )
                ] 
            ),
            body:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text('Alarm Title goes Here' ),
                    Text('8:00 AM'),
                    ElevatedButton(
                        onPressed: () {},
                        child: Text('Stop Alarm')
                    )
                ]
            ),         
        );
    }
}