import 'package:flutter/material.dart';
import 'package:smart_shop/Utils/app_colors.dart';

import '../../Utils/font_styles.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({this.marginTop, Key? key, this.fontStyle}) : super(key: key);
  final double? marginTop;
  final TextStyle? fontStyle;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop!),
      child: RichText(
        text: TextSpan(
          text: 'DGA ',
            style: FontStyles.montserratRegular25().copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: 'Express',
              style: FontStyles.montserratRegular25().copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
