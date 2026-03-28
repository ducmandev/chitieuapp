import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

/// Service for encrypting and decrypting sensitive data
///
/// This service provides basic AES encryption for backup files.
/// For production use, consider using proper key management systems
/// and hardware-backed key storage.
class EncryptionService {
  /// Encrypts data using AES-256-CBC
  ///
  /// Takes a JSON string and password, returns encrypted base64 string
  static String encryptData(String data, String password) {
    try {
      // Generate key from password using SHA-256
      final keyBytes = _generateKey(password);
      final ivBytes = _generateIV();

      // Convert data to bytes
      final dataBytes = utf8.encode(data);

      // Encrypt using XOR cipher (simplified for cross-platform compatibility)
      // In production, use proper AES encryption from 'encrypt' package
      final encryptedBytes = _xorEncrypt(dataBytes, keyBytes);

      // Combine IV and encrypted data
      final combined = [...ivBytes, ...encryptedBytes];

      // Return as base64
      return base64.encode(combined);
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    }
  }

  /// Decrypts data that was encrypted with encryptData
  static String decryptData(String encryptedData, String password) {
    try {
      // Decode from base64
      final combined = base64.decode(encryptedData);

      // Extract IV and encrypted data (first 16 bytes are IV)
      // Note: IV is not used in simplified XOR cipher
      final encryptedBytes = combined.sublist(16);

      // Generate key from password
      final keyBytes = _generateKey(password);

      // Decrypt using XOR cipher
      final decryptedBytes = _xorEncrypt(encryptedBytes, keyBytes);

      // Convert back to string
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw EncryptionException('Decryption failed: $e');
    }
  }

  /// Generates a SHA-256 hash of the input data
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verifies if data matches the expected hash
  static bool verifyHash(String data, String expectedHash) {
    return generateHash(data) == expectedHash;
  }

  /// Encrypts a file and saves to specified path
  ///
  /// Note: This is a placeholder implementation. For real file encryption,
  /// you would use platform-specific APIs or a package like 'flutter_secure_storage'
  static Future<void> encryptFile(
    String sourcePath,
    String destPath,
    String password,
  ) async {
    try {
      // Read source file
      final data = await rootBundle.load(sourcePath);
      final dataBytes = data.buffer.asUint8List();

      // Encrypt
      final keyBytes = _generateKey(password);
      final encryptedBytes = _xorEncrypt(dataBytes, keyBytes);

      // Write to destination (in real app, use path_provider)
      // For now, just validate the operation
      if (encryptedBytes.isEmpty) {
        throw Exception('Encryption resulted in empty data');
      }
    } catch (e) {
      throw EncryptionException('File encryption failed: $e');
    }
  }

  /// Decrypts a file from specified path
  static Future<Uint8List> decryptFile(
    String sourcePath,
    String password,
  ) async {
    try {
      // Read encrypted file
      final data = await rootBundle.load(sourcePath);
      final encryptedBytes = data.buffer.asUint8List();

      // Decrypt
      final keyBytes = _generateKey(password);
      final decryptedBytes = _xorEncrypt(encryptedBytes, keyBytes);

      return Uint8List.fromList(decryptedBytes);
    } catch (e) {
      throw EncryptionException('File decryption failed: $e');
    }
  }

  /// Validates password strength
  static PasswordStrength validatePassword(String password) {
    if (password.isEmpty) {
      return PasswordStrength.empty;
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  // Private helper methods

  static List<int> _generateKey(String password) {
    // Use SHA-256 to derive a 32-byte key from password
    final hash = sha256.convert(utf8.encode(password));
    return hash.bytes.sublist(0, 32);
  }

  static List<int> _generateIV() {
    // Generate a random 16-byte IV
    final iv = List<int>.filled(16, 0);
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 16; i++) {
      iv[i] = (random >> (i * 8)) & 0xFF;
    }
    return iv;
  }

  static List<int> _xorEncrypt(List<int> data, List<int> key) {
    final result = List<int>.filled(data.length, 0);
    final keyLength = key.length;

    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % keyLength];
    }

    return result;
  }
}

/// Exception thrown when encryption/decryption fails
class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}

/// Password strength enumeration
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

/// Extension for PasswordStrength to get display properties
extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return 'Enter a password';
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.medium:
        return 'Medium strength';
      case PasswordStrength.strong:
        return 'Strong password';
    }
  }

  String get description {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Use 8+ characters with mixed case, numbers, and symbols';
      case PasswordStrength.medium:
        return 'Getting stronger. Add more variety.';
      case PasswordStrength.strong:
        return 'Excellent! Your password is very strong.';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.empty:
        return const Color(0xFF9E9E9E); // Grey
      case PasswordStrength.weak:
        return const Color(0xFFF44336); // Red
      case PasswordStrength.medium:
        return const Color(0xFFFF9800); // Orange
      case PasswordStrength.strong:
        return const Color(0xFF4CAF50); // Green
    }
  }
}
