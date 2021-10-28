import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Loading'),
      ),
      child: Center(child: CupertinoActivityIndicator()));
}
