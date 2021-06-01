import 'package:flutter/material.dart';

///嵌套导航路由
///启动时添加一个Router，然后在主页面再添加一个Router
void main() {
  runApp(NestedRouterDemo());
}

///
class Book {
  ///
  final String title;

  ///
  final String author;

  ///
  Book(this.title, this.author);
}

///
class NestedRouterDemo extends StatefulWidget {
  @override
  _NestedRouterDemoState createState() => _NestedRouterDemoState();
}

class _NestedRouterDemoState extends State<NestedRouterDemo> {
  BookRouterDelegate _routerDelegate = BookRouterDelegate();
  BookRouteInformationParser _routeInformationParser =
      BookRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

///
class BooksAppState extends ChangeNotifier {
  int _selectedIndex;

  Book? _selectedBook;

  ///
  final List<Book> books = <Book>[
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  ///
  BooksAppState() : _selectedIndex = 0;

  // ignore: public_member_api_docs
  int get selectedIndex => _selectedIndex;

  // ignore: public_member_api_docs
  set selectedIndex(int idx) {
    _selectedIndex = idx;
    if (_selectedIndex == 1) {
      // Remove this line if you want to keep the selected book when navigating
      // between "settings" and "home" which book was selected when Settings is
      // tapped.
      selectedBook = null;
    }
    notifyListeners();
  }

  // ignore: public_member_api_docs
  Book? get selectedBook => _selectedBook;

  // ignore: public_member_api_docs
  set selectedBook(Book? book) {
    _selectedBook = book;
    notifyListeners();
  }

  // ignore: public_member_api_docs
  int getSelectedBookById() {
    if (!books.contains(_selectedBook)) {
      return 0;
    }
    return books.indexOf(_selectedBook!);
  }

  // ignore: public_member_api_docs
  void setSelectedBookById(int id) {
    if (id < 0 || id > books.length - 1) {
      return;
    }

    _selectedBook = books[id];
    notifyListeners();
  }
}

// ignore: public_member_api_docs
class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final Uri uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'settings') {
      return BooksSettingsPath();
    } else {
      if (uri.pathSegments.length >= 2) {
        if (uri.pathSegments[0] == 'book') {
          return BooksDetailsPath(int.tryParse(uri.pathSegments[1])!);
        }
      }
      return BooksListPath();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(BookRoutePath configuration) {
    if (configuration is BooksListPath) {
      return const RouteInformation(location: '/home');
    }
    if (configuration is BooksSettingsPath) {
      return const RouteInformation(location: '/settings');
    }
    if (configuration is BooksDetailsPath) {
      return RouteInformation(location: '/book/${configuration.id}');
    }
    return null;
  }
}

///
class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  ///
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  // ignore: public_member_api_docs
  BooksAppState appState = BooksAppState();

  // ignore: public_member_api_docs
  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    appState.addListener(notifyListeners);
  }

  @override
  BookRoutePath get currentConfiguration {
    if (appState.selectedIndex == 1) {
      return BooksSettingsPath();
    } else {
      if (appState.selectedBook == null) {
        return BooksListPath();
      } else {
        return BooksDetailsPath(appState.getSelectedBookById());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <MaterialPage<dynamic>>[
        MaterialPage<dynamic>(
          child: AppShell(appState: appState),
        ),
      ],
      onPopPage: (Route<dynamic> route, dynamic result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (appState.selectedBook != null) {
          appState.selectedBook = null;
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path is BooksListPath) {
      appState.selectedIndex = 0;
      appState.selectedBook = null;
    } else if (path is BooksSettingsPath) {
      appState.selectedIndex = 1;
    } else if (path is BooksDetailsPath) {
      appState.setSelectedBookById(path.id);
    }
  }
}

// Routes
// ignore: public_member_api_docs
abstract class BookRoutePath {}

// ignore: public_member_api_docs
class BooksListPath extends BookRoutePath {}

// ignore: public_member_api_docs
class BooksSettingsPath extends BookRoutePath {}

// ignore: public_member_api_docs
class BooksDetailsPath extends BookRoutePath {
  // ignore: public_member_api_docs
  final int id;

  // ignore: public_member_api_docs
  BooksDetailsPath(this.id);
}

// Widget that contains the AdaptiveNavigationScaffold
// ignore: public_member_api_docs
class AppShell extends StatefulWidget {
  // ignore: public_member_api_docs
  final BooksAppState appState;

  // ignore: public_member_api_docs
  const AppShell({
    required this.appState,
  });

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late InnerRouterDelegate _routerDelegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    _routerDelegate = InnerRouterDelegate(widget.appState);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _routerDelegate.appState = widget.appState;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    final BooksAppState appState = widget.appState;

    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    return Scaffold(
      appBar: AppBar(),
      body: Router<BookRoutePath>(
        routerDelegate: _routerDelegate,
        backButtonDispatcher: _backButtonDispatcher,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: appState.selectedIndex,
        onTap: (int newIndex) {
          appState.selectedIndex = newIndex;
        },
      ),
    );
  }
}

// ignore: public_member_api_docs
class InnerRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // ignore: public_member_api_docs
  BooksAppState get appState => _appState;
  BooksAppState _appState;

  // ignore: public_member_api_docs
  set appState(BooksAppState value) {
    if (value == _appState) {
      return;
    }
    _appState = value;
    notifyListeners();
  }

  // ignore: public_member_api_docs
  InnerRouterDelegate(this._appState);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<dynamic>>[
        if (appState.selectedIndex == 0) ...<Page<dynamic>>[
          FadeAnimationPage(
            child: BooksListScreen(
              books: appState.books,
              onTapped: _handleBookTapped,
            ),
            key: const ValueKey<String>('BooksListPage'),
          ),
          if (appState.selectedBook != null)
            MaterialPage<dynamic>(
              key: ValueKey<Book?>(appState.selectedBook),
              child: BookDetailsScreen(book: appState.selectedBook),
            ),
        ] else
          FadeAnimationPage(
            child: SettingsScreen(),
            key: const ValueKey<String>('SettingsPage'),
          ),
      ],
      onPopPage: (Route<dynamic> route, dynamic result) {
        appState.selectedBook = null;
        notifyListeners();
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath configuration) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }

  void _handleBookTapped(Book book) {
    appState.selectedBook = book;
    notifyListeners();
  }
}

// ignore: public_member_api_docs
class FadeAnimationPage extends Page<dynamic> {
  // ignore: public_member_api_docs
  final Widget child;

  // ignore: public_member_api_docs
  const FadeAnimationPage({LocalKey? key, required this.child})
      : super(key: key);

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return PageRouteBuilder<dynamic>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> animation2) {
        final CurveTween curveTween = CurveTween(curve: Curves.easeIn);
        return FadeTransition(
          opacity: animation.drive(curveTween),
          child: child,
        );
      },
    );
  }
}

// Screens
// ignore: public_member_api_docs
class BooksListScreen extends StatelessWidget {
  // ignore: public_member_api_docs
  final List<Book> books;

  // ignore: public_member_api_docs
  final ValueChanged<Book> onTapped;

  // ignore: public_member_api_docs
  const BooksListScreen({
    required this.books,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          for (Book book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

// ignore: public_member_api_docs
class BookDetailsScreen extends StatelessWidget {
  // ignore: public_member_api_docs
  final Book? book;

  // ignore: public_member_api_docs
  const BookDetailsScreen({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
            ),
            if (book != null) ...<Widget>[
              Text(book!.title, style: Theme.of(context).textTheme.headline6),
              Text(book!.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

// ignore: public_member_api_docs
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings screen'),
      ),
    );
  }
}
