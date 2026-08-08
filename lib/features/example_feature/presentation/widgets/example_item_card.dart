import 'package:flutter/material.dart';

import '../../../../core/extensions/navigation.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/example_item.dart';
import '../pages/example_item_details_args.dart';

class ExampleItemCard extends StatelessWidget {
  final ExampleItem item;
  final void Function(bool isLiked) onLikeChanged;

  const ExampleItemCard({
    super.key,
    required this.item,
    required this.onLikeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        Routes.exampleItemDetails,
        arguments: ExampleItemDetailsArgs(itemId: item.id),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsManager.lighterGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsManager.darkGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    item.title,
                    style: TextStyles.font16BlackMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.description,
                    style: TextStyles.font14GreyRegular,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onLikeChanged(item.isLiked),
              icon: Icon(
                item.isLiked ? Icons.favorite : Icons.favorite_border,
                color: item.isLiked ? ColorsManager.red : ColorsManager.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
