import 'package:flutter/material.dart';

// ─── Primary brand palette — single source of truth for all pages ────────────

const kPrimary = Color(0xFF1A56DB);
const kPrimaryMid = Color(0xFF0E3FA8);
const kPrimaryDark = Color(0xFF0A2D7A);
const kPrimaryLight = Color(0xFF6BC4FF);
const kAccent = Color(0xFF6EE7F7);

// ─── Gradients ────────────────────────────────────────────────────────────────

const kPrimaryGradient = LinearGradient(
  colors: [kPrimary, kPrimaryMid, kPrimaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kPrimaryGradientV = LinearGradient(
  colors: [kPrimary, kPrimaryDark],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const kHeaderGradient = LinearGradient(
  colors: [kPrimary, kPrimaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Neutrals ─────────────────────────────────────────────────────────────────

const kBackground = Color(0xFFF4F6FB);
const kSurface = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE5E7EB);
const kDivider = Color(0xFFF3F4F6);

// ─── Text ─────────────────────────────────────────────────────────────────────

const kTextDark = Color(0xFF1A1F36);
const kTextMedium = Color(0xFF6B7280);
const kTextLight = Color(0xFF9CA3AF);

// ─── Semantic ─────────────────────────────────────────────────────────────────

const kSuccess = Color(0xFF10B981);
const kSuccessLight = Color(0xFF11998E);
const kWarning = Color(0xFFF59E0B);
const kError = Color(0xFFEF4444);
const kEmergency = Color(0xFFFF416C);

// ─── Category accent colors ───────────────────────────────────────────────────

const kPurple = Color(0xFF8B5CF6);
const kOrange = Color(0xFFF97316);
const kTeal = Color(0xFF06B6D4);
const kGreen = Color(0xFF22C55E);
const kRed = Color(0xFFEF4444);
const kAmber = Color(0xFFF59E0B);
const kPink = Color(0xFFEC4899);
