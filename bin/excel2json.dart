#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:excel2json/excel2json.dart';

/// Excel to JSON converter entry point
/// This script detects the platform and executes the corresponding binary
void main(List<String> arguments) async {
  final scriptDir = Excel2Json.getScriptDirectory();
  final binaryPath = Excel2Json.getBinaryPath(scriptDir);
  
  if (binaryPath == null) {
    print('❌ Error: Unsupported platform: ${Platform.operatingSystem}');
    print('Supported platforms: macOS (Intel/ARM), Windows');
    exit(1);
  }

  // Check if binary exists
  final binary = File(binaryPath);
  if (!await binary.exists()) {
    print('❌ Error: Binary not found at: $binaryPath');
    exit(1);
  }

  // Make binary executable on Unix-like systems
  if (Platform.isMacOS || Platform.isLinux) {
    try {
      await Process.run('chmod', ['+x', binaryPath]);
    } catch (e) {
      // Ignore chmod errors
    }
  }

  // Execute the binary with all arguments
  final process = await Process.start(
    binaryPath,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await process.exitCode);
}

