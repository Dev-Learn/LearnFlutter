import 'package:flutter/material.dart';
import 'package:manga4dog/view/login/login_view.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewPortConstraint){
        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            height: viewPortConstraint.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: _buildRow(callback: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginView()));
                  }, title: 'Logout', icon: Icons.exit_to_app),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _buildRow({VoidCallback callback, String title, IconData icon}){
    return Material(
      child: InkWell(
        onTap: callback,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, textScaleFactor: 1.0, style: TextStyle(fontSize: 18.0),),
              Icon(icon),
            ],
          ),
        ),
      ),
    );
  }
}
