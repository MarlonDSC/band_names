import 'package:band_names/services/chat/chat_bloc.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:band_names/pages/home.dart';
import 'package:band_names/pages/status.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatBloc(),
        ),
      ],
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => SocketService())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Material App',
          initialRoute: 'home',
          routes: {
            'home': (_) => const HomePage(),
            'status': (_) => const StatusPage()
          },
        ),
      ),
    );
  }
}
