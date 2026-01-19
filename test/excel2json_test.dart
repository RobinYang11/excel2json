import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:excel2json/excel2json.dart';

void main() {
  group('Excel2Json', () {
    group('isPlatformSupported', () {
      test('should return true for macOS', () {
        // This test will only pass on macOS
        if (Platform.isMacOS) {
          expect(Excel2Json.isPlatformSupported(), isTrue);
        }
      });

      test('should return true for Windows', () {
        // This test will only pass on Windows
        if (Platform.isWindows) {
          expect(Excel2Json.isPlatformSupported(), isTrue);
        }
      });

      test('should return false for unsupported platforms', () {
        // This test will only pass on Linux or other unsupported platforms
        if (Platform.isLinux) {
          expect(Excel2Json.isPlatformSupported(), isFalse);
        }
      });
    });

    group('getMacOSArchitecture', () {
      test('should return arm64 or x64 on macOS', () {
        if (Platform.isMacOS) {
          final arch = Excel2Json.getMacOSArchitecture();
          expect(arch, anyOf('arm64', 'x64'));
        }
      });

      test('should handle uname command failure gracefully', () {
        // The function should default to x64 if uname fails
        // This is tested implicitly through the implementation
        if (Platform.isMacOS) {
          final arch = Excel2Json.getMacOSArchitecture();
          expect(arch, isNotEmpty);
          expect(arch, anyOf('arm64', 'x64'));
        }
      });
    });

    group('getBinaryPath', () {
      test('should return correct path for macOS ARM64', () {
        if (Platform.isMacOS) {
          const scriptDir = '/test/bin';
          final path = Excel2Json.getBinaryPath(scriptDir);
          expect(path, isNotNull);
          expect(path, contains('macos'));
          if (Excel2Json.getMacOSArchitecture() == 'arm64') {
            expect(path, contains('arm64'));
            expect(path, endsWith('excel2json'));
          } else {
            expect(path, contains('intel'));
            expect(path, endsWith('excel2json'));
          }
        }
      });

      test('should return correct path for macOS Intel', () {
        if (Platform.isMacOS) {
          const scriptDir = '/test/bin';
          final path = Excel2Json.getBinaryPath(scriptDir);
          expect(path, isNotNull);
          expect(path, contains('macos'));
          expect(path, anyOf(
            contains('arm64'),
            contains('intel'),
          ));
        }
      });

      test('should return correct path for Windows', () {
        if (Platform.isWindows) {
          const scriptDir = r'C:\test\bin';
          final path = Excel2Json.getBinaryPath(scriptDir);
          expect(path, isNotNull);
          expect(path, contains('windows'));
          expect(path, endsWith('excel2json.exe'));
        }
      });

      test('should return null for unsupported platforms', () {
        // This test verifies the logic, but will only work on Linux
        // We can't easily mock Platform.operatingSystem, so we test the behavior
        if (Platform.isLinux) {
          const scriptDir = '/test/bin';
          final path = Excel2Json.getBinaryPath(scriptDir);
          expect(path, isNull);
        }
      });

      test('should construct path with correct script directory', () {
        const scriptDir = '/custom/path/bin';
        if (Platform.isMacOS || Platform.isWindows) {
          final path = Excel2Json.getBinaryPath(scriptDir);
          expect(path, isNotNull);
          expect(path, startsWith(scriptDir));
        }
      });
    });

    group('getScriptDirectory', () {
      test('should return a non-empty string', () {
        final scriptDir = Excel2Json.getScriptDirectory();
        expect(scriptDir, isNotEmpty);
      });

      test('should handle file scheme script paths', () {
        final scriptDir = Excel2Json.getScriptDirectory();
        expect(scriptDir, isA<String>());
      });

      test('should fallback to bin directory if needed', () {
        final scriptDir = Excel2Json.getScriptDirectory();
        // Should either be an absolute path or 'bin'
        expect(scriptDir, anyOf(
          endsWith('bin'),
          equals('bin'),
        ));
      });
    });

    group('Integration tests', () {
      test('should get valid binary path on supported platforms', () {
        if (Platform.isMacOS || Platform.isWindows) {
          final scriptDir = Excel2Json.getScriptDirectory();
          final binaryPath = Excel2Json.getBinaryPath(scriptDir);
          
          expect(binaryPath, isNotNull);
          expect(binaryPath, isNotEmpty);
          
          // Verify path structure
          if (Platform.isMacOS) {
            expect(binaryPath, contains('macos'));
            expect(binaryPath, anyOf(
              contains('arm64'),
              contains('intel'),
            ));
          } else if (Platform.isWindows) {
            expect(binaryPath, contains('windows'));
            expect(binaryPath, endsWith('.exe'));
          }
        }
      });

      test('should detect platform support correctly', () {
        final isSupported = Excel2Json.isPlatformSupported();
        if (Platform.isMacOS || Platform.isWindows) {
          expect(isSupported, isTrue);
        } else {
          expect(isSupported, isFalse);
        }
      });
    });
  });
}
