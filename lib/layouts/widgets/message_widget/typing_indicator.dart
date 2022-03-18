import 'dart:math' as math;

import 'package:bluebubbles/helpers/constants.dart';
import 'package:bluebubbles/helpers/hex_color.dart';
import 'package:bluebubbles/helpers/navigator.dart';
import 'package:bluebubbles/layouts/setup/theme_selector/theme_selector.dart';
import 'package:bluebubbles/layouts/widgets/message_widget/message_widget_mixin.dart';
import 'package:bluebubbles/managers/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TypingIndicator extends StatefulWidget {
  TypingIndicator({
    Key? key,
    this.visible = false,
    this.bigPin = false,
    this.chatList = false,
  }) : super(key: key);
  final bool visible;
  final bool bigPin;
  final bool chatList;

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation animation;
  final Rx<Skins> skin = Rx<Skins>(SettingsManager().settings.skin.value);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _controller.addListener(() {});

    animation = Tween(
      begin: 0.0,
      end: math.pi,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.addStatusListener((state) {
      if (state == AnimationStatus.completed && mounted) {
        _controller.forward(from: 0.0);
      }
    });

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Skin.of(context) != null) {
      skin.value = Skin.of(context)!.skin;
    }
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: widget.visible
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    if (!widget.chatList && skin.value == Skins.iOS)
                      Container(
                        margin: EdgeInsets.only(left: widget.bigPin ? 18 : 2),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        width: 10,
                        height: 10,
                      ),
                    if (!widget.chatList && skin.value == Skins.iOS)
                      Container(
                        margin: EdgeInsets.only(left: 9, bottom: 10),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        width: 15,
                        height: 15,
                      ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: !widget.chatList && skin.value == Skins.iOS ? 13 : 5,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: CustomNavigator.width(context) * MessageWidgetMixin.MAX_SIZE,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.theme.colorScheme.secondary,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: [
                              buildDot(2),
                              buildDot(1),
                              buildDot(0),
                            ],
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Container(),
    );
  }

  Widget buildDot(int index) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.secondary.lightenOrDarken(
                  (math.sin(animation.value + (index) * math.pi / 4).abs() * 20).clamp(1, 20).toDouble()),
              borderRadius: BorderRadius.circular(30),
            ),
            width: 10,
            height: 10,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          );
        },
      );
}
