import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected app locale.
/// `null` means follow system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);
