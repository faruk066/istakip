import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:job_tracker_web/services/job_service.dart';
import 'package:job_tracker_web/main.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class MockImagePicker extends ImagePickerPlatform {
  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return PickedFile('path/to/mock/image.png');
  }

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions? options,
  }) async {
    return XFile('path/to/mock/image.png');
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return XFile('path/to/mock/image.png');
  }
}

void main() {
  setUpAll(() {
    ImagePickerPlatform.instance = MockImagePicker();
  });

  testWidgets('Full flow: Dashboard loads, Add Job, Verify new entry', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => JobService())],
        child: const JobTrackerApp(),
      ),
    );

    // 1. Verify Dashboard loads
    expect(
      find.text('İş Takip Listesi'),
      findsOneWidget,
    ); // Title from main.dart
    expect(find.textContaining('ALTAŞ'), findsOneWidget); // Mock data

    // 2. Navigate to Add Job Screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Yeni İş Ekle'), findsOneWidget);

    // 3. Fill out the form
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Bina Adı'),
      'Test Binası',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Daire No'),
      '101',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Marka'),
      'Test Marka',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Sayaç Türü'),
      'Su',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Durum / Tutar'),
      'ONAYLANDI',
    );

    // 4. "Pick Image" (simulated by MockImagePicker)
    final galeriButton = find.text('Galeri');
    await tester.ensureVisible(galeriButton);
    await tester.tap(galeriButton);
    await tester.pump(); // Allow future to complete

    // 5. Submit
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle(); // Walt for navigation back

    // 6. Verify we are back on Dashboard and new item is there
    expect(find.text('İş Takip Listesi'), findsOneWidget);
    expect(find.text('Test Binası'), findsOneWidget); // New Job
    expect(find.text('101'), findsOneWidget);
  });
}
