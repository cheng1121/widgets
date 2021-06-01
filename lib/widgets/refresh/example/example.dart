import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

import '../loading_more.dart';

class LoadMoreExample extends StatefulWidget {
  @override
  _LoadMoreExampleState createState() => _LoadMoreExampleState();
}

class _LoadMoreExampleState extends State<LoadMoreExample> {
  final List<int> _data = <int>[];
  final List<int> _rdata = <int>[];
  final RefreshController _controller = RefreshController();
  int page = 0;
  int rpage = 0;

  Future<bool> _loadData(int page, [bool isRefresh = false]) async {
    final List<int> data =
        await Future<List<int>>.delayed(const Duration(milliseconds: 3000), () {
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
    final bool result = await _loadData(page, true);
    setState(() {});
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
    setState(() {});
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
  Widget build(BuildContext context) {
    Widget child = Container();

    Widget buildItem(BuildContext context, int index) {
      return Container(
        height: 45,
        alignment: Alignment.center,
        // color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        child: Text('条目 index = $index'),
      );
    }

    child = LoadingMoreListView(
      itemCount: _data.length,
      itemBuilder: buildItem,
      onLoadMore: _loadMore,
    );

    // child = LoadingMoreCustomScrollView(
    //   onLoadMore: _loadMore,
    //   // physics: const ClampingScrollPhysics(),
    //   slivers: <Widget>[
    //     PullToRefreshContainer((PullToRefreshScrollNotificationInfo? info) {
    //       return WaterDropRefreshHeader(
    //         info: info,
    //       );
    //     }),
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //         (BuildContext context, int index) {
    //           return buildItem(context, index);
    //         },
    //         childCount: _data.length,
    //       ),
    //     ),
    //
    //     // const SliverFillRemaining(
    //     //   child: Center(
    //     //     child: Text('没有内容'),
    //     //   ),
    //     // ),
    //   ],
    // );

    child = PullToRefreshNotification(
      child: child,
      onRefresh: _refresh,
      pullBackOnRefresh: false,
      armedDragUpCancel: false,
      maxDragOffset: 80,
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

    child = Row(
      children: <Widget>[
        Expanded(child: child),
        // Expanded(child: pullToRefresh),
      ],
    );

    return Scaffold(
      appBar: AppBar(),
      body: child,
    );
  }
}
