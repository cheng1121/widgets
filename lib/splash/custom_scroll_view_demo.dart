import 'package:flutter/material.dart';

class CustomScrollViewDemo extends StatefulWidget {
  const CustomScrollViewDemo({Key? key}) : super(key: key);

  @override
  _CustomScrollViewDemoState createState() => _CustomScrollViewDemoState();
}

class _CustomScrollViewDemoState extends State<CustomScrollViewDemo> {
  @override
  Widget build(BuildContext context) {
    final SliverList list = SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Center(
          child: Container(
            height: 40,
            child: Text('item index = $index'),
          ),
        );
      },
      childCount: 100,
    ));

    Widget child = CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          // collapsedHeight: 100,
          stretch: false,
          onStretchTrigger: () async {
            print('===========222=');
          },

          flexibleSpace: FlexibleSpaceBar(
            title: Text('title ===='),
            stretchModes: <StretchMode>[
              StretchMode.fadeTitle,
            ],
            background: Container(
              height: 200,
              color: Colors.red,
            ),
          ),
        ),
        list,
      ],
    );

    child = FlexibleSpaceBarSettings(
      toolbarOpacity: .5,
      minExtent: 10,
      maxExtent: 200,
      currentExtent: 200,
      child: child,
    );

    return Scaffold(
      body: child,
    );
  }
}
