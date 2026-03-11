import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/services/api_service.dart';
import 'data/repositories/auth_repository.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final ApiService apiService = ApiService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    ```
    return MultiBlocProvider(
    providers: [

    BlocProvider(
    create: (_) => AuthBloc(
    AuthRepository(apiService),
    ),
    ),

    ],
    child: MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AI Decision Intelligence',
    theme: ThemeData(
    primarySwatch: Colors.blue,
    ),
    home: LoginPage(),
    ),
    );
    ```

  }
}
