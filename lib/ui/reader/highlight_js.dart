/// JavaScript code injected into the WebView for text selection and highlighting.
const String highlightJs = r'''
(function() {
  // --- XPath utilities ---
  function getXPath(node) {
    if (!node || node === document) return '/';
    if (node.nodeType === Node.TEXT_NODE) {
      var sibling = node.parentNode.firstChild;
      var index = 0;
      while (sibling) {
        if (sibling.nodeType === Node.TEXT_NODE) index++;
        if (sibling === node) break;
        sibling = sibling.nextSibling;
      }
      return getXPath(node.parentNode) + '/text()[' + index + ']';
    }
    if (node.id) return '//*[@id="' + node.id + '"]';
    var siblings = node.parentNode ? node.parentNode.children : [];
    var sameTag = [];
    for (var i = 0; i < siblings.length; i++) {
      if (siblings[i].tagName === node.tagName) sameTag.push(siblings[i]);
    }
    var tagIndex = sameTag.indexOf(node) + 1;
    return getXPath(node.parentNode) + '/' + node.tagName.toLowerCase() + '[' + tagIndex + ']';
  }

  function getNodeByXPath(xpath) {
    try {
      var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
      return result.singleNodeValue;
    } catch(e) { return null; }
  }

  // --- Highlight application ---
  function applyHighlight(id, rangeStart, startOffset, rangeEnd, endOffset, color) {
    try {
      var startNode = getNodeByXPath(rangeStart);
      var endNode = getNodeByXPath(rangeEnd);
      if (!startNode || !endNode) return false;

      var range = document.createRange();
      range.setStart(startNode, Math.min(startOffset, startNode.length || 0));
      range.setEnd(endNode, Math.min(endOffset, endNode.length || 0));

      // Wrap in a highlight span
      var wrapper = document.createElement('span');
      wrapper.className = 'booktopia-highlight';
      wrapper.dataset.highlightId = id;
      wrapper.style.backgroundColor = color;
      wrapper.style.borderRadius = '2px';
      wrapper.style.cursor = 'pointer';

      // Handle multi-node selections by extracting and wrapping
      try {
        range.surroundContents(wrapper);
      } catch(e) {
        // For cross-element selections, highlight each text node individually
        var nodes = getTextNodesInRange(range);
        for (var i = 0; i < nodes.length; i++) {
          var textNode = nodes[i];
          var span = document.createElement('span');
          span.className = 'booktopia-highlight';
          span.dataset.highlightId = id;
          span.style.backgroundColor = color;
          span.style.borderRadius = '2px';
          span.style.cursor = 'pointer';
          textNode.parentNode.insertBefore(span, textNode);
          span.appendChild(textNode);
        }
      }

      // Add tap handler for highlight
      var highlights = document.querySelectorAll('[data-highlight-id="' + id + '"]');
      for (var h = 0; h < highlights.length; h++) {
        highlights[h].addEventListener('click', function(e) {
          e.stopPropagation();
          window.flutter_inappwebview.callHandler('onHighlightTap', id);
        });
      }
      return true;
    } catch(e) {
      return false;
    }
  }

  function getTextNodesInRange(range) {
    var nodes = [];
    var treeWalker = document.createTreeWalker(
      range.commonAncestorContainer,
      NodeFilter.SHOW_TEXT,
      null, false
    );
    while (treeWalker.nextNode()) {
      var node = treeWalker.currentNode;
      if (range.intersectsNode(node) && node.textContent.trim().length > 0) {
        nodes.push(node);
      }
    }
    return nodes;
  }

  function removeHighlight(id) {
    var spans = document.querySelectorAll('[data-highlight-id="' + id + '"]');
    for (var i = 0; i < spans.length; i++) {
      var span = spans[i];
      var parent = span.parentNode;
      while (span.firstChild) {
        parent.insertBefore(span.firstChild, span);
      }
      parent.removeChild(span);
      parent.normalize();
    }
  }

  // --- Selection handler ---
  var selectionTimeout = null;
  document.addEventListener('selectionchange', function() {
    clearTimeout(selectionTimeout);
    selectionTimeout = setTimeout(function() {
      var sel = window.getSelection();
      if (!sel || sel.isCollapsed || !sel.toString().trim()) {
        window.flutter_inappwebview.callHandler('onSelectionDismissed');
        return;
      }

      var range = sel.getRangeAt(0);
      var text = sel.toString().trim();
      if (text.length < 2) return;

      var startXPath = getXPath(range.startContainer);
      var endXPath = getXPath(range.endContainer);

      // Get bounding rect of selection for toolbar positioning
      var rect = range.getBoundingClientRect();

      window.flutter_inappwebview.callHandler('onTextSelected', JSON.stringify({
        text: text,
        startXPath: startXPath,
        startOffset: range.startOffset,
        endXPath: endXPath,
        endOffset: range.endOffset,
        rectTop: rect.top,
        rectBottom: rect.bottom,
        rectLeft: rect.left,
        rectRight: rect.right
      }));
    }, 400);
  });

  // Expose functions globally
  window.booktopiaApplyHighlight = applyHighlight;
  window.booktopiaRemoveHighlight = removeHighlight;
})();
''';

/// Generate JS call to apply a single highlight.
String jsApplyHighlight({
  required int id,
  required String rangeStart,
  required int startOffset,
  required String rangeEnd,
  required int endOffset,
  required String colorHex,
}) {
  final escapedStart = rangeStart.replaceAll("'", "\\'");
  final escapedEnd = rangeEnd.replaceAll("'", "\\'");
  return "window.booktopiaApplyHighlight('$id', '$escapedStart', $startOffset, '$escapedEnd', $endOffset, '$colorHex');";
}

/// Generate JS call to remove a highlight.
String jsRemoveHighlight(int id) {
  return "window.booktopiaRemoveHighlight('$id');";
}
