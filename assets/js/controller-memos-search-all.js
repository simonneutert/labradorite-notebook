if (document.getElementById("memos-search-all")) {
  (() => {
    const searchUrl = "/api/v1/memos/search-all";
    const searchElem = document.getElementById("search");
    const statusElem = document.getElementById("search-status");
    const resultCountElem = document.getElementById("result-count");

    const highlightSearchText = (text) => {
      const search = searchElem.value;
      // Escape special regex characters
      const escapedSearch = search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      return text.replaceAll(
        new RegExp(`${escapedSearch}`, "gi"),
        `<span class="highlight-search-span">$&</span>`,
      );
    };

    // Generate unique ID for result anchors
    const generateResultId = (url) => {
      return 'result-' + url.replace(/[^a-zA-Z0-9]/g, '-');
    };

    const createSearchResultDomElement = function (url, title, hits) {
      const resultId = generateResultId(url);
      const container = document.createElement("div");
      container.className = "search-result-item mb-4 pb-3 border-bottom";
      container.id = resultId; // Add ID for anchor navigation
      
      const href = document.createElement("a");
      href.href = url;
      container.appendChild(href);

      const resultHeader = document.createElement("h4");
      resultHeader.appendChild(document.createTextNode(title));
      href.append(resultHeader);
      
      hits.forEach((hit) => {
        const highlighted = highlightSearchText(hit);
        const hitElement = document.createElement("p");
        hitElement.style.paddingLeft = "1em";
        hitElement.innerHTML = highlighted;
        href.appendChild(hitElement);
      });

      return container;
    };

    // Create navigation link for sidebar
    const createNavLink = function (url, title) {
      const resultId = generateResultId(url);
      const link = document.createElement("a");
      link.href = `#${resultId}`;
      link.className = "list-group-item list-group-item-action";
      link.textContent = title;
      link.style.fontSize = "0.9em";
      return link;
    };

    const buildResultCollectionDomElements = function (data) {
      return data.map((searchResult) => {
        const [url, title, hits] = searchResult;
        return createSearchResultDomElement(url, title, hits);
      });
    };

    const buildNavigationLinks = function (data) {
      return data.map((searchResult) => {
        const [url, title] = searchResult;
        return createNavLink(url, title);
      });
    };

    const updateResultCount = function (count) {
      if (statusElem) {
        statusElem.classList.remove("d-none");
      }
      if (resultCountElem) {
        resultCountElem.textContent = `Found ${count} result${count !== 1 ? 's' : ''}`;
      }
    };

    const postData = function (searchAbortController, elem) {
      const startTime = Date.now();
      
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
          // Ensure spinner shows for at least 500ms
          const elapsed = Date.now() - startTime;
          const remainingTime = Math.max(0, 500 - elapsed);
          
          setTimeout(() => {
            const listOfResultElements = buildResultCollectionDomElements(data);
            const listOfNavLinks = buildNavigationLinks(data);
            
            // Update main results
            document
              .getElementById("search-results")
              .replaceChildren(...listOfResultElements);
            
            // Update sidebar navigation (only on tablet and up)
            const navContainer = document.getElementById("search-nav");
            if (navContainer) {
              navContainer.replaceChildren(...listOfNavLinks);
            }
            
            updateResultCount(data.length);
          }, remainingTime);
        })
        .catch((error) => {
          if (error.name !== 'AbortError') {
            console.error('Search failed:', error);
          }
        });
    };

    const runSearch = function (elem) {
      searchAbortController = new AbortController();

      if (elem.value.length < 3) {
        document.getElementById("search-results").replaceChildren(...[]);
        const navContainer = document.getElementById("search-nav");
        if (navContainer) {
          navContainer.replaceChildren(...[]);
        }
        statusElem.classList.add("d-none");
        return;
      }

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
        runSearch(searchElem);
      }, 200);
    });

    // Optional: trigger search if URL has query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const initialQuery = urlParams.get('q');
    if (initialQuery) {
      searchElem.value = initialQuery;
      runSearch(searchElem);
    }
  })();
}
