// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show ServicesBinding, ServicesBindingMixin;

import 'image_cache.dart';

abstract class PaintingBindingMixin implements PaintingBinding {
  static doInitInstances(PaintingBinding binding) {
    _instance = binding;
    binding._imageCache = binding.createImageCache();
  }

  /// The current [PaintingBinding], if one has been created.
  static PaintingBinding get instance => _instance;
  static PaintingBinding _instance;

  /// The singleton that implements the Flutter framework's image cache.
  ///
  /// The cache is used internally by [ImageProvider] and should generally not
  /// be accessed directly.
  ///
  /// The image cache is created during startup by the [createImageCache]
  /// method.
  ImageCache get imageCache => _imageCache;
  ImageCache _imageCache;

  /// Creates the [ImageCache] singleton (accessible via [imageCache]).
  ///
  /// This method can be overridden to provide a custom image cache.
  @protected
  ImageCache createImageCache() => new ImageCache();

  static void doEvict(PaintingBinding binding, String asset) {
    binding.imageCache.clear();
  }
}

/// Binding for the painting library.
///
/// Hooks into the cache eviction logic to clear the image cache.
///
/// Requires the [ServicesBinding] to be mixed in earlier.
abstract class PaintingBinding extends BindingBase with ServicesBindingMixin {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory PaintingBinding._() => null;

  @override
  void initInstances() {
    super.initInstances();
    ServicesBindingMixin.doInitInstances(this);
    _instance = this;
    _imageCache = createImageCache();
  }

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();
    ServicesBindingMixin.doInitServiceExtensions(this);
  }

  /// The current [PaintingBinding], if one has been created.
  static PaintingBinding get instance => _instance;
  static PaintingBinding _instance;

  /// The singleton that implements the Flutter framework's image cache.
  ///
  /// The cache is used internally by [ImageProvider] and should generally not
  /// be accessed directly.
  ///
  /// The image cache is created during startup by the [createImageCache]
  /// method.
  ImageCache get imageCache => _imageCache;
  ImageCache _imageCache;

  /// Creates the [ImageCache] singleton (accessible via [imageCache]).
  ///
  /// This method can be overridden to provide a custom image cache.
  @protected
  ImageCache createImageCache() => new ImageCache();

  static void doEvict(PaintingBinding binding, String asset) {
    binding.imageCache.clear();
  }
}

/// The singleton that implements the Flutter framework's image cache.
///
/// The cache is used internally by [ImageProvider] and should generally not be
/// accessed directly.
///
/// The image cache is created during startup by the [PaintingBinding]'s
/// [PaintingBinding.createImageCache] method.
ImageCache get imageCache => PaintingBinding.instance.imageCache;
