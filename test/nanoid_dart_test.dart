import 'dart:math';

import 'package:test/test.dart';
import 'package:nanoid_dart/nanoid_dart.dart';

void main() {
  group('NanoId Core', () {
    test('generates 21 characters by default', () {
      expect(nanoid().length, 21);
    });

    test('generates custom lengths', () {
      for (var i = 1; i <= 1000; i++) {
        expect(nanoid(i).length, i);
      }
    });

    test('customAlphabet works correctly', () {
      final id = customAlphabet('0123456789ABCDEF', 5);
      expect(id.length, 5);
      expect(RegExp(r'^[0-9A-F]+$').hasMatch(id), isTrue);
    });

    test('distribution is uniform (Simple Chi-Squared check)', () {
      final alphabet = 'abcde';
      final counts = <String, int>{};
      final total = 50000;

      for (var i = 0; i < total; i++) {
        final char = customAlphabet(alphabet, 1);
        counts[char] = (counts[char] ?? 0) + 1;
      }

      final expected = total / alphabet.length;
      for (var char in alphabet.split('')) {
        final deviation = (counts[char]! - expected).abs();
        // Allow 5% margin of error for 50k samples
        expect(deviation, lessThan(expected * 0.05));
      }
    });
  });
  group('Statistical Tests', () {
    test('Character Distribution Uniformity', () {
      const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
      const iterations = 100000;
      const size = 10;

      final charCounts = <String, int>{};
      for (var char in alphabet.split('')) {
        charCounts[char] = 0;
      }

      // Generate IDs and count occurrences
      for (var i = 0; i < iterations; i++) {
        final id = customAlphabet(alphabet, size);
        for (var j = 0; j < id.length; j++) {
          final char = id[j];
          charCounts[char] = charCounts[char]! + 1;
        }
      }

      // Chi-Squared Statistic Calculation
      // Formula: Σ (Observed - Expected)^2 / Expected
      final double expected = (iterations * size) / alphabet.length;
      double chiSquared = 0;

      charCounts.forEach((char, observed) {
        chiSquared += pow(observed - expected, 2) / expected;
      });

      // For a significance level of α = 0.01 and degrees of freedom (36-1) = 35
      // The critical value is approximately 57.34.
      // If our chiSquared is lower, we fail to reject the null hypothesis (it is uniform).
      expect(
        chiSquared,
        lessThan(60.0),
        reason: 'Distribution is biased. Chi-squared: $chiSquared',
      );
    });

    test('Uniqueness / Collision Resistance', () {
      final Set<String> seen = {};
      const count = 50000;

      for (var i = 0; i < count; i++) {
        final id = nanoid(15);
        expect(
          seen.contains(id),
          isFalse,
          reason: 'Collision detected at iteration $i',
        );
        seen.add(id);
      }
    });

    test('Bitwise Entropy (Run Test)', () {
      // This tests for "runs" of the same character, which would indicate a flaw in randomness
      final alphabet = 'ab'; // Small alphabet makes patterns obvious
      final id = customAlphabet(alphabet, 1000);

      int runs = 1;
      for (int i = 1; i < id.length; i++) {
        if (id[i] != id[i - 1]) runs++;
      }

      // For a string of 1000 binary chars, the expected number of runs is (N/2) + 1 = 501
      // Standard deviation is sqrt((N-1)/4) ≈ 15.8
      // We expect runs to be within 3 standard deviations (454 to 548)
      expect(runs, greaterThan(450));
      expect(runs, lessThan(550));
    });

    test('No Modulo Bias in Custom Alphabets', () {
      // Test an alphabet size that is NOT a power of 2 (e.g., 37)
      // Modulo bias usually over-represents the first (N % total) characters
      const alphabet = '0123456789abcdefghijklmnopqrstuvwxyz!';
      final Map<String, int> counts = {};

      for (var i = 0; i < 74000; i++) {
        final char = customAlphabet(alphabet, 1);
        counts[char] = (counts[char] ?? 0) + 1;
      }

      final firstCharCount = counts[alphabet[0]]!;
      final lastCharCount = counts[alphabet[alphabet.length - 1]]!;

      // If modulo bias existed, the first few characters would be significantly
      // more frequent than the last ones.
      final difference = (firstCharCount - lastCharCount).abs();
      final threshold = (74000 / alphabet.length) * 0.1; // 10% tolerance

      expect(
        difference,
        lessThan(threshold.toInt()),
        reason:
            'Modulo bias detected: first char count ($firstCharCount) vs last ($lastCharCount)',
      );
    });
  });
}
