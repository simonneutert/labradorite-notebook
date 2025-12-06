if (document.getElementsByClassName("enable-search-keyboard-shortcut")) {
  (() => {
    // Detect OS and update placeholder
    const isMac = navigator.platform.toUpperCase().indexOf("MAC") >= 0;
    const modifierKey = isMac ? "Cmd" : "Ctrl";
    const searchInput = document.getElementById("search");

    if (searchInput) {
      searchInput.placeholder = `${modifierKey} + K to search ...`;
    }

    // Set up keyboard shortcut
    document.body.addEventListener("keydown", function (e) {
      if (e.key == "k" && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        searchInput.focus({ focusVisible: true });
      }
    });
  })();
}
