(function () {
  function initMemosPreview(contentFormElement, searchAbortControllerX) {
    searchAbortControllerX = new AbortController();
    let markdownContent = contentFormElement.value;

    if (!markdownContent) {
      return;
    }

    fetch("http://localhost:9292/api/v1/memos/preview", {
      signal: searchAbortControllerX.signal,
      method: "POST",
      cache: "no-cache",
      headers: {
        "Content-Type": "application/json",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: JSON.stringify({ md: markdownContent }),
    })
      .then((response) => response.json())
      .catch((e) => console.error(e))
      .then((data) => {
        if (data && data.md) {
          document.getElementById("content-preview").innerHTML = data["md"];
        }
      });
  }

  let debounce = undefined;
  let searchAbortControllerX = new AbortController();
  let contentFormElement = document.getElementById("content");

  contentFormElement.addEventListener("keyup", (e) => {
    if (debounce) {
      clearTimeout(debounce);
      searchAbortControllerX.abort();
    }
    debounce = setTimeout(() => {
      initMemosPreview(contentFormElement, searchAbortControllerX);
    }, 200);
  });
})();
