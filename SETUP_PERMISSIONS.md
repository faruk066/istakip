# Setup Permissions

This project currently contains configuration for Web (`web/`).

If you decide to add Android or iOS platforms (using `flutter create .`), you **must** add the following permissions for the Camera and Photo Library features to work:

## iOS (`ios/Runner/Info.plist`)

Add the following keys to your `Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>İş listesi fotoğrafını çekmek için kamera izni gereklidir.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>İş listesi fotoğrafını seçmek için galeri izni gereklidir.</string>
```

## Android (`android/app/src/main/AndroidManifest.xml`)

Ensure you have the following permissions (though usually handled by the plugin, explicit declaration is safer):

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Note on Web
OCR functionality (`google_mlkit_text_recognition`) is currently **NOT** supported on Flutter Web. The "Fotoğraf ile Yükle" feature will show an error message if used on the web. Excel import works on all platforms.
