import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Circular avatar that shows a Cloudinary/network photo when available,
/// falling back to the user's initial on a coloured background.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final Color fallbackColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 48,
    this.fallbackColor = AppColors.accentOrange,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        (name.isNotEmpty ? name : '?')[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: fallbackColor, shape: BoxShape.circle),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorWidget: (_, __, ___) => _Initial(initial, size),
              )
            : _Initial(initial, size),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String initial;
  final double size;
  const _Initial(this.initial, this.size);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(initial,
            style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w800)),
      );
}
