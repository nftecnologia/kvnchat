// Force title update to remove "Chatwoot" from browser tab
export const forceTitleUpdate = () => {
  // Get the current title
  const currentTitle = document.title;

  // If title contains "Chatwoot", replace it with "Kirvano"
  if (currentTitle && currentTitle.includes('Chatwoot')) {
    document.title = currentTitle.replace(/Chatwoot/g, 'Kirvano');
  }

  // Monitor for any title changes and fix them
  const titleElement = document.querySelector('title');
  if (titleElement) {
    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        if (
          mutation.type === 'childList' ||
          mutation.type === 'characterData'
        ) {
          const newTitle = document.title;
          if (newTitle && newTitle.includes('Chatwoot')) {
            document.title = newTitle.replace(/Chatwoot/g, 'Kirvano');
          }
        }
      });
    });

    observer.observe(titleElement, {
      childList: true,
      characterData: true,
      subtree: true,
    });
  }

  // Also override document.title setter to intercept any direct changes
  const originalTitleDescriptor = Object.getOwnPropertyDescriptor(
    Document.prototype,
    'title'
  );
  if (originalTitleDescriptor) {
    Object.defineProperty(document, 'title', {
      get: originalTitleDescriptor.get,
      set: function (newTitle) {
        if (newTitle && newTitle.includes('Chatwoot')) {
          newTitle = newTitle.replace(/Chatwoot/g, 'Kirvano');
        }
        originalTitleDescriptor.set.call(this, newTitle);
      },
    });
  }
};

// Run immediately when loaded
forceTitleUpdate();

// Run after DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', forceTitleUpdate);
} else {
  forceTitleUpdate();
}

// Run after a short delay to catch any async title updates
setTimeout(forceTitleUpdate, 100);
setTimeout(forceTitleUpdate, 500);
setTimeout(forceTitleUpdate, 1000);
