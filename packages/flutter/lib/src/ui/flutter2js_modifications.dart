part of dart.ui;

/// The [Window] singleton. This object exposes the size of the display, the
/// core scheduler API, the input event callback, the graphics drawing API, and
/// other such core services.
Window get window => flutter2js.window;

/// Opaque handle to raw decoded image data (pixels).
///
/// To obtain an Image object, use [decodeImageFromList].
///
/// To draw an Image, use one of the methods on the [Canvas] class, such as
/// [Canvas.drawImage].
abstract class Image {
  /// The number of image pixels along the image's horizontal axis.
  int get width;

  /// The number of image pixels along the image's vertical axis.
  int get height;

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  void dispose();

  @override
  String toString() => '[$width\u00D7$height]';
}

/// Instantiates an image codec [Codec] object.
///
/// [list] is the binary image data (e.g a PNG or GIF binary data).
/// The data can be for either static or animated images.
///
/// The following image formats are supported: {@macro flutter.package:flutter/ui.dart.imageFormats}
///
/// The returned future can complete with an error if the image decoding has
/// failed.
Future<Codec> instantiateImageCodec(Uint8List list) =>
    flutter2js.PlatformPlugin.current.instantiateImageCodec(list);

/// Creates an image from a list of bytes.
///
/// This function attempts to interpret the given bytes an image. If successful,
/// the returned [Future] resolves to the decoded image. Otherwise, the [Future]
/// resolves to null.
Future<Image> decodeImageFromList(Uint8List list, void complete(Image image)) {
  return flutter2js.PlatformPlugin.current.decodeImageFromList(list, complete);
}

/// A filter operation to apply to a raster image.
///
/// See [SceneBuilder.pushBackdropFilter].
class ImageFilter {
  // The following fields exist only in Flutter2js!
  final double sigmaX;
  final double sigmaY;

  /// Creates an image filter that applies a Gaussian blur.
  ImageFilter.blur({this.sigmaX: 0.0, this.sigmaY: 0.0}) {}
}

/// A shader (as used by [Paint.shader]) that tiles an image.
class ImageShader extends Shader {
  // The following fields exist only in Flutter2js!
  final Image image;
  final TileMode tmx;
  final TileMode tmy;
  final Float64List matrix4;

  /// Creates an image-tiling shader. The first argument specifies the image to
  /// tile. The second and third arguments specify the [TileMode] for the x
  /// direction and y direction respectively. The fourth argument gives the
  /// matrix to apply to the effect. All the arguments are required and must not
  /// be null.
  ImageShader(this.image, this.tmx, this.tmy, this.matrix4) {
    assert(image != null); // image is checked on the engine side
    assert(tmx != null);
    assert(tmy != null);
    assert(matrix4 != null);
    if (matrix4.length != 16)
      throw new ArgumentError('"matrix4" must have 16 entries.');
  }
}

/// A set of vertex data used by [Canvas.drawVertices].
class Vertices {
  // The following fields exist only in Flutter2js!
  final VertexMode mode;
  final List<Offset> positions;
  final List<Offset> textureCoordinates;
  final List<Color> colors;
  final List<int> indices;

  Vertices(
    this.mode,
    this.positions, {
    this.textureCoordinates,
    this.colors,
    this.indices,
  }) {
    assert(mode != null);
    assert(positions != null);
    if (textureCoordinates != null &&
        textureCoordinates.length != positions.length)
      throw new ArgumentError(
          '"positions" and "textureCoordinates" lengths must match.');
    if (colors != null && colors.length != positions.length)
      throw new ArgumentError('"positions" and "colors" lengths must match.');
    if (indices != null &&
        indices.any((int i) => i < 0 || i >= positions.length))
      throw new ArgumentError(
          '"indices" values must be valid indices in the positions list.');
  }

  Vertices.raw(
    this.mode,
    this.positions, {
    this.textureCoordinates,
    this.colors,
    this.indices,
  }) {
    assert(mode != null);
    assert(positions != null);
    if (textureCoordinates != null &&
        textureCoordinates.length != positions.length)
      throw new ArgumentError(
          '"positions" and "textureCoordinates" lengths must match.');
    if (colors != null && colors.length * 2 != positions.length)
      throw new ArgumentError('"positions" and "colors" lengths must match.');
    if (indices != null &&
        indices.any((int i) => i < 0 || i >= positions.length))
      throw new ArgumentError(
          '"indices" values must be valid indices in the positions list.');
  }
}

/// A shader (as used by [Paint.shader]) that renders a color gradient.
///
/// There are two useful types of gradients, created by [new Gradient.linear]
/// and [new Gradient.radial].
class Gradient extends Shader {
  Gradient();

  /// Creates a linear gradient from `from` to `to`.
  ///
  /// If `colorStops` is provided, `colorStops[i]` is a number from 0.0 to 1.0
  /// that specifies where `color[i]` begins in the gradient. If `colorStops` is
  /// not provided, then only two stops, at 0.0 and 1.0, are implied (and
  /// `color` must therefore only have two entries).
  ///
  /// The behavior before `from` and after `to` is described by the `tileMode`
  /// argument. For details, see the [TileMode] enum.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/dart-ui/tile_mode_clamp_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/dart-ui/tile_mode_mirror_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/dart-ui/tile_mode_repeated_linear.png)
  ///
  /// If `from`, `to`, `colors`, or `tileMode` are null, or if `colors` or
  /// `colorStops` contain null values, this constructor will throw a
  /// [NoSuchMethodError].
  factory Gradient.linear(
    Offset from,
    Offset to,
    List<Color> colors, [
    List<double> colorStops,
    TileMode tileMode,
  ]) = LinearGradient;

  /// Creates a radial gradient centered at `center` that ends at `radius`
  /// distance from the center.
  ///
  /// If `colorStops` is provided, `colorStops[i]` is a number from 0.0 to 1.0
  /// that specifies where `color[i]` begins in the gradient. If `colorStops` is
  /// not provided, then only two stops, at 0.0 and 1.0, are implied (and
  /// `color` must therefore only have two entries).
  ///
  /// The behavior before and after the radius is described by the `tileMode`
  /// argument. For details, see the [TileMode] enum.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/dart-ui/tile_mode_clamp_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/dart-ui/tile_mode_mirror_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/dart-ui/tile_mode_repeated_radial.png)
  ///
  /// If `center`, `radius`, `colors`, or `tileMode` are null, or if `colors` or
  /// `colorStops` contain null values, this constructor will throw a
  /// [NoSuchMethodError].
  factory Gradient.radial(
    Offset center,
    double radius,
    List<Color> colors, [
    List<double> colorStops,
    TileMode tileMode,
  ]) = RadialGradient;

  void _validateColorStops(List<Color> colors, List<double> colorStops) {
    if (colorStops == null) {
      if (colors.length != 2)
        throw new ArgumentError(
            '"colors" must have length 2 if "colorStops" is omitted.');
    } else {
      if (colors.length != colorStops.length)
        throw new ArgumentError(
            '"colors" and "colorStops" arguments must have equal length.');
    }
  }
}

/// The following class exists only in Flutter2js!
class LinearGradient extends Gradient {
  final Offset from;
  final Offset to;
  final List<Color> colors;
  final List<double> colorStops;
  final TileMode tileMode;

  LinearGradient(
    this.from,
    this.to,
    this.colors, [
    this.colorStops = null,
    this.tileMode = TileMode.clamp,
  ]) {
    assert(_offsetIsValid(from));
    assert(_offsetIsValid(to));
    assert(colors != null);
    assert(tileMode != null);
    _validateColorStops(colors, colorStops);
  }
}

/// The following class exists only in Flutter2js!
class RadialGradient extends Gradient {
  final Offset center;
  final double radius;
  final List<Color> colors;
  final List<double> colorStops;
  final TileMode tileMode;

  RadialGradient(
    this.center,
    this.radius,
    this.colors, [
    this.colorStops = null,
    this.tileMode = TileMode.clamp,
  ]) {
    assert(_offsetIsValid(center));
    assert(colors != null);
    assert(tileMode != null);
    _validateColorStops(colors, colorStops);
  }
}
