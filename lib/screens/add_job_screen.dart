import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../models/job.dart';
import '../services/job_service.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buildingNameController = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _counterTypeController = TextEditingController();
  final _statusController = TextEditingController(text: 'ONAYLANDI');
  final _descriptionController = TextEditingController();

  XFile? _pickedImage;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newJob = Job(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        buildingName: _buildingNameController.text,
        flatNumber: _flatNumberController.text,
        brand: _brandController.text,
        counterType: _counterTypeController.text,
        status: _statusController.text,
        description: _descriptionController.text,
        imageUrl: _pickedImage?.path,
      );

      Provider.of<JobService>(context, listen: false).addJob(newJob);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İş Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_buildingNameController, 'Bina Adı'),
              _buildTextField(_flatNumberController, 'Daire No'),
              _buildTextField(_brandController, 'Marka'),
              _buildTextField(_counterTypeController, 'Sayaç Türü'),
              _buildTextField(_statusController, 'Durum / Tutar'),
              _buildTextField(
                _descriptionController,
                'Açıklama',
                required: false,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ],
              ),
              if (_pickedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: kIsWeb
                      ? Image.network(_pickedImage!.path, height: 200)
                      : Image.file(File(_pickedImage!.path), height: 200),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) =>
                  value == null || value.isEmpty ? '$label gerekli' : null
            : null,
      ),
    );
  }
}
