import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/job_service.dart';
import 'add_job_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İş Takip Listesi')),
      body: Consumer<JobService>(
        builder: (context, jobService, child) {
          final jobs = jobService.jobs;
          if (jobs.isEmpty) {
            return const Center(child: Text('Henüz kayıtlı iş yok.'));
          }
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.work),
                  title: Text('${job.buildingName} - Daire: ${job.flatNumber}'),
                  subtitle: Text(
                    '${job.brand} - ${job.counterType}\n${job.status}',
                  ),
                  isThreeLine: true,
                  trailing: job.imageUrl != null
                      ? const Icon(Icons.image, color: Colors.blue)
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
