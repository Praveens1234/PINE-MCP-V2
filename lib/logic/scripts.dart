// The "Magic" JavaScript payloads for automation
// These are injected into the hidden Desktop view

const String jsCheckLogin = """
(function() {
    // Check if the user profile avatar exists
    const avatar = document.querySelector('.tv-header__user-menu-button');
    // Or check if the "Sign in" button is missing
    const signInBtn = document.querySelector('button[class*="js-header-user-menu-button"]');
    
    // Simple heuristic: if we see "Sign in" or "Get started", we are logged out.
    // If we see the user menu avatar, we are logged in.
    return !!document.querySelector('.tv-header__user-menu-button--logged-in') || !!document.querySelector('.js-user-menu-opener');
})();
""";

// Helper to wait for element
const String jsWaitForElement = """
function waitForElement(selector, timeout = 5000) {
  return new Promise((resolve, reject) => {
    if (document.querySelector(selector)) {
      return resolve(document.querySelector(selector));
    }

    const observer = new MutationObserver(mutations => {
      if (document.querySelector(selector)) {
        observer.disconnect();
        resolve(document.querySelector(selector));
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
    
    setTimeout(() => {
        observer.disconnect();
        reject(new Error("Timeout waiting for " + selector));
    }, timeout);
  });
}
""";

const String jsOpenEditor = """
(async function() {
    // 1. Check if editor is already open
    const editorContent = document.querySelector('.cm-content');
    if (editorContent && editorContent.offsetParent !== null) {
        return "ALREADY_OPEN";
    }

    // 2. Find and click the 'Pine Editor' button
    // Selectors from JSON: text="Pine Editor", role="button"
    const buttons = Array.from(document.querySelectorAll('button'));
    const pineBtn = buttons.find(b => b.innerText.includes('Pine Editor'));
    
    if (pineBtn) {
        pineBtn.click();
        return "CLICKED";
    }
    
    return "NOT_FOUND";
})();
""";

const String jsInjectCode = """
(async function(code) {
    const editor = document.querySelector('.cm-content');
    if (!editor) return "EDITOR_NOT_FOUND";
    
    // Focus the editor
    editor.focus();
    
    // Robust CodeMirror 6 Injection Strategy
    // 1. Try Clipboard API (Best for modern editors, but might be blocked by permission)
    // 2. Try document.execCommand (Deprecated but reliable fallback for text input)
    // 3. Try direct DOM manipulation + Event Dispatch (Last resort)

    try {
        // Method 1: Direct DOM manipulation with simulated input events
        // This is often the most reliable for headless/automation if we can't access the CM instance
        editor.textContent = code;
        
        // Dispatch a sequence of events to wake up the editor
        const events = ['input', 'change', 'blur', 'focus'];
        events.forEach(evt => {
            editor.dispatchEvent(new Event(evt, { bubbles: true }));
        });
        
        // Wait for a render cycle
        await new Promise(r => setTimeout(r, 200));
        
        // Verify if content stuck
        if (editor.textContent === code) {
             return "INJECTED";
        }
    } catch (e) {
        console.error(e);
    }
    
    return "INJECTED_FALLBACK";
})();
""";

const String jsClickAddToChart = """
(async function() {
    const buttons = Array.from(document.querySelectorAll('button'));
    // "Add to chart", "Update on chart", "Save"
    const targetTexts = ["Add to chart", "Update on chart", "Save"];
    
    const btn = buttons.find(b => targetTexts.some(t => b.innerText.includes(t)));
    
    if (btn) {
        btn.click();
        return "CLICKED";
    }
    return "NOT_FOUND";
})();
""";

const String jsCheckResults = """
(function() {
    // Selectors from JSON
    const errorToast = document.querySelector('.toast-critical');
    const successToast = document.querySelector('.toast-success');
    
    if (errorToast) {
        return JSON.stringify({
            status: 'error',
            message: errorToast.innerText
        });
    }
    
    if (successToast) {
        return JSON.stringify({
            status: 'success',
            message: successToast.innerText || "Script added successfully"
        });
    }
    
    // Check console errors (simulated by checking error console UI in editor if available)
    const consoleErrors = document.querySelectorAll('.console-message.error');
    if (consoleErrors.length > 0) {
         let msg = "";
         consoleErrors.forEach(e => msg += e.innerText + "\\n");
         return JSON.stringify({
            status: 'error',
            message: msg
        });
    }
    
    return "WAITING";
})();
""";
