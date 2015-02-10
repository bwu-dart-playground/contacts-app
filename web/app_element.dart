import 'dart:js' as js;
import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_animated_pages.dart';
import 'package:contacts_app/elements/info-page/info_page.dart';
import 'package:route_hierarchical/client.dart' show Router;

@CustomTag('app-element')
class AppElement extends PolymerElement {

  static const DEFAULT_ROUTE = '/contacts/all';

  CoreAnimatedPages _pages;
  InfoPage _infoPage;
  Router router;

  AppElement.created() : super.created() {
    // Set duration for core-animated-pages transitions
    js.context.callMethod('setCoreStyleTransitionsDuration', ['0.2s']);

    initRouter();
  }

  @observable bool largeScreen = false;
  @observable int selected;

  @observable String category;
  @observable String heading;

  ObservableList _contacts;
  @observable ObservableList get contacts => _contacts;
  set contacts(List contacts) {
    final old = _contacts;
    if(contacts is ObservableList) {
      _contacts = contacts;
    }
    _contacts = toObservable(contacts);
    notifyPropertyChange(#contacts, old, _contacts);
  }

  void initRouter() {
    router = new Router(useFragment: true)
    ..root.addRoute(
      name: 'add',
      path: '/add',
      enter: (route) => addEnter())
    ..root.addRoute(
      name: 'contacts',
      path: '/contacts',
      mount: (router) =>
          router
            ..addRoute(
              name: 'contacts_list',
              path: '/:category',
              enter: (route) => contactsEnter(route.parameters['category']))
          ..addRoute(
              name: 'contact_detail',
              path: '/:category/:id',
              enter: (route) => infoEnter(route.parameters['category'], route.parameters['id'])));
  }

  void contactsEnter (String category) {
    this.category = category;
    $['ajax'].go();
    heading = category.substring(0, 1).toUpperCase() + category.substring(1);
    if (heading == 'All') {
      heading = 'All Contacts';
    }
    // In a non-sample app you probably would want to match the
    // routes to pages in a dictionary and then use valueattr on
    // core-animated-pages to pickout which child matches the current route.
    // To keep this sample easy, we're just manually changing the page number.
    _pages.selected = 0;
  }

  void infoEnter(String category, String contactId) {
    if (contacts == null || contacts.isEmpty) {
      router.gotoUrl(DEFAULT_ROUTE);
      return;
    }
    _infoPage.contactId = int.parse(contactId);
    _pages.selected = 1;
  }

  void addEnter () {
    if (contacts == null || contacts.isEmpty) {
      router.gotoUrl(DEFAULT_ROUTE);
      return;
    }
    _pages.selected = 2;
  }

  @override
  domReady() {
    _pages = shadowRoot.querySelector('#pages');
    _infoPage = shadowRoot.querySelector('info-page');

    // Setup categories
    category = 'all';

    router
    ..listen()
    ..gotoUrl(DEFAULT_ROUTE);

    // Listen for pages to fire their change-route event
    // Instead of letting them change the route directly,
    // handle the event here and change the route for them
    dom.document.addEventListener('change-route', (dom.CustomEvent e) {
      if (e.detail != null) {
        router.gotoUrl(e.detail); // {'category': 'all'});
      }
    });

    // Similar to change-route, listen for when a page wants to go
    // back to the previous state and change the route for them
    dom.document.addEventListener('change-route-back', (dom.Event e) {
      dom.window.history.back();
    });

    // Handle page transitions
    _pages.addEventListener('core-animated-pages-transition-prepare', (dom.Event e) {
      _pages.selectedItem.querySelector('.page').willPrepare();
    });
  }
}
