import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// EduAccess dropdown — styled to match AppTextField.
///
/// ```dart
/// AppDropdown<String>(
///   label: 'Role',
///   value: _selectedRole,
///   items: [
///     AppDropdownItem(value: 'guru', label: 'Guru'),
///     AppDropdownItem(value: 'siswa', label: 'Siswa'),
///   ],
///   onChanged: (v) => setState(() => _selectedRole = v),
/// )
/// ```
class AppDropdownItem<T> {
  final T value;
  final String label;
  final Widget? leading;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.leading,
  });
}

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          value: value,
          validator: validator,
          onChanged: enabled ? onChanged : null,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.neutral500),
          decoration: InputDecoration(
            hintText: hint ?? 'Pilih $label',
            errorText: errorText,
          ),
          dropdownColor: AppColors.white,
          menuMaxHeight: 300,
          borderRadius: AppRadius.lgAll,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Row(
                    children: [
                      if (item.leading != null) ...[
                        item.leading!,
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(item.label),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
