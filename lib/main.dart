import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Richiede i permessi per le notifiche all'avvio
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Gestisce le notifiche quando l'app è in primo piano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Notifica ricevuta in primo piano:');
    print('   Titolo: ${message.notification?.title}');
    print('   Corpo: ${message.notification?.body}');
  });

  // Gestisce le notifiche quando l'app viene aperta da una notifica
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📩 App aperta da notifica:');
    print('   Titolo: ${message.notification?.title}');
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TokenScreen(),
    );
  }
}

class TokenScreen extends StatefulWidget {
  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String fcmToken = 'Premi il pulsante per ottenere il token';
  String statusMessage = '';

  Future<void> getToken() async {
    setState(() {
      statusMessage = '⏳ Richiedo il token...';
    });

    try {
      // Ottiene il token FCM
      String? token = await FirebaseMessaging.instance.getToken();

      setState(() {
        fcmToken = token ?? 'Errore: token nullo';
        statusMessage = '✅ Token ottenuto con successo!';
      });

      print('📱 Token FCM: $token');
    } catch (e) {
      setState(() {
        fcmToken = 'Errore: ${e.toString()}';
        statusMessage = '❌ Errore durante il recupero del token';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainy FCM Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Token FCM:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SelectableText(
                  fcmToken,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              if (statusMessage.isNotEmpty)
                Text(
                  statusMessage,
                  style: TextStyle(
                    color: statusMessage.contains('✅') ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: getToken,
                icon: Icon(Icons.refresh),
                label: Text('OTTIENI TOKEN'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Copia il token e incollalo nella tabella Users di DynamoDB.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}