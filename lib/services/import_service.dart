import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import '../models/job.dart';

class ImportService {
  final Uuid _uuid = const Uuid();

  Future<List<Job>> pickAndParseExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Important for Web
      );

      if (result != null) {
        List<int>? bytes;
        if (kIsWeb) {
          bytes = result.files.single.bytes;
        } else {
          // On mobile, sometimes bytes is null, so read from path
          if (result.files.single.path != null) {
            bytes = File(result.files.single.path!).readAsBytesSync();
          }
        }

        if (bytes == null) return [];

        var excel = Excel.decodeBytes(bytes);
        List<Job> jobs = [];

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet == null) continue;

          bool firstRow = true;
          for (var row in sheet.rows) {
            if (firstRow) {
              firstRow = false;
              // Simple heuristic: if first cell is "Bina" or "Building", skip.
              if (row.isNotEmpty && (row[0]?.value.toString().toLowerCase().contains('bina') ?? false)) {
                continue;
              }
            }

            if (row.isEmpty) continue;

            // Assume order: Building, Flat, Brand, CounterType, Status, Description
            // Adjust indices based on your needs.
            String building = _getCellValue(row, 0);
            String flat = _getCellValue(row, 1);
            String brand = _getCellValue(row, 2);
            String counterType = _getCellValue(row, 3);
            String status = _getCellValue(row, 4);
            String description = _getCellValue(row, 5);

            if (building.isNotEmpty) {
              jobs.add(Job(
                id: _uuid.v4(),
                buildingName: building,
                flatNumber: flat,
                brand: brand,
                counterType: counterType,
                status: status,
                description: description,
              ));
            }
          }
        }
        return jobs;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing Excel: $e");
      }
      rethrow;
    }
    return [];
  }

  String _getCellValue(List<Data?> row, int index) {
    if (index >= row.length || row[index] == null) return '';
    return row[index]!.value.toString();
  }

  Future<List<Job>> pickAndParseImage(ImageSource source) async {
    if (kIsWeb) {
      throw Exception("OCR Web üzerinde henüz desteklenmemektedir.");
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image == null) return [];

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      List<Job> jobs = [];
      String fullText = recognizedText.text;

      // Simple parsing logic:
      // Try to identify lines that look like jobs.
      // This assumes the checklist format from the user image.
      // Since I can't perfect it without seeing the text structure,
      // I'll create a single "Imported Job" with the full text as description
      // OR split by newlines and try to be smart.

      // Heuristic: If a line has "Daire" or numbers, treat it as a potential job.
      // For now, let's dump the text into one job per block or line if it's not structured.

      // Better: Create one Job containing the whole text in description so user can edit.
      // jobs.add(Job(
      //   id: _uuid.v4(),
      //   buildingName: "OCR İçe Aktarım",
      //   flatNumber: "",
      //   brand: "",
      //   counterType: "",
      //   status: "İncelenmeli",
      //   description: fullText,
      //   imageUrl: image.path
      // ));

      // Alternative: Try to split by lines
      List<String> lines = fullText.split('\n');
      for (String line in lines) {
         if (line.trim().isEmpty) continue;
         jobs.add(Job(
           id: _uuid.v4(),
           buildingName: "Otomatik", // Placeholder
           flatNumber: "",
           brand: "",
           counterType: "",
           status: "Taslak",
           description: line.trim(),
           imageUrl: image.path
         ));
      }

      textRecognizer.close();
      return jobs;

    } catch (e) {
      if (kDebugMode) {
        print("Error parsing Image: $e");
      }
      rethrow;
    }
  }
}
