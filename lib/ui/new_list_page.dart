import 'package:flutter/cupertino.dart';

class NewListPage extends StatefulWidget {
  const NewListPage({Key? key}) : super(key: key);

  @override
  State<NewListPage> createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: 'Lists',
        ),
        child: CupertinoTextField(
          placeholder: 'List name',
        ));
  }
}
