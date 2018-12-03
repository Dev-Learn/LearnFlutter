library login_view;

import 'dart:async';
import 'package:data/auth/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:base/no_scale_factor_text.dart';
import 'package:base/util/size_util.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:manga4dog/resourses/app_colors.dart';
import 'package:manga4dog/resourses/app_strings.dart';
import 'package:manga4dog/view/home/home_view.dart';
import 'package:base/widgets/transition_animation.dart';

part 'sign_button.dart';

part 'login_widgets.dart';

class LoginView extends StatefulWidget {
  LoginView();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginView> {
  final _usernameController = TextEditingController()..text = 'clonebongda@gmail.com';
  final _passwordController = TextEditingController()..text = '123456';
  AuthManager _auth;

  _LoginPageState() {
    _auth = AuthManager();
  }

  Future<bool> _handleSubmit() {
    return _auth.login(_usernameController.text, _passwordController.text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginForm(_usernameController, _passwordController, _handleSubmit),
    );
  }
}

class LoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final HandleSubmit onLogin;

  LoginForm(this.usernameController, this.passwordController, this.onLogin);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  GlobalKey<_SignButtonState> buttonKey = GlobalKey();

  FocusNode viewFocusNode = FocusNode();
  FocusNode userNameFocusNode = FocusNode();
  FocusNode passWordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => FocusScope.of(context).requestFocus(viewFocusNode),
        child: LayoutBuilder(
          builder: (context, viewConstraint) {
            return SingleChildScrollView(
              child: Container(
                height: viewConstraint.maxHeight,
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    Positioned.fromRect(
                      rect: Rect.fromLTRB(0.0, 0.0, viewConstraint.maxWidth, viewConstraint.maxHeight * 0.8 - 20.0),
                      child: Container(
                        alignment: AlignmentDirectional.bottomCenter,
                        padding: EdgeInsets.symmetric(horizontal: SizeUtil.instance.getSize(67)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Hero(
                                  tag: 'imageHero',
                                  child: Image.asset(
                                    'assets/ic_github_icon.png',
                                    width: 120.0,
                                    height: 120.0,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                NoScaleFactorText(
                                  'Sign in',
                                  style: new TextStyle(fontSize: 23.0),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeUtil.instance.getSize(50)),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF454545), style: BorderStyle.solid),
                                ),
                              ),
                              child: TextFormField(
                                focusNode: userNameFocusNode,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(passWordFocusNode);
                                },
                                controller: widget.usernameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.person_outline,
                                      color: Colors.black54,
                                    ),
                                    hintText: AppStrings.EMAIL),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF454545), style: BorderStyle.solid),
                                ),
                              ),
                              child: Stack(
                                children: <Widget>[
                                  TextFormField(
                                    onFieldSubmitted: (value) {
                                      buttonKey.currentState.onSubmit();
                                    },
                                    focusNode: passWordFocusNode,
                                    controller: widget.passwordController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.lock_outline,
                                        color: Colors.black54,
                                      ),
                                      hintText: AppStrings.PASSWORD,
                                    ),
                                    obscureText: _obscureText,
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      alignment: AlignmentDirectional(1.0, 0.0),
                                      child: PassWordToggle(
                                        value: _obscureText,
                                        onChanged: (value) {
                                          setState(() {
                                            _obscureText = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        height: viewConstraint.maxHeight,
                        width: viewConstraint.maxWidth,
                        alignment: AlignmentDirectional(0.0, 0.8),
                        child: Container(
                          child: SignButton(
                            focus: viewFocusNode,
                            key: buttonKey,
                            onPressed: widget.onLogin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PassWordToggle extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool value;

  PassWordToggle({@required this.onChanged, @required this.value});

  @override
  _PassWordToggleState createState() => _PassWordToggleState();
}

class _PassWordToggleState extends State<PassWordToggle> with SingleTickerProviderStateMixin {
  double _fraction = 0.7;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween(begin: 0.7, end: 0.3).animate(controller)
      ..addListener(() {
        setState(() {
          _fraction = animation.value;
        });
      });
  }

  _handleTap() {
    widget.onChanged(!widget.value);
    widget.value ? controller.forward() : controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.black87;
    return Container(
      transform: Matrix4.translationValues(15.0, 0.0, 0.0),
      child: InkWell(
        customBorder: CircleBorder(),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        onTap: _handleTap,
        child: Container(
          width: 60.0,
          height: 60.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: Container(
                child: Icon(
                  Icons.visibility,
                  color: color,
                  size: 30.0,
                ),
              )),
              Positioned.fill(
                child: CustomPaint(
                  painter: CrossPainter(
                    fraction: _fraction,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CrossPainter extends CustomPainter {
  Color color;
  Paint _paint;
  Paint _paint2;
  double fraction;

  CrossPainter({@required this.fraction, @required this.color}) {
    _paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    _paint2 = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double leftLineFraction;

    _paint.color = fraction == 0.3 ? Colors.transparent : color;

    leftLineFraction = fraction / 1.0;

    canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.3 + 0.5), Offset(size.width * leftLineFraction, size.height * leftLineFraction + 0.5), _paint);
    canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.3 - 1.5), Offset(size.width * leftLineFraction, size.height * leftLineFraction - 1.5), _paint2);
  }

  @override
  bool shouldRepaint(CrossPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
