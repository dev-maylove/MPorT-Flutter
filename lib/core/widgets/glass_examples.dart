// Contoh penggunaan Glassmorphism UI Kit — MPorT Flutter
// File ini hanya dokumentasi / referensi, tidak di-import production.
//
// Import:
//   import 'package:mport/core/widgets/glass.dart';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass.dart';

// ignore_for_file: unused_element, dead_code

void _examples(BuildContext context) {
  // ── GlassCard ──────────────────────────────────────────────
  const GlassCard(
    child: Text('Konten kartu'),
  );

  GlassCard(
    enableGlow: true,
    onTap: () {},
    child: const Text('Card dengan glow + tap'),
  );

  // ── GlassStat (dashboard metrics) ──────────────────────────
  const Row(
    children: [
      Expanded(child: GlassStat(label: 'Pelanggan', value: '128', icon: Icons.people_rounded)),
      SizedBox(width: 10),
      Expanded(child: GlassStat(label: 'Invoice', value: '42', color: AppColors.warning, icon: Icons.receipt_long_rounded)),
      SizedBox(width: 10),
      Expanded(child: GlassStat(label: 'Ticket', value: '7', color: AppColors.danger, icon: Icons.support_agent_rounded)),
    ],
  );

  // ── StatusBadge ────────────────────────────────────────────
  const Wrap(
    spacing: 8,
    children: [
      StatusBadge(status: 'paid'),
      StatusBadge(status: 'pending'),
      StatusBadge(status: 'overdue'),
      StatusBadge(status: 'open'),
      GlassChip(label: 'Custom', color: AppColors.purple, icon: Icons.star_rounded),
    ],
  );

  // ── GlassButton ────────────────────────────────────────────
  Column(
    children: [
      GlassButton(label: 'Bayar Sekarang', icon: Icons.payments_rounded, onPressed: () {}),
      const SizedBox(height: 10),
      GlassButton(
        label: 'Detail',
        variant: GlassButtonVariant.outlined,
        onPressed: () {},
      ),
      const SizedBox(height: 10),
      GlassButton(
        label: 'Soft',
        variant: GlassButtonVariant.soft,
        color: AppColors.purple,
        expanded: false,
        onPressed: () {},
      ),
    ],
  );

  // ── GlassTextField ─────────────────────────────────────────
  const GlassTextField(
    label: 'Email',
    hint: 'nama@email.com',
    prefixIcon: Icon(Icons.email_outlined, color: AppColors.muted),
  );

  // ── GlassListTile ──────────────────────────────────────────
  GlassListTile(
    leading: const GlassAvatar(name: 'Budi Santoso'),
    title: 'INV-2026-00142',
    subtitle: 'Rp 350.000 · Jatuh tempo 25 Agu',
    trailing: const StatusBadge(status: 'pending'),
    onTap: () {},
  );

  // ── GlassAppBar ────────────────────────────────────────────
  const GlassAppBar(
    title: 'Invoice',
    actions: [
      GlassIconButton(icon: Icons.search_rounded, size: 40),
    ],
  );

  // ── GlassBottomBar ─────────────────────────────────────────
  GlassBottomBar(
    currentIndex: 0,
    onTap: (_) {},
    accent: AppColors.cyan,
    items: const [
      GlassBottomItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
      GlassBottomItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Invoice'),
      GlassBottomItem(icon: Icons.confirmation_number_outlined, activeIcon: Icons.confirmation_number_rounded, label: 'Ticket'),
      GlassBottomItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
    ],
  );

  // ── Dialog ─────────────────────────────────────────────────
  showGlassDialog(
    context: context,
    builder: (ctx) => GlassDialog(
      title: 'Konfirmasi',
      content: const Text('Bayar invoice ini sekarang?', style: TextStyle(color: AppColors.muted)),
      actions: [
        GlassButton(
          label: 'Batal',
          variant: GlassButtonVariant.ghost,
          expanded: false,
          onPressed: () => Navigator.pop(ctx),
        ),
        GlassButton(
          label: 'Bayar',
          expanded: false,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );

  // ── Bottom sheet ───────────────────────────────────────────
  showGlassSheet(
    context: context,
    builder: (ctx) => GlassSheet(
      title: 'Filter',
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: const [
          GlassListTile(title: 'Semua', subtitle: 'Tampilkan semua status'),
          SizedBox(height: 8),
          GlassListTile(title: 'Lunas', subtitle: 'Invoice sudah dibayar'),
          SizedBox(height: 8),
          GlassListTile(title: 'Belum bayar', subtitle: 'Pending & overdue'),
        ],
      ),
    ),
  );

  // ── Empty / Error / Skeleton ───────────────────────────────
  GlassEmpty(
    icon: Icons.receipt_long_rounded,
    title: 'Belum ada invoice',
    subtitle: 'Tagihan akan muncul di sini setelah siklus billing.',
    actionLabel: 'Refresh',
    onAction: () {},
  );

  GlassError(
    message: 'Gagal memuat data. Periksa koneksi internet.',
    onRetry: () {},
  );

  const Column(
    children: [
      GlassSkeletonCard(),
      SizedBox(height: 12),
      GlassSkeletonCard(height: 72),
    ],
  );

  // ── Panel section ──────────────────────────────────────────
  const GlassPanel(
    title: 'RINGKASAN LAYANAN',
    child: Text('Paket: 50 Mbps · Status: Aktif', style: TextStyle(color: AppColors.text)),
  );
}
