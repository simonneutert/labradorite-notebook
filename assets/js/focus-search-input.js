if (document.getElementsByClassName("enable-search-keyboard-shortcut")) {
  (() => {
    document.body.addEventListener("keydown", function (e) {
      if (e.key == "f" && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        document.getElementById("search").focus({ focusVisible: true });
      }
    });
  })();
}
