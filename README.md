# Nano ID for Dart

A tiny, secure, URL-friendly, unique string ID generator for Dart. This implementation is based on the [original Nano ID](https://github.com/ai/nanoid) for JavaScript, utilizing `Random.secure()` for cryptographically strong IDs.

## Features

- **Secure**: Uses `dart:math`'s `Random.secure()` to ensure IDs are unpredictable.
- **Fast**: Optimized using **32-bit chunking** and a "Mask and Retry" approach.
- **Customizable**: Easily define your own alphabet and ID length.

## Performance Optimization: 32-bit Chunking

Calling `Random.secure()` frequently can be expensive as it interfaces with the OS entropy source. This library optimizes generation by:

1.  **Buffered Generation**: It calculates the required number of bytes in advance.
2.  **Integer Chunking**: It pulls **32 bits** of randomness at once using `_random.nextInt(0xFFFFFFFF)` rather than generating individual bytes.
3.  **Bitwise Dissection**: The 32-bit integer is split into four 8-bit integers (bytes) using bit-shifting (>>) and bitwise AND (&) operations.

## Math Behind the Efficiency

The library calculates a bitmask to map random bytes to the size of your alphabet. The "Step Size" is calculated using the following formula to minimize the number of iterations:

$$
\text{step} = \left\lceil \frac{1.6 \times \text{mask} \times \text{size}}{\text{alphabetLength}} \right\rceil
$$

The bitmask is computed as:

$$
\text{mask} = (2^{\lfloor \log_2(\text{alphabetLength}-1) \rfloor + 1}) - 1
$$

## Usage

### Default ID (21 characters)
```dart
import 'nanoid.dart';

void main() {
  var id = nanoid(); 
  print(id); // Example: "V67_K-j_V6m0Q9qN_v6mQ"
}
```

### Custom Alphabet and Length
```dart
final String alphabet = '0123456789ABCDEF';
final int size = 12;

var id = customAlphabet(alphabet, size);
print(id); // Example: "6A1F8D2B90E3"
```

## Technical Details

### Alphabet Overview

| Characteristic | Value |
| :--- | :--- |
| **Default Length** | 21 |
| **Characters** | `A-Z`, `a-z`, `0-9`, `_`, `-` |

## License

This project is open source and available under the MIT License.