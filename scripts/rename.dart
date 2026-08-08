// Renames the template into your project.
//
// Usage (from the project root):
//   dart run scripts/rename.dart --name "My App" --package my_app --bundle-id com.company.my_app
//
// What it does:
//   * pubspec.yaml           : name -> <package>
//   * lib/, test/            : package:mobile_template/ imports -> package:<package>/
//   * android                : namespace, applicationId, android:label, MainActivity package/path
//   * ios                    : PRODUCT_BUNDLE_IDENTIFIER, CFBundleDisplayName/CFBundleName
//   * lib/app                : MaterialApp title

library;

////dart run scripts/rename.dart --name "متجر الزهور" --package flower_store --bundle-id com.mycompany.flower_store

// Review the diff with git before committing.
import 'dart:io';

const String oldPackage = 'mobile_template';
const String oldBundleId = 'com.example.mobile_template';
const String oldAppName = 'App Template';

void main(List<String> args) {
  final Map<String, String> options = _parseArgs(args);
  final String? appName = options['name'];
  final String? package = options['package'];
  final String? bundleId = options['bundle-id'];

  if (appName == null || package == null || bundleId == null) {
    stderr.writeln(
      'Usage: dart run scripts/rename.dart --name "My App" --package my_app --bundle-id com.company.my_app',
    );
    exit(64);
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(package)) {
    stderr.writeln('Invalid --package "$package": use lower_snake_case.');
    exit(64);
  }
  if (!RegExp(r'^[a-zA-Z][\w]*(\.[a-zA-Z][\w]*)+$').hasMatch(bundleId)) {
    stderr.writeln('Invalid --bundle-id "$bundleId": use reverse-DNS form.');
    exit(64);
  }

  _replaceInFile('pubspec.yaml', {'name: $oldPackage': 'name: $package'});

  for (final String dir in ['lib', 'test']) {
    _replaceInTree(dir, {
      'package:$oldPackage/': 'package:$package/',
      oldAppName: appName,
    });
  }

  // Android
  _replaceInFile('android/app/build.gradle.kts', {oldBundleId: bundleId});
  // This template ships android:label="App Template"; a freshly `flutter create`d
  // project uses the package name instead, so replace whichever is present.
  _replaceInFile('android/app/src/main/AndroidManifest.xml', {
    'android:label="$oldAppName"': 'android:label="$appName"',
    'android:label="$oldPackage"': 'android:label="$appName"',
    oldBundleId: bundleId,
  });
  _moveMainActivity(bundleId);

  // iOS
  _replaceInFile('ios/Runner.xcodeproj/project.pbxproj', {
    oldBundleId: bundleId,
  });
  // Covers both CFBundleDisplayName and CFBundleName. They hold the same value
  // in this template, but a freshly `flutter create`d project sets them to the
  // title-cased name and the package name respectively — so both are handled.
  _replaceInFile('ios/Runner/Info.plist', {
    '<string>$oldAppName</string>': '<string>$appName</string>',
    '<string>$oldPackage</string>': '<string>$appName</string>',
  });

  stdout.writeln('Done. Renamed to "$appName" ($package / $bundleId).');
  stdout.writeln('Now run: flutter pub get && dart run build_runner build --delete-conflicting-outputs');
}

Map<String, String> _parseArgs(List<String> args) {
  final Map<String, String> options = {};
  for (int i = 0; i < args.length - 1; i++) {
    if (args[i].startsWith('--')) {
      options[args[i].substring(2)] = args[i + 1];
    }
  }
  return options;
}

void _replaceInFile(String path, Map<String, String> replacements) {
  final File file = File(path);
  if (!file.existsSync()) {
    stdout.writeln('Skipped (not found): $path');
    return;
  }
  String content = file.readAsStringSync();
  replacements.forEach((from, to) => content = content.replaceAll(from, to));
  file.writeAsStringSync(content);
  stdout.writeln('Updated: $path');
}

void _replaceInTree(String dir, Map<String, String> replacements) {
  final Directory directory = Directory(dir);
  if (!directory.existsSync()) return;
  for (final FileSystemEntity entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      String updated = content;
      replacements.forEach((from, to) => updated = updated.replaceAll(from, to));
      if (updated != content) {
        entity.writeAsStringSync(updated);
        stdout.writeln('Updated: ${entity.path}');
      }
    }
  }
}

void _moveMainActivity(String bundleId) {
  const String sourceRoot = 'android/app/src/main';
  final String oldRelativeDir = oldBundleId.replaceAll('.', '/');
  final String newRelativeDir = bundleId.replaceAll('.', '/');
  File? mainActivity;
  String? sourceDir;
  String? sourceSet;
  // The Kotlin source set directory is `kotlin` but the file extension is `.kt`,
  // so the two can't be derived from each other.
  const Map<String, String> sourceSets = {'java': 'java', 'kotlin': 'kt'};
  for (final MapEntry<String, String> entry in sourceSets.entries) {
    final String candidateDir = '$sourceRoot/${entry.key}/$oldRelativeDir';
    final File candidate = File('$candidateDir/MainActivity.${entry.value}');
    if (candidate.existsSync()) {
      mainActivity = candidate;
      sourceDir = candidateDir;
      sourceSet = entry.key;
      break;
    }
  }
  if (mainActivity == null || sourceDir == null || sourceSet == null) {
    stdout.writeln('Skipped MainActivity move (not found for $oldBundleId).');
    return;
  }
  final String extension = sourceSets[sourceSet]!;
  final String newDir = '$sourceRoot/$sourceSet/$newRelativeDir';
  Directory(newDir).createSync(recursive: true);
  final String content = mainActivity.readAsStringSync().replaceAll(
    'package $oldBundleId',
    'package $bundleId',
  );
  File('$newDir/MainActivity.$extension').writeAsStringSync(content);
  mainActivity.deleteSync();
  // Clean now-empty old directories.
  Directory currentDir = Directory(sourceDir);
  final Directory sourceRootDir = Directory('$sourceRoot/$sourceSet');
  while (currentDir.path != sourceRootDir.path && currentDir.existsSync() && currentDir.listSync().isEmpty) {
    final Directory parent = currentDir.parent;
    currentDir.deleteSync();
    currentDir = parent;
  }
  stdout.writeln('Moved MainActivity to $newDir');
}
