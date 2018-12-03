part of login_view;

class SignButton extends StatefulWidget {
  final HandleSubmit onPressed;
  final FocusNode focus;

  SignButton({this.onPressed, this.focus, Key key}) : super(key: key);

  @override
  _SignButtonState createState() => new _SignButtonState();
}

class _SignButtonState extends State<SignButton> with SingleTickerProviderStateMixin {
  String _title;
  bool isLoading = false;
  AnimationController controller;
  SequenceAnimation sequenceAnimation;

  @override
  void initState() {
    super.initState();
    _title = "Sign In";
    controller = new AnimationController(vsync: this);
    sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
            animatable: Tween(
              begin: SizeUtil.instance.getSize(867),
              end: SizeUtil.instance.getSize(133),
            ),
            from: Duration.zero,
            to: const Duration(milliseconds: 250),
            curve: Curves.ease,
            tag: "width")
        .addAnimatable(
            animatable: Tween(
              begin: SizeUtil.instance.getSize(10),
              end: SizeUtil.instance.getSize(100),
            ),
            from: Duration.zero,
            to: const Duration(milliseconds: 100),
            curve: Curves.linear,
            tag: "border")
        .addAnimatable(
            animatable: Tween(
              begin: SizeUtil.instance.getSize(133),
              end: 1000.0,
            ),
            from: const Duration(milliseconds: 1000),
            to: const Duration(milliseconds: 1500),
            tag: "zoomout")
        .animate(controller);
    controller.addListener(() {
      if (controller.isCompleted) {
        Navigator.pushReplacement(
                context, AnimatedPageRoute(child: HomeView(), transitionType: TransitionType.Fade, duration: Duration(milliseconds: 500)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(animation: controller, builder: _buildAnimation);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Material(
      color: primaryColor,
      borderRadius: sequenceAnimation["zoomout"].value < SizeUtil.instance.getSize(500)
          ? BorderRadius.all(Radius.circular(sequenceAnimation["border"].value))
          : BorderRadius.all(Radius.circular(0.0),),
      child: InkWell(
        onTap: onSubmit,
        child: Container(
          width: sequenceAnimation["zoomout"].value == SizeUtil.instance.getSize(133)
              ? sequenceAnimation["width"].value
              : sequenceAnimation["zoomout"].value,
          height: sequenceAnimation["zoomout"].value == SizeUtil.instance.getSize(133)
              ? SizeUtil.instance.getSize(133)
              : sequenceAnimation["zoomout"].value,
          alignment: FractionalOffset.center,
          child: sequenceAnimation["width"].value > 60
              ? new NoScaleFactorText(
                  _title,
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: SizeUtil.instance.getSize(43),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                )
              : sequenceAnimation["zoomout"].value < SizeUtil.instance.getSize(333)
                  ? new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : SizedBox(),
        ),
      ),
    );
  }

  Future<Null> _playAnimation() async {
    try {
      await controller.forward();
//      await controller.reverse();
    } on TickerCanceled {}
  }

  void onSubmit() {
    FocusScope.of(context).requestFocus(widget.focus ?? FocusNode());
    setState(() {
      _title = "Singing In ...";
      isLoading = true;
    });

    widget.onPressed().then((success) {
      if (success) {
        _playAnimation();
      } else {}
    }).whenComplete(() {
      setState(() {
        _title = "Sign In";
        isLoading = false;
      });
    });
  }
}
