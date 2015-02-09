library contacts_app.app.elements.info_page;

import 'dart:html' as dom;
import 'dart:math' as math;

import 'package:polymer/polymer.dart';

import '../base-page/base_page.dart';

@CustomTag('info-page')
class InfoPage extends BasePage {
  InfoPage.created() : super.created();

  @observable int contactId;
  @observable List contacts;
  @observable bool largeScreen;
  @observable Map contact;

  void domReady() {
    // custom transformation: scale header's title
    var titleStyle = $['title'].style;
    dom.document.addEventListener('core-header-transform', (dom.CustomEvent e) {
      Map d = e.detail;
      double m = d['height'] - d['condensedHeight'];
      double scale = math.max(0.55, (m - nullToZero(d['y'])) / (m / 0.25) + 0.55);
      titleStyle.transform = titleStyle.transform =
        'scale(${scale}) translateZ(0)';
    });
  }

  double nullToZero(val) {
    if(val == null) {
      return 0.0;
    }
    return val;
  }

  void willPrepare() {
    super.willPrepare();
    // Measure the core-scroll-header-panel, otherwise its height will
    // be messed up
    $['scrollHeaderPanel'].measureHeaderHeight();

    // Reset the scroller so every time the user comes to the info page
    // so they see the full profile photo
    $['scrollHeaderPanel'].scroller.scrollTop = 0;
  }


  void contactIdChanged(oldVal, newVal) {
    contact = contacts[newVal];

    if (largeScreen) return;

    // Update the core-scroll-header-panel's background image with the
    // user's avatar if we're on a small screen
    $['scrollHeaderPanel'].$['headerBg'].style.background = 'url(${contact['avatar']}) 0 / cover no-repeat';
  }
}
