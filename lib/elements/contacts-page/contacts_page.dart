library contacts_app.app.elements.contacts_page;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart';

import '../base-page/base_page.dart';

@CustomTag('contacts-page')
class ContactsPage extends BasePage {
  ContactsPage.created() : super.created();

  @observable List contacts;
  @observable String heading;
  @observable String category;


  void willPrepare() {
    super.willPrepare();
    $['list'].updateSize();
  }

  void navigateIndex(dom.Event e, var detail, dom.AnchorElement sender) {
    e.preventDefault();
    fire('change-route', detail: '/contacts/${category}/${sender.attributes['route']}' /*href*/);
  }

  void closeDrawer() {
    // Maybe this could wait till the next frame before animating
    // out... right now it animates while the list is rebuilding
    // and causes some jank
    $['drawerPanel'].closeDrawer();
  }
}
