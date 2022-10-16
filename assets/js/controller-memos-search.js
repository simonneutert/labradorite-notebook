if (document.getElementById("memos-search")) {
  (() => {
    const searchUrl = "/api/v1/memos/search";
    const searchElem = document.getElementById("search");

    const createSearchResultDomElement = function (url, title, hits) {
      const createSearchResultsElem = document.createElement("div");
      const href = document.createElement("a");
      createSearchResultsElem.appendChild(href);
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
      return createSearchResultsElem;
    };

    const buildResultCollectionDomElements = function (data) {
      const coll = [];
      data.map((searchResult) => {
        const [url, title, hits] = searchResult;
        const searchResultDomElement = createSearchResultDomElement(
          url,
          title,
          hits
        );
        coll.push(searchResultDomElement);
      });
      return coll;
    };

    const postData = function (searchAbortController, elem) {
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
          const listOfResultElements = buildResultCollectionDomElements(data);
          document
            .getElementById("search-results")
            .replaceChildren(...listOfResultElements);
        });
    };

    const runSearch = function (elem, searchAbortController) {
      searchAbortController = new AbortController();

      if (elem.value.length < 3) {
        // clear content
        document.getElementById("search-results").replaceChildren(...[]);
        return;
      }

      // fetch data replace content
      postData(searchAbortController, elem);
    };

    let debounce = undefined;
    let searchAbortController = new AbortController();

    searchElem.addEventListener("keyup", (e) => {
      if (debounce) {
        clearTimeout(debounce);
        searchAbortController.abort();
      }
      debounce = setTimeout(() => {
        runSearch(search, searchAbortController);
      }, 200);
    });

    runSearch(searchElem, searchAbortController);
  })();
}
