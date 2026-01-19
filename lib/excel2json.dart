import 'dart:io';

/// Excel to JSON converter utilities
class Excel2Json {
  /// Get the path to the platform-specific binary
  static String? getBinaryPath(String scriptDir) {
    final os = Platform.operatingSystem;

    if (os == 'macos') {
      // Check architecture for macOS
      final arch = getMacOSArchitecture();
      if (arch == 'arm64') {
        return '$scriptDir/macos/arm64/excel2json';
      } else if (arch == 'x64') {
        return '$scriptDir/macos/intel/excel2json';
      }
    } else if (os == 'windows') {
      return '$scriptDir/windows/excel2json.exe';
    }

    return null;
  }

  /// Get the directory where the script is located
  static String getScriptDirectory() {
    final script = Platform.script;
    if (script.scheme == 'file') {
      final scriptPath = File(script.toFilePath()).parent.path;
      
      // Check if we're running from pub.dev installed package
      // Script path will be like: .dart_tool/pub/bin/excel2json/
      if (scriptPath.contains('.dart_tool/pub/bin')) {
        // Find the actual package directory in pub cache
        final packageBinDir = _findPackageBinInPubCache(scriptPath);
        if (packageBinDir != null && Directory(packageBinDir).existsSync()) {
          return packageBinDir;
        }
      }
      
      // Check if we're running from the package directory
      if (scriptPath.endsWith('bin')) {
        return scriptPath;
      }
      
      // For pub run or other scenarios, use the package's bin directory
      // Try to find the bin directory relative to current working directory
      final cwd = Directory.current.path;
      final packageBin = '$cwd/bin';
      if (Directory(packageBin).existsSync()) {
        return packageBin;
      }
      return scriptPath;
    }
    // For pub run, try to get from package root
    final cwd = Directory.current.path;
    final packageBin = '$cwd/bin';
    if (Directory(packageBin).existsSync()) {
      return packageBin;
    }
    return 'bin';
  }

  /// Find package bin directory in pub cache when installed from pub.dev
  static String? _findPackageBinInPubCache(String scriptPath) {
    try {
      // When installed from pub.dev:
      // Script is at: .dart_tool/pub/bin/excel2json/excel2json.dart
      // Package is at: .dart_tool/pub/cache/hosted/pub.dev/excel2json-{version}/
      
      final cwd = Directory.current.path;
      
      // Try to find in project's pub cache first
      final pubCacheDir = Directory('$cwd/.dart_tool/pub/cache/hosted/pub.dev');
      if (pubCacheDir.existsSync()) {
        final entries = pubCacheDir.listSync();
        for (final entry in entries) {
          if (entry is Directory) {
            final dirName = entry.path.split(Platform.pathSeparator).last;
            if (dirName.startsWith('excel2json-')) {
              final binDir = '${entry.path}/bin';
              if (Directory(binDir).existsSync()) {
                return binDir;
              }
            }
          }
        }
      }
      
      // Try global pub cache
      final homeDir = Platform.environment['HOME'] ?? 
                     Platform.environment['USERPROFILE'] ?? '';
      if (homeDir.isNotEmpty) {
        final globalPubCache = Directory('$homeDir/.pub-cache/hosted/pub.dev');
        if (globalPubCache.existsSync()) {
          final entries = globalPubCache.listSync();
          for (final entry in entries) {
            if (entry is Directory) {
              final dirName = entry.path.split(Platform.pathSeparator).last;
              if (dirName.startsWith('excel2json-')) {
                final binDir = '${entry.path}/bin';
                if (Directory(binDir).existsSync()) {
                  return binDir;
                }
              }
            }
          }
        }
      }
      
      // Alternative: try to resolve from script path
      // Script path: .dart_tool/pub/bin/excel2json/
      // Go up to find .dart_tool, then navigate to cache
      if (scriptPath.contains('.dart_tool')) {
        final parts = scriptPath.split(Platform.pathSeparator);
        final dartToolIndex = parts.indexWhere((p) => p == '.dart_tool');
        if (dartToolIndex >= 0) {
          final basePath = parts.sublist(0, dartToolIndex).join(Platform.pathSeparator);
          final cachePath = '$basePath${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}pub${Platform.pathSeparator}cache${Platform.pathSeparator}hosted${Platform.pathSeparator}pub.dev';
          final cacheDir = Directory(cachePath);
          if (cacheDir.existsSync()) {
            final entries = cacheDir.listSync();
            for (final entry in entries) {
              if (entry is Directory) {
                final dirName = entry.path.split(Platform.pathSeparator).last;
                if (dirName.startsWith('excel2json-')) {
                  final binDir = '${entry.path}/bin';
                  if (Directory(binDir).existsSync()) {
                    return binDir;
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore errors and fall back to other methods
    }
    return null;
  }

  /// Detect macOS architecture
  static String getMacOSArchitecture() {
    try {
      final result = Process.runSync('uname', ['-m']);
      final arch = result.stdout.toString().trim();
      if (arch == 'arm64' || arch == 'aarch64') {
        return 'arm64';
      } else {
        return 'x64';
      }
    } catch (e) {
      // Default to x64 if detection fails
      return 'x64';
    }
  }

  /// Check if the current platform is supported
  static bool isPlatformSupported() {
    final os = Platform.operatingSystem;
    return os == 'macos' || os == 'windows';
  }
}
