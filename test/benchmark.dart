import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:nanoid/nanoid.dart' as v1;
import 'package:nanoid_dart/nanoid_dart.dart' as v2;

// -----------------------------------------------------------------------------
// BENCHMARK CLASSES
// -----------------------------------------------------------------------------

class NanoIdV1Benchmark extends BenchmarkBase {
  NanoIdV1Benchmark() : super('Implementation 1 (Concatenation)');
  @override
  void run() => v1.nanoid(21);
}

class NanoIdV2Benchmark extends BenchmarkBase {
  NanoIdV2Benchmark() : super('Implementation 2 (Mask & Retry)');
  @override
  void run() => v2.nanoid(21);
}

void main() {
  print('Starting Benchmarks (size=21)...\n');
  NanoIdV1Benchmark().report();
  NanoIdV2Benchmark().report();
}
