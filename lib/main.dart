import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witchy/domain/models/period_cycle.dart';
import 'package:witchy/domain/repositories/period_cycle_repository.dart';
import 'package:witchy/domain/services/cycle_predictor.dart';
import 'package:witchy/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbService = LocalDatabaseService();
  await dbService.initialize();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalDatabaseService>.value(value: dbService),
        Provider<NotificationService>.value(value: notificationService),
        ProxyProvider<LocalDatabaseService, PeriodCycleRepository>(
          update: (_, db, __) => HivePeriodCycleRepository(db),
        ),
        ProxyProvider<LocalDatabaseService, DailyLogRepository>(
          update: (_, db, __) => HiveDailyLogRepository(db),
        ),
        ProxyProvider<PeriodCycleRepository, PeriodCycleProvider>(
          update: (_, repo, __) => PeriodCycleProvider(repository: repo, notificationService: notificationService),
        ),
        ProxyProvider<DailyLogRepository, DailyLogProvider>(
          update: (_, repo, __) => DailyLogProvider(repository: repo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Witchy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const CycleListScreen(),
    );
  }
}

class CycleListScreen extends StatefulWidget {
  const CycleListScreen({super.key});

  @override
  State<CycleListScreen> createState() => _CycleListScreenState();
}

class _CycleListScreenState extends State<CycleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodCycleProvider>().loadCycles();
      context.read<DailyLogProvider>().loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cycles')),
      body: Consumer<PeriodCycleProvider>(
        builder: (context, provider, child) {
          if (provider.cycles.isEmpty) {
            return const Center(child: Text('No cycles recorded yet.'));
          }
          return ListView.builder(
            itemCount: provider.cycles.length,
            itemBuilder: (context, index) {
              final cycle = provider.cycles[index];
              return ListTile(
                title: Text('Cycle starting ${cycle.startDate.toLocal().toString().split(' ')[0]}'),
                subtitle: Text(cycle.isCompleted ? 'Ended' : 'In progress'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.deleteCycle(cycle.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.read<PeriodCycleProvider>().startNewCycle(DateTime.now());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
