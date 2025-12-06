if (document.getElementById("memos-search")) {
  (() => {
    const searchUrl = "/api/v1/memos/search";
    const searchElem = document.getElementById("search");

    const highlightSearchText = (text) => {
      const search = document.getElementById("search").value;
      return text.replaceAll(
        new RegExp(`${search}`, "gi"),
        `<span class="highlight-search-span">$&</span>`,
      );
    };

    const createSearchResultDomElement = function (url, title, hits) {
      const createSearchResultsElem = document.createElement("div");
      const href = document.createElement("a");
      createSearchResultsElem.appendChild(href);
      href.href = url;

      const resultHeader = document.createElement("h4");
      resultHeader.appendChild(document.createTextNode(title));
      href.append(resultHeader);
      hits.forEach((hit) => {
        const hhit = highlightSearchText(hit);
        console.log(hhit);
        const hitElement = document.createElement("p");
        hitElement.style.paddingLeft = "1em";
        hitElement.innerHTML = hhit;
        href.appendChild(hitElement);
      });
      return createSearchResultsElem;
    };

    const buildResultCollectionDomElements = function (data) {
      const coll = [];
      // Get preview limit from data attribute (customizable via ENV)
      const previewLimit = parseInt(document.getElementById('memos-index')?.dataset.previewLimit || 5, 10);
      const previewData = data.slice(0, previewLimit);
      previewData.map((searchResult) => {
        const [url, title, hits] = searchResult;
        const searchResultDomElement = createSearchResultDomElement(
          url,
          title,
          hits,
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
      // Redirect to search-all on Enter key
      if (e.key === 'Enter' && searchElem.value.length >= 3) {
        window.location.href = `/memos/search-all?q=${encodeURIComponent(searchElem.value)}`;
        return;
      }

      if (debounce) {
        clearTimeout(debounce);
        searchAbortController.abort();
      }
      debounce = setTimeout(() => {
        runSearch(searchElem, searchAbortController);
      }, 200);
    });

    runSearch(searchElem, searchAbortController);
  })();
}
