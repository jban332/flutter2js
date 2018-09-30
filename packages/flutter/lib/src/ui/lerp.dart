part of dart.ui;

/// Linearly interpolate between two numbers.
double lerpDouble(num a, num b, double t) {
  if (a == null && b == null) return null;
  if (a == null) a = 0.0;
  if (b == null) b = 0.0;
  return a + (b - a) * t;
}
