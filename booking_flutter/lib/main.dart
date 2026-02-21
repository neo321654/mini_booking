import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io' show Platform;
import 'services/graphql_service.dart';
import 'screens/hotels_screen.dart';
import 'screens/windows_widget_screen.dart';

void main() async {
  // Инициализация Hive для кеширования GraphQL
  await initHiveForFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем GraphQL клиент
    final client = GraphQLService.getClient();

    // Определяем начальный экран в зависимости от платформы
    // Windows - показываем виджет мониторинга
    // iOS/Android - показываем полное приложение
    final homeScreen = Platform.isWindows
        ? const WindowsWidgetScreen()
        : const HotelsScreen();

    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp(
        title: 'Mini Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: homeScreen,
      ),
    );
  }
}
