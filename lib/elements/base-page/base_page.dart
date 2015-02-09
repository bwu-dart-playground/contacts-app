library contacts_app.app.elements.base_page;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart';

@CustomTag('base-page')
class BasePage extends PolymerElement {
  BasePage.created() : super.created();

  // `willPrepare` is called by app.js when the
  // core-animated-pages begins its
  // 'core-animated-pages-transition-prepare' event.
  // At this point the element is no longer display: none;
  // so if you need to do anything with height in JavaScript
  // this is the time to do it :)
  void willPrepare() {}

  // `navigate` is called in response to someone clicking on
  // an anchor tag. The normal click behavior is stopped to
  // prevent a page refresh, and the href is sent to the router
  // so it can change the current route
  void navigate(dom.Event e, var detail, dom.AnchorElement sender) {
    e.preventDefault();
    fire('change-route', detail: sender.attributes['route'] /*href*/);
  }

  void goBack(dom.Event e) {
    e.preventDefault();
    fire('change-route-back');
  }
}
