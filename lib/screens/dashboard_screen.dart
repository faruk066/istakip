import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/job_service.dart';
import '../services/import_service.dart';
import 'add_job_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Excel\'den Yükle'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final jobs = await ImportService().pickAndParseExcel();
                    if (context.mounted && jobs.isNotEmpty) {
                      Provider.of<JobService>(context, listen: false).addJobs(jobs);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${jobs.length} iş başarıyla yüklendi.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Fotoğraf ile Yükle (OCR)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showImageSourceDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fotoğraf Kaynağı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _processImageImport(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _processImageImport(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImageImport(BuildContext context, ImageSource source) async {
    try {
      final jobs = await ImportService().pickAndParseImage(source);
      if (context.mounted && jobs.isNotEmpty) {
        Provider.of<JobService>(context, listen: false).addJobs(jobs);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${jobs.length} satır okundu/eklendi.')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metin okunamadı veya iptal edildi.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İş Takip Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'İş Listesi Yükle',
            onPressed: () => _showImportOptions(context),
          ),
        ],
      ),
      body: Consumer<JobService>(
        builder: (context, jobService, child) {
          final jobs = jobService.jobs;
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Henüz kayıtlı iş yok.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showImportOptions(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('İş Listesi Yükle'),
                  ),
                ],
              ),
            );
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
