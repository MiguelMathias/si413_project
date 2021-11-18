import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

///A component to generate Cupertino style vertically scrollable groups of columns with
///rounded edges and a background of the secondary theme color
class GroupedComponent extends StatelessWidget {
  final List<List<Widget>> groups;
  const GroupedComponent({Key? key, this.groups = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //ListView for scrollability
    return ListView(
        children: groups
            .map((columnChildren) => Container(
                //A Container with the Cupertino styling present in Apple's design language
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
                    //The column to contain each group's children
                    mainAxisSize: MainAxisSize.min,
                    children: columnChildren)))
            .toList());
  }
}
