// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildCard(BuildContext context, Card widget) {
  return new Container(
      margin: const EdgeInsets.all(4.0),
      child: new Material(
          color: widget.color,
          type: MaterialType.card,
          elevation: widget.elevation,
          child: widget.child));
}
