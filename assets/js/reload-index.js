if (document.getElementById("memos-search")) {
  window.reloadIndex = (e) => {
    e.target.style.display = "none";
    fetch("/api/v1/memos/reload", {
      method: "post",
    })
      .then((res) => {
        e.target.style.display = "";
      })
      .catch((e) => {
        console.console.error(e);
        e.target.style.display = "none";
      });
  };
}
