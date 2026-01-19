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
