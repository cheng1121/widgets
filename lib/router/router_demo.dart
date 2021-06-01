import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

///书籍对象
class Book {
  ///构造
  Book(this.title, this.author);

  ///书名
  final String title;

  ///作者
  final String author;
}

///app
class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
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

///路径解析
class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final Uri uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.length >= 2) {
      final String remaining = uri.pathSegments[1];
      return BookRoutePath.details(int.tryParse(remaining)!);
    } else {
      return BookRoutePath.home();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(BookRoutePath configuration) {
    if (configuration.isHomePage) {
      return const RouteInformation(location: '/');
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(location: '/book/${configuration.id}');
    }
    return null;
  }
}

///路由代理
class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  ///key
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  ///
  Book? _selectedBook;

  ///
  List<Book> books = <Book>[
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  ///
  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  BookRoutePath get currentConfiguration => _selectedBook == null
      ? BookRoutePath.home()
      : BookRoutePath.details(books.indexOf(_selectedBook!));

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      transitionDelegate: NoAnimationTransitionDelegate(),
      pages: <Page<dynamic>>[
        MaterialPage<dynamic>(
          key: const ValueKey<String>('BooksListPage'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
          ),
        ),
        if (_selectedBook != null) BookDetailsPage(book: _selectedBook!)
      ],
      onPopPage: (Route<dynamic> route, dynamic result) {
        if (!route.didPop(result)) {
          return false;
        }
// Update the list of pages by setting _selectedBook to null
        _selectedBook = null;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath configuration) async {
    if (configuration.isDetailsPage) {
      _selectedBook = books[configuration.id!];
    }
  }

  void _handleBookTapped(Book book) {
    _selectedBook = book;
    notifyListeners();
  }
}

///
class BookDetailsPage extends Page<dynamic> {
  ///
  final Book book;

  ///
  BookDetailsPage({
    required this.book,
  }) : super(key: ValueKey<Book>(book));

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return MaterialPageRoute<dynamic>(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book);
      },
    );
  }
}

///
class BookRoutePath {
  ///
  final int? id;

  ///
  BookRoutePath.home() : id = null;

  ///
  BookRoutePath.details(this.id);

  ///
  bool get isHomePage => id == null;

  ///
  bool get isDetailsPage => id != null;
}

///
class BooksListScreen extends StatelessWidget {
  ///
  final List<Book> books;

  ///
  final ValueChanged<Book> onTapped;

  ///
  const BooksListScreen({
    required this.books,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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

///
class BookDetailsScreen extends StatelessWidget {
  ///
  final Book book;

  ///
  const BookDetailsScreen({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}

///
class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];
    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final RouteTransitionRecord exitingPageRoute
        in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final List<RouteTransitionRecord>? pagelessRoutes =
            pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}
