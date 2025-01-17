import 'package:Medito/constants/constants.dart';
import 'package:Medito/models/models.dart';
import 'package:Medito/providers/providers.dart';
import 'package:Medito/routes/routes.dart';
import 'package:Medito/utils/utils.dart';
import 'package:Medito/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnnouncementWidget extends ConsumerStatefulWidget {
  const AnnouncementWidget({super.key, required this.announcement});
  final AnnouncementModel announcement;
  @override
  ConsumerState<AnnouncementWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends ConsumerState<AnnouncementWidget> {
  bool _isCollapsed = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _toggleCollapse();
    });
    super.initState();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bgColor =
        ColorConstants.getColorFromString(widget.announcement.colorBackground);
    var topPadding = MediaQuery.of(context).viewPadding.top;
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: Visibility(
            visible: !_isCollapsed,
            child: Column(
              children: [
                Container(
                  color: bgColor,
                  height: topPadding,
                  width: size.width,
                ),
                Container(
                  color: bgColor,
                  width: size.width,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _icon(widget.announcement.icon),
                          _text(context, widget.announcement.text),
                        ],
                      ),
                      height16,
                      _actionBtn(context, ref, widget.announcement),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isCollapsed)
          SizedBox(
            height: topPadding,
          ),
      ],
    );
  }

  Row _actionBtn(
    BuildContext context,
    WidgetRef ref,
    AnnouncementModel announcement,
  ) {
    var textColor = ColorConstants.getColorFromString(
      announcement.colorText,
    );
    var bgColor = ColorConstants.getColorFromString(
      announcement.colorBackground,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        LoadingButtonWidget(
          onPressed: () {
            _toggleCollapse();
            _handleTrackEvent(ref, announcement.id, StringConstants.dismiss);
            ref.invalidate(homeProvider);
            ref.read(homeProvider);
          },
          btnText: StringConstants.dismiss,
          bgColor: bgColor,
          textColor: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          elevation: 0,
        ),
        width4,
        LoadingButtonWidget(
          onPressed: () => _handleCtaTitlePress(context, ref, announcement),
          btnText: announcement.ctaTitle ?? '',
          bgColor: textColor,
          textColor: bgColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          elevation: 0,
        ),
      ],
    );
  }

  Flexible _text(BuildContext context, String? title) {
    return Flexible(
      child: SelectableText(
        title ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ColorConstants.getColorFromString(
                widget.announcement.colorText,
              ),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _icon(String? icon) {
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 0, right: 10),
        child: Icon(
          IconData(
            formatIcon(widget.announcement.icon!),
            fontFamily: 'MaterialIcons',
          ),
          size: 24,
        ),
      );
    }

    return SizedBox();
  }

  void _handleCtaTitlePress(
    BuildContext context,
    WidgetRef ref,
    AnnouncementModel element,
  ) {
    var location = GoRouter.of(context).location;
    _handleTrackEvent(ref, element.id, element.ctaTitle);
    if (element.ctaType == TypeConstants.LINK) {
      context.push(
        location + RouteConstants.webviewPath,
        extra: {'url': element.ctaPath},
      );
    } else {
      context.push(getPathFromString(
        element.ctaType,
        [element.ctaPath.toString().getIdFromPath()],
      ));
    }
  }

  void _handleTrackEvent(
    WidgetRef ref,
    String announcementId,
    String? ctaTitle,
  ) {
    var announcement = AnnouncementCtaTappedModel(
      announcementId: announcementId,
      ctaTitle: ctaTitle ?? '',
    );
    var event = EventsModel(
      name: EventTypes.announcementCtaTapped,
      payload: announcement.toJson(),
    );
    ref.read(eventsProvider(event: event.toJson()));
  }
}
