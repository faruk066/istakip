import 'package:flutter/foundation.dart';
import '../models/job.dart';

class JobService extends ChangeNotifier {
  final List<Job> _jobs = [];

  List<Job> get jobs => List.unmodifiable(_jobs);

  JobService() {
    _populateMockData();
  }

  void _populateMockData() {
    _jobs.addAll([
      Job(
        id: '1',
        buildingName: 'ALTAŞ',
        flatNumber: '39',
        brand: 'CALMET',
        counterType: 'SICAK SU',
        status: 'YENİ',
        description: '',
      ),
      Job(
        id: '2',
        buildingName: 'NİL MY',
        flatNumber: 'A41',
        brand: 'SENSÖR DEĞİŞTİR',
        counterType: '',
        status: '',
        description: '',
      ),
      Job(
        id: '3',
        buildingName: 'MANZARA',
        flatNumber: 'A24',
        brand: 'CALMET',
        counterType: 'ULTRASONİ ÖDEDİ',
        status: 'ÖDEDİ',
        description: '',
      ),
    ]);
    notifyListeners();
  }

  void addJob(Job job) {
    _jobs.add(job);
    notifyListeners();
  }

  void addJobs(List<Job> jobs) {
    _jobs.addAll(jobs);
    notifyListeners();
  }

  void removeJob(String id) {
    _jobs.removeWhere((job) => job.id == id);
    notifyListeners();
  }
}
