(() => {
  const searchUrl = "http://localhost:9292/api/v1/memos/search";

  const createSearchResultDomElement = function (url, title, hits) {
    const ele = document.createElement("div");
    const href = document.createElement("a");
    ele.appendChild(href);
    href.href = url;
    const resultHeader = document.createElement("h4");
    resultHeader.appendChild(document.createTextNode(title));
    href.append(resultHeader);
    hits.map((hit) => {
      const hitElement = document.createElement("p");
      hitElement.style.paddingLeft = "1em";
      hitElement.appendChild(document.createTextNode(hit));
      href.appendChild(hitElement);
    });
    return ele;
  };

  const runSearch = function (elem, searchAbortController) {
    searchAbortController = new AbortController();

    if (elem.value.length < 3) {
      // clear content
      document.getElementById("search-results").replaceChildren(...[]);
      return;
    }
    // fetch data replace content
    fetch(searchUrl, {
      signal: searchAbortController.signal,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: JSON.stringify({ search: elem.value }),
    })
      .then((response) => response.json())
      .then((data) => {
        let coll = [];
        data.map((searchResult) => {
          const url = searchResult[0];
          const title = searchResult[1];
          const hits = searchResult[2];

          coll.push(createSearchResultDomElement(url, title, hits));
        });
        document.getElementById("search-results").replaceChildren(...coll);
      });
  };

  const search = document.getElementById("search");
  let debounce = undefined;
  let searchAbortController = new AbortController();

  search.addEventListener("keyup", (e) => {
    if (debounce) {
      clearTimeout(debounce);
      searchAbortController.abort();
    }
    debounce = setTimeout(() => {
      runSearch(search, searchAbortController);
    }, 100);
  });
  runSearch(search, searchAbortController);
})();

(() => {
  // window.onkeydown = function (e) {
  //   var ck = e.keyCode ? e.keyCode : e.which;
  //   if ((e.ctrlKey && ck == 70) || (e.metaKey && ck == 70)) {
  //     document.getElementById("search").focus({ focusVisible: true });
  //   }
  // };
  document.body.addEventListener("keydown", function (e) {
    if (e.key == "f" && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      document.getElementById("search").focus({ focusVisible: true });
    }
  });
})();
