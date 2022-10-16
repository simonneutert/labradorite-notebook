ready(() => {
  if (document.getElementById("memos-edit")) {
    const elems = ["show-editor-form", "show-preview"];
    elems.forEach((id) => {
      document.getElementById(id).addEventListener("click", (e) => {
        Array.from(
          document.getElementById("form-menu").getElementsByTagName("a")
        ).forEach((element) => {
          element.classList.remove("active");
        });
        console.log(e);
        if (e.target.parentElement.id == "show-editor-form") {
          document.getElementById("memo-form-content").style.display = "";
          document.getElementById("memo-form-preview").style.display = "none";
        } else {
          document.getElementById("memo-form-content").style.display = "none";
          document.getElementById("memo-form-preview").style.display = "";
        }
        e.target.classList.add("active");
      });
    });
  }
});
