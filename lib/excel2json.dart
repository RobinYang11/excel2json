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
    } else if (os == 'linux') {
      // Check architecture for Linux
      final arch = getLinuxArchitecture();
      if (arch == 'arm64' || arch == 'aarch64') {
        return '$scriptDir/linux/arm64/excel2json';
      } else {
        return '$scriptDir/linux/x64/excel2json';
      }
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
        // If we can't find the cache directory, this is an error
        // Don't fallback to scriptPath as it won't have the binaries
        throw Exception(
          'Cannot find excel2json package in pub cache. '
          'Please run: flutter pub get\n'
          'Searched in:\n'
          '- ${Directory.current.path}/.dart_tool/pub/cache/hosted/pub.dev\n'
          '- ${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '~'}/.pub-cache/hosted/pub.dev'
        );
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
      
      // Strategy 1: Try to resolve from script path
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
            // Sort to get the latest version first
            final sortedEntries = entries.whereType<Directory>()
                .where((d) {
                  final dirName = d.path.split(Platform.pathSeparator).last;
                  return dirName.startsWith('excel2json-');
                })
                .toList()
              ..sort((a, b) {
                // Sort by version number (descending)
                final aVersion = a.path.split(Platform.pathSeparator).last.replaceFirst('excel2json-', '');
                final bVersion = b.path.split(Platform.pathSeparator).last.replaceFirst('excel2json-', '');
                return bVersion.compareTo(aVersion);
              });
            for (final entry in sortedEntries) {
              final binDir = '${entry.path}/bin';
              if (Directory(binDir).existsSync()) {
                // Verify that the bin directory actually contains the platform-specific binaries
                final hasMacos = Directory('$binDir/macos').existsSync() || 
                                 Directory('$binDir/windows').existsSync();
                if (hasMacos) {
                  return binDir;
                }
              }
            }
          }
        }
      }
      
      // Strategy 2: Try to find in project's pub cache
      final pubCacheDir = Directory('$cwd/.dart_tool/pub/cache/hosted/pub.dev');
      if (pubCacheDir.existsSync()) {
        final entries = pubCacheDir.listSync();
        // Sort to get the latest version first
        final sortedEntries = entries.whereType<Directory>()
            .where((d) {
              final dirName = d.path.split(Platform.pathSeparator).last;
              return dirName.startsWith('excel2json-');
            })
            .toList()
          ..sort((a, b) {
            // Sort by version number (descending)
            final aVersion = a.path.split(Platform.pathSeparator).last.replaceFirst('excel2json-', '');
            final bVersion = b.path.split(Platform.pathSeparator).last.replaceFirst('excel2json-', '');
            return bVersion.compareTo(aVersion);
          });
        for (final entry in sortedEntries) {
          final binDir = '${entry.path}/bin';
          if (Directory(binDir).existsSync()) {
            // Verify that the bin directory actually contains the platform-specific binaries
            final hasMacos = Directory('$binDir/macos').existsSync() || 
                             Directory('$binDir/windows').existsSync();
            if (hasMacos) {
              return binDir;
            }
          }
        }
      }
      
      // Strategy 3: Try global pub cache
      final homeDir = Platform.environment['HOME'] ?? 
                     Platform.environment['USERPROFILE'] ?? '';
      if (homeDir.isNotEmpty) {
        final globalPubCache = Directory('$homeDir/.pub-cache/hosted/pub.dev');
        if (globalPubCache.existsSync()) {
          final entries = globalPubCache.listSync();
          // Sort to get the latest version first
          final sortedEntries = entries.whereType<Directory>()
              .where((d) {
                final dirName = d.path.split(Platform.pathSeparator).last;
                return dirName.startsWith('excel2json-');
              })
              .toList()
            ..sort((a, b) {
              // Sort by version number (descending)
              final aVersion = a.path.split(Platform.pathSeparator).last.replaceFirst('excel2json-', '');
              final bVersion = b.path.split(Platform.pathSeparator).last.replaceFirst('excel2json-', '');
              return bVersion.compareTo(aVersion);
            });
          for (final entry in sortedEntries) {
            final binDir = '${entry.path}/bin';
            if (Directory(binDir).existsSync()) {
              // Verify that the bin directory actually contains the platform-specific binaries
              final hasMacos = Directory('$binDir/macos').existsSync() || 
                               Directory('$binDir/windows').existsSync();
              if (hasMacos) {
                return binDir;
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
    return os == 'macos' || os == 'windows' || os == 'linux';
  }

  /// Detect Linux architecture
  static String getLinuxArchitecture() {
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
}
