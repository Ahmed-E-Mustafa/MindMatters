/*import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'camera_integration.dart';

class CallPage extends StatefulWidget {
  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final TextEditingController myController = TextEditingController();
  bool _validateError = false;

  Future<void> onJoin() async {
    setState(() {
      myController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    if (!_validateError) {
      await Permission.camera.request();
      await Permission.microphone.request();

      // Navigate to the camera_integration.dart
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: myController,
              decoration: InputDecoration(
                labelText: 'Channel Name',
                errorText:
                    _validateError ? 'Channel Name cannot be empty' : null,
              ),
            ),
            ElevatedButton(
              onPressed: onJoin,
              child: Text('Join Call'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/controllers/rtc_buttons.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class CallPage extends StatefulWidget {
  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final TextEditingController myController = TextEditingController();
  bool _validateError = false;

  Future<void> onJoin(BuildContext context) async {
    setState(() {
      myController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    if (!_validateError) {
      await Permission.camera.request();
      await Permission.microphone.request();

      // Navigate to the Agora page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgoraPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: myController,
              decoration: InputDecoration(
                labelText: 'Channel Name',
                errorText:
                    _validateError ? 'Channel Name cannot be empty' : null,
              ),
            ),
            ElevatedButton(
              onPressed: () => onJoin(context),
              child: Text('Join Call'),
            ),
          ],
        ),
      ),
    );
  }
}

class AgoraPage extends StatefulWidget {
  @override
  _AgoraPageState createState() => _AgoraPageState();
}

class _AgoraPageState extends State<AgoraPage> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "f041fa5c2bfc4d79938a8b1cf6dc4da8",
      channelName: "test",
      tempToken: "YOUR_VALID_TOKEN_HERE", // Replace with a valid token
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  get sessionController => null;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(client: client),
            AgoraVideoButtons(client: client),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserTypeSelectionScreen(),
            ),
          );
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of resources when the widget is disposed
    super.dispose();
    endCall(sessionController: sessionController);
    // Leave the channel when disposing
  }
}
