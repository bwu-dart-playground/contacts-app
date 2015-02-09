library contacts_app.app.elements.add_page;

import 'package:polymer/polymer.dart';

import '../base-page/base_page.dart';

@CustomTag('add-page')
class AddPage extends BasePage {
  AddPage.created() : super.created();

  @observable String contactName;

  List contacts;

  void willPrepare() {
    super.willPrepare();

    // Reset the scroller so every time the user comes to the add page
    // they see the top of the form
    $['headerPanel'].scroller.scrollTop = 0;
  }
}
