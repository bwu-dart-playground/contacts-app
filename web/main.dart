import 'dart:js' as js;
import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_animated_pages.dart';
import 'package:contacts_app/elements/info-page/info_page.dart';

//import 'package:bwu_polymer_routing/module.dart' as brt;
import 'package:route_hierarchical/client.dart' show Router;

class Model extends Object with Observable {

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

  @observable bool largeScreen = false;
  @observable int selected;

  Router router;

  Model() {
    initRouter();
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
    app.$['ajax'].go();
    heading = category.substring(0, 1).toUpperCase() + category.substring(1);
    if (heading == 'All') {
      heading = 'All Contacts';
    }
    // In a non-sample app you probably would want to match the
    // routes to pages in a dictionary and then use valueattr on
    // core-animated-pages to pickout which child matches the current route.
    // To keep this sample easy, we're just manually changing the page number.
    pages.selected = 0;
  }

  void infoEnter(String category, String contactId) {
    if (contacts == null || contacts.isEmpty) {
      router.gotoUrl(DEFAULT_ROUTE);
      return;
    }
    infoPage.contactId = int.parse(contactId);
    pages.selected = 1;
  }

  void addEnter () {
    if (contacts == null || contacts.isEmpty) {
      router.gotoUrl(DEFAULT_ROUTE);
      return;
    }
    pages.selected = 2;
  }
}

AutoBindingElement app;
CoreAnimatedPages pages;
InfoPage infoPage;
// Setup routing
final DEFAULT_ROUTE = '/contacts/all';


void main() {
  // dummy to satisfy the di transformer
  //brt.RouteCfg y;
  initPolymer().run(() {
      // code here works most of the time
      Polymer.onReady.then((_) {
        // some things must wait until onReady callback is called
        // for an example look at the discussion linked below
        initApp();
      });
    });
}

void initApp() {

    // Install Service Worker
//  if (dom.window.navigator.serviceWorker != null) {
//    dom.window.navigator.serviceWorker.register('/worker.js').then((reg) {
//      dom.window.console.log('◕‿◕, ${reg}');
//    }, onError: (err) {
//      dom.window.console.log('ಠ_ಠ, ${err}');
//    });
//  }

  // Select auto-binding template and use as the top level of our app
  app = dom.document.querySelector('template#app');
  app.model = new Model();

  app.on['template-bound'].listen((e) {
    pages = dom.document.querySelector('#pages');
    infoPage = dom.document.querySelector('info-page');

    // Setup categories
    app.model.category = 'all';

    app.model.router
    ..listen()
    ..gotoUrl(DEFAULT_ROUTE);

    // Listen for pages to fire their change-route event
    // Instead of letting them change the route directly,
    // handle the event here and change the route for them
    dom.document.addEventListener('change-route', (dom.CustomEvent e) {
      if (e.detail != null) {
        app.model.router.gotoUrl(e.detail); // {'category': 'all'});
      }
    });

    // Similar to change-route, listen for when a page wants to go
    // back to the previous state and change the route for them
    dom.document.addEventListener('change-route-back', (dom.Event e) {
      dom.window.history.back();
    });

    // Handle page transitions
    pages.addEventListener('core-animated-pages-transition-prepare', (dom.Event e) {
      pages.selectedItem.querySelector('.page').willPrepare();
    });

    // Set duration for core-animated-pages transitions
    js.context.callMethod('setCoreStyleTransitionsDuration', ['0.2s']);
  });
}


