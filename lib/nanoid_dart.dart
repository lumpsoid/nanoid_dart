import 'dart:math';
import 'dart:typed_data';

/// The default URL-safe alphabet used by Nano ID.
const String urlAlphabet =
    'useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict';

final _random = Random.secure();

// Compute step size (How many random bytes needed to likely fill size)
// We allocate a fixed buffer based on the size
// Formula: (ceil(1.6 * mask * size / alphabetLength)) rounded up to next multiple of 4
int _calcStep({
  required int alphabetLength,
  required int mask,
  required int size,
}) => ((1.6 * mask * size / alphabetLength).ceil() + 3) & ~3;

/// A factory that returns a pre-optimized function for a specific alphabet.
String customAlphabet(String alphabet, int size) {
  final int alphabetLength = alphabet.length;

  // Compute bitmask (e.g., length 62 becomes mask 63)
  // This is the "Mask" part of "Mask and Retry"
  final int mask = (2 << (log(alphabetLength - 1) / ln2).floor()) - 1;

  final int currentStep = _calcStep(
    alphabetLength: alphabetLength,
    mask: mask,
    size: size,
  );
  // Initial buffer
  final Uint8List stepBuffer = Uint8List(currentStep);

  final StringBuffer idBuilder = StringBuffer();

  while (true) {
    // Fill buffer using 32-bit chunks to minimize Random.secure() calls
    for (var i = 0; i < currentStep; i += 4) {
      final int val = _random.nextInt(0xFFFFFFFF);
      stepBuffer[i] = val & 0xFF;
      stepBuffer[i + 1] = (val >> 8) & 0xFF;
      stepBuffer[i + 2] = (val >> 16) & 0xFF;
      stepBuffer[i + 3] = (val >> 24) & 0xFF;
    }

    // "Retry" logic: Apply mask and skip indices outside alphabet range
    for (var i = 0; i < currentStep; i++) {
      final int alphabetIndex = stepBuffer[i] & mask;
      if (alphabetIndex < alphabetLength) {
        idBuilder.write(alphabet[alphabetIndex]);
        if (idBuilder.length == size) {
          return idBuilder.toString();
        }
      }
    }
  }
}

// Usage for the default nanoid (21 chars, urlAlphabet)
String nanoid([int size = 21]) {
  return customAlphabet(urlAlphabet, size);
}
