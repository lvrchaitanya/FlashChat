
import 'package:flutter/material.dart';


class MyButton extends StatelessWidget {
  String discrip;
  Function onPress;
  Color colors;
  MyButton({this.discrip,this.onPress,this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colors,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            '$discrip',
          ),
        ),
      ),
    );
  }
}
