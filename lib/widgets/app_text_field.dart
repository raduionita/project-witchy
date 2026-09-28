import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final FaIconData? lead;
  final bool obscure;
  final TextEditingController? controller;
  final VoidCallback? onToggleObscure;
  const AppTextField({super.key, this.label, required this.hint, this.lead, this.obscure = false, this.controller, this.onToggleObscure});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[Padding(padding: const EdgeInsets.only(left: 2, bottom: 6), child: Text(label!, style: AppText.sans(10.5, w: FontWeight.w600, c: const Color(0xFF4D3B52))))],
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppText.sans(12.5, c: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.sans(12.5, c: AppColors.placeholder),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12).copyWith(left: lead != null ? 36 : 12),
            prefixIcon: lead != null ? FaIcon(lead, size: AppIconSize.sm, color: AppColors.muted) : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 20),
            suffixIcon:
                onToggleObscure != null ? IconButton(onPressed: onToggleObscure, icon: FaIcon(obscure ? AppIcons.eye : AppIcons.eyeOpen, size: AppIconSize.sm, color: AppColors.muted)) : null,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.pur)),
          ),
        ),
      ],
    );
  }
}
