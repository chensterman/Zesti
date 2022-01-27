import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';

/// This is the stateful widget that the main application instantiates.
class ZestiLoading extends StatefulWidget {
  const ZestiLoading({Key? key}) : super(key: key);

  @override
  State<ZestiLoading> createState() => _ZestiLoadingState();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _ZestiLoadingState extends State<ZestiLoading>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _animation,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50.0,
            child: SvgPicture.asset(
              "assets/loading.svg",
            ),
          ),
        ),
      ),
    );
  }
}

class ZestiLoadingAsync {
  static final ZestiLoadingAsync _singleton = ZestiLoadingAsync._internal();
  BuildContext? _context;

  factory ZestiLoadingAsync() {
    return _singleton;
  }

  ZestiLoadingAsync._internal();

  show(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: ZestiLoading(),
          );
        });
  }

  dismiss() {
    if (_context != null) {
      Navigator.of(_context!).pop();
    }
  }
}
