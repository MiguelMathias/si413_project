import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class GroupedComponent extends StatelessWidget {
  final List<List<Widget>> groups;
  const GroupedComponent({Key? key, this.groups = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: groups
            .map((columnChildren) => Container(
                margin: EdgeInsets.only(
                    top: 20,
                    right: 20,
                    left: 20,
                    bottom: groups.indexOf(columnChildren) == groups.length - 1
                        ? 20
                        : 0),
                decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                    mainAxisSize: MainAxisSize.min, children: columnChildren)))
            .toList());
  }
}
