import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

///A simple loading page with a centered Cupertino Activity Indicator. Usually used when waiting on async data.
class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Loading'),
      ),
      child: Center(child: CupertinoActivityIndicator()));
}
