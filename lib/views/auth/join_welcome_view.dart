import 'package:Medito/utils/utils.dart';
import 'package:Medito/widgets/widgets.dart';
import 'package:Medito/constants/constants.dart';
import 'package:Medito/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JoinWelcomeView extends ConsumerWidget {
  const JoinWelcomeView({super.key, required this.email});
  final String email;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorConstants.ebony,
      body: SizedBox(
        height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AssetConstants.join,
              height: size.height * 0.45,
              width: size.width,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringConstants.welcomeToTheMeditoFamily,
                      style: textTheme.headlineMedium?.copyWith(
                        color: ColorConstants.walterWhite,
                        fontFamily: ClashDisplay,
                        height: 1.2,
                        fontSize: 24,
                      ),
                    ),
                    height8,
                    Text(
                      StringConstants.welcomeMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: ColorConstants.walterWhite,
                        fontFamily: ClashDisplay,
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      StringConstants.thanksForJoining,
                      style: textTheme.headlineSmall?.copyWith(
                        color: ColorConstants.walterWhite,
                        fontFamily: ClashDisplay,
                        height: 3,
                        fontSize: 16,
                      ),
                    ),
                    height8,
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: LoadingButtonWidget(
                        onPressed: () {
                          var auth = ref.read(authProvider.notifier);
                          auth.setUserEmail(email);
                          context.go(RouteConstants.homePath);
                        },
                        btnText: StringConstants.close,
                        bgColor: ColorConstants.walterWhite,
                        textColor: ColorConstants.greyIsTheNewGrey,
                      ),
                    ),
                    // height16,
                    // height16,
                    SizedBox(
                      height: getBottomPadding(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
