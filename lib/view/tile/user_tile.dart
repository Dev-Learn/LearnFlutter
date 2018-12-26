import 'package:data/model/user/user.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/widget/image_loader/image_loader.dart';

//class UserTile extends StatelessWidget{
//  //final Map map;
//  final User _user;
//
//  //UserItem(this.map);
//  UserTile(this._user);
//
//  @override
//  Widget build(BuildContext context) {
//    return new Column(
//      children: <Widget>[
//        ListTile(
//          leading: new CircleAvatar(
//            backgroundImage: CachedNetworkImageProvider(_user.avatar, scale: 6.0),
//            backgroundColor: Colors.grey,
//          ),
//          title: new Text(_user.username),
//
//        ),
//        new Divider()
//      ],
//    );
//
//  }
//}

class UserTile extends StatefulWidget {
  //final Map map;
  final User user;
  final bool isAnimate;
  final index;
  final TickerProvider tickerProvider;

  UserTile(this.user, this.isAnimate, this.index, this.tickerProvider, {Key key}) : super(key: key);

  @override
  createState() => new _UserTileState();
}

class _UserTileState extends State<UserTile> with AutomaticKeepAliveClientMixin<UserTile> {
  AnimationController _controller;
  Animation<Offset> animation;
  Animation<double> sizeAnimation;
  bool isLoaded = false;

//  CachedNetworkImageProvider image;

  _UserTileState();

  @override
  void initState() {
    super.initState();
    _init();
  }



  //  _loadImage() async {
//    image = CachedNetworkImageProvider(widget.user.avatar);
//    image.resolve(new ImageConfiguration()).addListener((_, __) {
//      if (mounted) {
//        setState(() {
//          isLoaded = true;
//        });
//      }
//    });
//  }

  _init() {
    //_loadImage();
    _controller = new AnimationController(duration: const Duration(milliseconds: 1000), vsync: widget.tickerProvider);
    sizeAnimation = Tween(begin: widget.isAnimate ? 0.0 : 1.0, end: 1.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.0,
          1.0,
          curve: Curves.elasticOut,
        ),
      ),
    );
    animation =
        new Tween(begin: widget.isAnimate ? Offset(-0.05, 0.0) : Offset(0.0, 0.0), end: const Offset(0.0, 0.0)).animate(new CurveTween(curve: Curves.easeInOut).animate(_controller));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
//    print('super build ${widget.index}');
    super.build(context);
    print('build ${widget.index}');
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ClipOval(
                      child: Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          image: DecorationImage(
                            image: ImageLoaderProvider(widget.user.avatar, scale: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(widget.user.login),
                ],
              ),
              transform: Matrix4.diagonal3Values(
                sizeAnimation.value,
                sizeAnimation.value,
                1.0,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 84.0),
              color: Colors.black12,
              height: 0.5,
              width: double.infinity,
            ),
          ],
        );
      },
    );
//    return Column(
//      children: <Widget>[
//        Container(
//          child: Row(
//            children: <Widget>[
//              Container(
//                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                child: ClipOval(
//                  child: Container(
//                    width: 52.0,
//                    height: 52.0,
//                    decoration: BoxDecoration(
//                        color: Colors.grey.shade200, image: DecorationImage(image: ImageLoaderProvider(widget.user.avatar, scale: 0.4))),
//                  ),
//                ),
//              ),
//              Text(widget.user.login),
//            ],
//          ),
//        ),
//        Container(
//          margin: EdgeInsets.only(left: 84.0),
//          color: Colors.black12,
//          height: 0.5,
//          width: double.infinity,
//        ),
//      ],
//    );
  }

  @override
  void dispose() {
    print("BBBBBBBBBBBB");
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
