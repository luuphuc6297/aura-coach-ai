import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/cloud_image.dart';

class ChatBubbleAi extends StatelessWidget {
  final String text;
  final String senderName;

  const ChatBubbleAi({
    super.key,
    required this.text,
    this.senderName = 'Aura Coach',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: ClipOval(
            child: CloudImage(url: CloudinaryAssets.chatbot, size: 32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  border: Border.all(color: AppColors.clayBorder, width: 1.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: Text(
                  text,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
