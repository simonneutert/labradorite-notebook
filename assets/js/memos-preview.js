ready(() => {
  if (document.getElementById("memos-edit")) {
    (function () {
      const previewUrl = "/api/v1/memos/preview";

      function initMemosPreview(contentFormElement, searchAbortController) {
        searchAbortController = new AbortController();
        // Get content from TinyMDE editor if available, otherwise from textarea
        let markdownContent;
        if (window.tinyMDE) {
          markdownContent = window.tinyMDE.getContent();
        } else {
          markdownContent = contentFormElement.value;
        }

        if (!markdownContent) {
          return;
        }

        fetch(previewUrl, {
          signal: searchAbortController.signal,
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
      let searchAbortController = new AbortController();
      let contentFormElement = document.getElementById("content");
      const showPreviewButton = document.getElementById("show-preview");
      showPreviewButton.addEventListener("click", (event) => {
        if (debounce) {
          clearTimeout(debounce);
          searchAbortController.abort();
        }
        debounce = setTimeout(() => {
          initMemosPreview(contentFormElement, searchAbortController);
        }, 200);
      });
    })();
  }
});
