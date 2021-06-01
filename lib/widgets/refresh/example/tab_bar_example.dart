import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

import '../loading_more.dart';
import '../water_drop.dart';

///标签栏 页面刷新
class TabBarExample extends StatefulWidget {
  const TabBarExample({Key? key}) : super(key: key);

  @override
  _TabBarExampleState createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = <String>[
    '标签一',
    '标签二',
    '标签三',
  ];
  late TabController _controller;
  Index tabIndex = Index(0);

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this);
    _controller.addListener(() {
      tabIndex.index = _controller.index;
      print('index ===== ${tabIndex.index}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget tabBarView = TabBarView(
      controller: _controller,
      children: const <Widget>[
        View1(),
        View2(),
        View3(),
      ],
    );
    Widget child = NestedScrollView(
      body: tabBarView,
      headerSliverBuilder: (BuildContext context, bool b) {
        return <Widget>[
          SliverToBoxAdapter(
            child: TabBar(
                controller: _controller,
                labelColor: Colors.blue,
                tabs: tabs
                    .map((String e) => Tab(
                          text: e,
                        ))
                    .toList()),
          ),
        ];
      },
    );

    child = Scaffold(
      appBar: AppBar(),
      body: child,
    );
    child = TabBarData(tabIndex: tabIndex, child: child);
    return child;
  }
}

class Index {
  Index(this.index);

  int index = 0;
}

///
class TabBarData extends InheritedWidget {
  ///
  const TabBarData({Key? key, required this.tabIndex, required Widget child})
      : super(key: key, child: child);

  ///
  final Index tabIndex;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class View1 extends StatefulWidget {
  const View1({Key? key}) : super(key: key);

  @override
  _View1State createState() => _View1State();
}

class _View1State extends State<View1> with AutomaticKeepAliveClientMixin {
  final List<int> _data = <int>[];
  final List<int> _rdata = <int>[];
  final RefreshController _controller = RefreshController();
  int page = 0;
  int rpage = 0;

  Future<bool> _loadData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 1000), () {
      return List<int>.generate(20, (int index) => index);
    });
    if (isRefresh) {
      _data.clear();
    }
    _data.addAll(data);
    return true;
  }

  Future<bool> _init() {
    return _refresh();
  }

  Future<bool> _refresh() async {
    print('view1 refresh');
    final bool result = await _loadData(page, true);
    if (mounted) {
      setState(() {});
    }
    return result;
  }

  Future<void> _loadMore() async {
    page++;
    print('load more ===============$page');

    await _loadData(page);

    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _loadRData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 3), () {
      return List<int>.generate(20, (int index) => index);
    });
    if (isRefresh) {
      _rdata.clear();
    }
    _rdata.addAll(data);
    return true;
  }

  Future<bool> _rinit() {
    return _rrefresh();
  }

  Future<bool> _rrefresh() async {
    print('=====11111111111======');
    final bool result = await _loadRData(rpage, true);
    setState(() {});
    _controller.refreshCompleted();
    return result;
  }

  Future<void> _rloadMore() async {
    page++;
    await _loadRData(rpage);
    _controller.loadComplete();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
    _rinit();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget child = Container();

    Widget buildItem(BuildContext context, int index) {
      return Container(
        height: 45,
        alignment: Alignment.center,
        // color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        child: Text('item index = $index'),
      );
    }

    // child = LoadingMoreListView(
    //   itemCount: _data.length,
    //   itemBuilder: buildItem,
    //   onLoadMore: _loadMore,
    // );

    child = LoadingMoreCustomScrollView(
      onLoadMore: _loadMore,
      // physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        PullToRefreshContainer((PullToRefreshScrollNotificationInfo? info) {
          return WaterDropRefreshHeader(
            info: info,
          );
        }),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return buildItem(context, index);
            },
            childCount: _data.length,
          ),
        ),

        // const SliverFillRemaining(
        //   child: Center(
        //     child: Text('没有内容'),
        //   ),
        // ),
      ],
    );
    final Index index = context
        .dependOnInheritedWidgetOfExactType<TabBarData>(aspect: TabBarData)!
        .tabIndex;
    child = PullToRefreshNotification(
      child: child,
      onRefresh: _refresh,
      maxDragOffset: 80,
      notificationPredicate: (ScrollNotification notification) =>
          index.index == 0,
    );

    final Widget pullToRefresh = SmartRefresher(
      controller: _controller,
      header: const WaterDropHeader(),
      onRefresh: _rrefresh,
      onLoading: _rloadMore,
      child: ListView.builder(
        itemBuilder: buildItem,
        itemCount: _rdata.length,
      ),
    );

    return child;
  }
}

class View2 extends StatefulWidget {
  const View2({Key? key}) : super(key: key);

  @override
  _View2State createState() => _View2State();
}

class _View2State extends State<View2> with AutomaticKeepAliveClientMixin {
  final List<int> _data = <int>[];
  final List<int> _rdata = <int>[];
  final RefreshController _controller = RefreshController();
  int page = 0;
  int rpage = 0;

  Future<bool> _loadData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 1000), () {
      return List<int>.generate(20, (int index) => index);
    });
    if (isRefresh) {
      _data.clear();
    }
    _data.addAll(data);
    return true;
  }

  Future<bool> _init() {
    return _refresh();
  }

  Future<bool> _refresh() async {
    print('view2 refresh');
    final bool result = await _loadData(page, true);
    if (mounted) {
      setState(() {});
    }
    return result;
  }

  Future<void> _loadMore() async {
    page++;
    print('load more ===============$page');

    await _loadData(page);
    // await Future<void>.delayed(const Duration(milliseconds: 200), () {
    //   page = 0;
    //   print('page  = 0 ');
    // });
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _loadRData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 3), () {
      return List<int>.generate(20, (int index) => index);
    });
    if (isRefresh) {
      _rdata.clear();
    }
    _rdata.addAll(data);
    return true;
  }

  Future<bool> _rinit() {
    return _rrefresh();
  }

  Future<bool> _rrefresh() async {
    print('=====222222222======');
    final bool result = await _loadRData(rpage, true);
    if (mounted) {
      setState(() {});
    }
    _controller.refreshCompleted();
    return result;
  }

  Future<void> _rloadMore() async {
    page++;
    await _loadRData(rpage);
    _controller.loadComplete();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    _rinit();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget child = Container();

    Widget buildItem(BuildContext context, int index) {
      return Container(
        height: 45,
        alignment: Alignment.center,
        // color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        child: Text('item index = $index'),
      );
    }

    // child = LoadingMoreListView(
    //   itemCount: _data.length,
    //   itemBuilder: buildItem,
    //   onLoadMore: _loadMore,
    // );

    child = LoadingMoreCustomScrollView(
      onLoadMore: _loadMore,
      // physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        PullToRefreshContainer((PullToRefreshScrollNotificationInfo? info) {
          return WaterDropRefreshHeader(
            info: info,
          );
        }),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return buildItem(context, index);
            },
            childCount: _data.length,
          ),
        ),

        // const SliverFillRemaining(
        //   child: Center(
        //     child: Text('没有内容'),
        //   ),
        // ),
      ],
    );
    final Index index = context
        .dependOnInheritedWidgetOfExactType<TabBarData>(aspect: TabBarData)!
        .tabIndex;
    child = PullToRefreshNotification(
      child: child,
      onRefresh: _refresh,
      pullBackOnRefresh: false,
      armedDragUpCancel: false,
      maxDragOffset: 80,
      notificationPredicate: (ScrollNotification notification) =>
          index.index == 1,
    );

    final Widget pullToRefresh = SmartRefresher(
      controller: _controller,
      header: const WaterDropHeader(),
      onRefresh: _rrefresh,
      onLoading: _rloadMore,
      child: ListView.builder(
        itemBuilder: buildItem,
        itemCount: _rdata.length,
      ),
    );

    return child;
  }
}

class View3 extends StatefulWidget {
  const View3({Key? key}) : super(key: key);

  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with AutomaticKeepAliveClientMixin {
  final List<int> _data = <int>[];
  final List<int> _rdata = <int>[];
  final RefreshController _controller = RefreshController();
  int page = 0;
  int rpage = 0;

  Future<bool> _loadData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 1000), () {
      return List<int>.generate(20, (int index) => index);
    });
    if (isRefresh) {
      _data.clear();
    }
    _data.addAll(data);
    return true;
  }

  Future<bool> _init() {
    return _refresh();
  }

  Future<bool> _refresh() async {
    print('view3 refresh');
    final bool result = await _loadData(page, true);
    if (mounted) {
      setState(() {});
    }
    return result;
  }

  Future<void> _loadMore() async {
    page++;

    await _loadData(page);

    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _loadRData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 3), () {
      return List<int>.generate(20, (int index) => index);
    });
    if (isRefresh) {
      _rdata.clear();
    }
    _rdata.addAll(data);
    return true;
  }

  Future<bool> _rinit() {
    return _rrefresh();
  }

  Future<bool> _rrefresh() async {
    print('=====33333333======');
    final bool result = await _loadRData(rpage, true);
    if (mounted) {
      setState(() {});
    }
    _controller.refreshCompleted();
    return result;
  }

  Future<void> _rloadMore() async {
    page++;
    await _loadRData(rpage);
    _controller.loadComplete();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    _rinit();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget child = Container();

    Widget buildItem(BuildContext context, int index) {
      return Container(
        height: 45,
        alignment: Alignment.center,
        // color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        child: Text('item index = $index'),
      );
    }

    // child = LoadingMoreListView(
    //   itemCount: _data.length,
    //   itemBuilder: buildItem,
    //   onLoadMore: _loadMore,
    // );

    child = LoadingMoreCustomScrollView(
      onLoadMore: _loadMore,
      // physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        PullToRefreshContainer((PullToRefreshScrollNotificationInfo? info) {
          return WaterDropRefreshHeader(
            info: info,
          );
        }),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return buildItem(context, index);
            },
            childCount: _data.length,
          ),
        ),

        // const SliverFillRemaining(
        //   child: Center(
        //     child: Text('没有内容'),
        //   ),
        // ),
      ],
    );
    final Index index = context
        .dependOnInheritedWidgetOfExactType<TabBarData>(aspect: TabBarData)!
        .tabIndex;
    print('index ===== $index');
    child = PullToRefreshNotification(
      child: child,
      onRefresh: _refresh,
      pullBackOnRefresh: false,
      armedDragUpCancel: false,
      maxDragOffset: 80,
      notificationPredicate: (ScrollNotification notification) =>
          index.index == 2,
    );

    final Widget pullToRefresh = SmartRefresher(
      controller: _controller,
      header: const WaterDropHeader(),
      onRefresh: _rrefresh,
      onLoading: _rloadMore,
      child: ListView.builder(
        itemBuilder: buildItem,
        itemCount: _rdata.length,
      ),
    );

    return child;
  }
}
