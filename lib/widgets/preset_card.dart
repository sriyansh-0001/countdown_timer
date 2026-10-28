import 'package:flutter/material.dart';

import '../models/timer_preset.dart';
import '../theme/app_theme.dart';

/// Card widget representing a duration preset, supporting active selection,
/// custom preset tags, and deletion for user-defined presets.
class PresetCard extends StatelessWidget {
  final TimerPreset preset;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback? onDelete;

  const PresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onSelected,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.12)
            : (isDark ? AppTheme.darkCardColor : AppTheme.lightCardColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white12 : Colors.black12),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.2)
                      : (isDark
                            ? AppTheme.darkSurfaceVariant
                            : AppTheme.lightSurfaceVariant),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  preset.icon,
                  size: 18,
                  color: isSelected ? primaryColor : theme.iconTheme.color,
                ),
              ),
              const SizedBox(width: 10),

              // Title and Duration
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? primaryColor : null,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    preset.formattedDigitalDuration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              // Optional delete button for custom presets
              if (preset.isCustom && onDelete != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  tooltip: 'Delete custom preset',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
