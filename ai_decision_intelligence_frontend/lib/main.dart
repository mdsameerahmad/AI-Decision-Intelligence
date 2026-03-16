import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dataset_repository.dart';
import 'data/services/api_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/pages/welcome_page.dart';
import 'features/common/widgets/main_scaffold.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';

final _log = Logger('main');

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _log.info('Application started. Running on Web: $kIsWeb');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final authRepository = AuthRepository(apiService);
    final datasetRepository = DatasetRepository(apiService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository,
            apiService,
          )..add(AppStarted()),
        ),
        BlocProvider(
          create: (context) => DashboardBloc(datasetRepository)..add(LoadDatasets()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI Data Analysts',
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess || state is ProfileLoaded) {
              return const MainScaffold();
            }
            return const WelcomePage();
          },
        ),
      ),
    );
  }
}
