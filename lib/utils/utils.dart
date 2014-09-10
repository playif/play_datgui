part of datgui;

class CSS{
  static load(String url, [HtmlDocument doc]) {
    doc = doc == null ? document : doc;
    LinkElement link = new LinkElement();
    link.type = 'text/css';
    link.rel = 'stylesheet';
    link.href = url;
    doc.getElementsByTagName('head')[0].append(link);
  }

  static inject(String css, [HtmlDocument doc]) {
    doc = doc == null ? document : doc;
    StyleElement injected = new StyleElement();
    injected.type = 'text/css';
    injected.innerHtml = css;
    doc.getElementsByTagName('head')[0].append(injected);
  }
}


