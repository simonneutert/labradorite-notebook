ready(() => {
  if (document.getElementById("memos-edit")) {
    const elems = ["show-editor-form", "show-preview"];
    elems.forEach((id) => {
      document.getElementById(id).addEventListener("click", (event) => {
        Array.from(
          document.getElementById("form-menu").getElementsByTagName("a"),
        ).forEach((element) => {
          element.classList.remove("active");
        });
        if (event.target.parentElement.id == "show-editor-form") {
          document.getElementById("memo-form-content").style.display = "";
          document.getElementById("memo-form-preview").style.display = "none";
          // Ensure TinyMDE editor content is synced back to textarea
          if (window.tinyMDE) {
            // TinyMDE automatically syncs to textarea, but we can trigger focus
            window.tinyMDE.element.focus();
          }
        } else {
          document.getElementById("memo-form-content").style.display = "none";
          document.getElementById("memo-form-preview").style.display = "";
        }
        event.target.classList.add("active");
      });
    });
  }
});
