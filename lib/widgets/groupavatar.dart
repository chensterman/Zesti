import 'package:flutter/material.dart';

// Widget displaying user cards to make decisions on.
class GroupAvatar extends StatelessWidget {
  final double radius;
  final List<dynamic> groupPhotos;

  GroupAvatar({
    required this.radius,
    required this.groupPhotos,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double avatarRadius = radius * 0.5;
    List<Widget> widgetList = [];
    for (ImageProvider<Object> photo in groupPhotos) {
      widgetList.add(_buildAvatar(photo, avatarRadius));
    }
    return Center(
      child: Container(
        height: radius,
        width: radius,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  widgetList.length >= 1 ? widgetList[0] : Container(),
                  widgetList.length >= 3 ? widgetList[2] : Container(),
                ],
              ),
              Row(
                children: <Widget>[
                  widgetList.length >= 2 ? widgetList[1] : Container(),
                  widgetList.length >= 4 ? widgetList[3] : Container(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ImageProvider<Object> photo, double avatarRadius) {
    return Expanded(
        child: Container(
      width: avatarRadius,
      height: avatarRadius,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: photo,
        ),
      ),
    ));
  }
}
