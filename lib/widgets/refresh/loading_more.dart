import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///加载状态改变的回调
typedef OnLoadStateChange = void Function(LoadState state);

///加载更多布局
typedef OnFooterBuilder = Widget Function(LoadState state);

///加载状态
enum LoadState {
  ///开始拖动
  drag,

  ///开始加载
  refresh,

  ///结束加载
  refreshComplete,
}

///自定义 上拉加载，使用[Notification]来监听滚动距离
class LoadingMore extends StatefulWidget {
  /// 构造
  const LoadingMore(
      {Key? key, required this.child, this.onLoadMore, this.onLoadStateChange})
      : super(key: key);

  /// 子widget
  final Widget child;

  ///加载更多
  final AsyncCallback? onLoadMore;

  /// 加载状态
  final OnLoadStateChange? onLoadStateChange;

  @override
  _LoadingMoreState createState() => _LoadingMoreState();
}

class _LoadingMoreState extends State<LoadingMore> {
  bool _isLoading = false;

  ScrollDirection? _scrollDirection;
  LoadState _loadState = LoadState.refreshComplete;

  Future<void> _loadMore() async {
    _isLoading = true;
    _loadState = LoadState.refresh;
    widget.onLoadStateChange?.call(LoadState.refresh);
    await widget.onLoadMore?.call();
    _isLoading = false;
    _loadState = LoadState.refreshComplete;
    widget.onLoadStateChange?.call(LoadState.refreshComplete);
  }

  ///处理上拉
  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification is UserScrollNotification) {
      if (notification.metrics.pixels >= notification.metrics.maxScrollExtent) {
        if (notification.direction == ScrollDirection.reverse &&
            _loadState != LoadState.drag &&
            !_isLoading) {
          ///用户拖动
          _scrollDirection = notification.direction;
          _loadState = LoadState.drag;
          widget.onLoadStateChange?.call(_loadState);
        } else if (notification.direction == ScrollDirection.idle &&
            _scrollDirection == ScrollDirection.reverse) {
          ///结束上拉并且列表停止滑动

          if (notification.metrics.axisDirection == AxisDirection.down &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent &&
              !_isLoading) {
            _loadMore();
          }
          _scrollDirection = ScrollDirection.idle;
        }
      }
    }

    return false;
  }

  ///取消android的 滚动水波纹效果
  ///cancel GlowingOverscrollIndicator;
  bool glowingIndicator(OverscrollIndicatorNotification notification) {
    if (notification.leading || !notification.leading) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: glowingIndicator,
        child: widget.child,
      ),
    );
  }
}

///加载更多列表
class LoadingMoreListView extends StatefulWidget {
  ///加载更多列表
  const LoadingMoreListView({
    Key? key,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.itemCount,
    this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.footerBuilder,
  }) : super(key: key);

  ///构建item
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final SliverGridDelegate? gridDelegate;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final int itemCount;
  final AsyncCallback onLoadMore;
  final OnFooterBuilder? footerBuilder;

  @override
  _LoadingMoreListViewState createState() => _LoadingMoreListViewState();
}

class _LoadingMoreListViewState extends State<LoadingMoreListView> {
  late int _itemCount;
  LoadState _state = LoadState.refreshComplete;

  @override
  void initState() {
    super.initState();
    _itemCount = widget.itemCount;
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == _itemCount - 1) {
      final Widget? footer = widget.footerBuilder?.call(_state);
      if (_state == LoadState.drag) {
        if (footer == null) {
          return Container(
            height: 30,
            alignment: Alignment.center,
            child: const Text('松开加载更多'),
          );
        } else {
          return footer;
        }
      } else if (_state == LoadState.refresh) {
        if (footer == null) {
          return Container(
            height: 30,
            alignment: Alignment.center,
            child: const CupertinoActivityIndicator(),
          );
        } else {
          return footer;
        }
      } else if (_state == LoadState.refreshComplete && footer != null) {
        return footer;
      }
    }
    return widget.itemBuilder(context, index);
  }

  @override
  void didUpdateWidget(covariant LoadingMoreListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemCount = widget.itemCount;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = ListView.builder(
      key: widget.key,
      itemBuilder: _buildItem,
      itemCount: _itemCount,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      itemExtent: widget.itemExtent,
    );

    child = LoadingMore(
      onLoadMore: widget.onLoadMore,
      onLoadStateChange: (LoadState state) {
        _state = state;
        setState(() {
          if (state == LoadState.drag) {
            _itemCount++;
          } else if (state == LoadState.refreshComplete) {
            _itemCount--;
          }
        });
      },
      child: child,
    );

    return child;
  }
}

class LoadingMoreCustomScrollView extends StatefulWidget {
  ///
  const LoadingMoreCustomScrollView({
    Key? key,
    this.slivers = const <Widget>[],
    required this.onLoadMore,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.footerBuilder,
  }) : super(key: key);

  ///
  final List<Widget> slivers;

  ///加载更多回调
  final AsyncCallback onLoadMore;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final OnFooterBuilder? footerBuilder;

  @override
  _LoadingMoreCustomScrollViewState createState() =>
      _LoadingMoreCustomScrollViewState();
}

class _LoadingMoreCustomScrollViewState
    extends State<LoadingMoreCustomScrollView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = widget.slivers;

    Widget child = CustomScrollView(
      slivers: slivers,
      key: widget.key,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      center: widget.center,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
    );

    child = LoadingMore(
      onLoadMore: widget.onLoadMore,
      onLoadStateChange: (LoadState state) {
        setState(() {
          if (state == LoadState.drag) {
            final Widget defaultHint = SliverSafeArea(
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: const Text('松开加载更多'),
                ),
              ),
            );
            final Widget? footer = widget.footerBuilder?.call(state);
            if (footer == null) {
              slivers.add(
                defaultHint,
              );
            } else {
              slivers.add(footer);
            }
          } else if (state == LoadState.refresh) {
            slivers.removeAt(slivers.length - 1);
            final Widget defaultRefresh = SliverSafeArea(
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: const CupertinoActivityIndicator(),
                ),
              ),
            );
            final Widget? footer = widget.footerBuilder?.call(state);
            if (footer == null) {
              slivers.add(defaultRefresh);
            } else {
              slivers.add(footer);
            }
          } else if (state == LoadState.refreshComplete) {
            final Widget? footer = widget.footerBuilder?.call(state);
            if (footer == null) {
              slivers.removeAt(slivers.length - 1);
            } else {
              slivers.add(footer);
            }
          }
        });
      },
      child: child,
    );

    return child;
  }
}
