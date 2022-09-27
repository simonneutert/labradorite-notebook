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

const search = document.getElementById("search");
let debounce = undefined;
search.addEventListener("keyup", (e) => {
  if (debounce) {
    clearTimeout(debounce);
  }
  debounce = setTimeout(() => {
    fetch("http://localhost:9292/memos/search", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: JSON.stringify({ search: search.value }),
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
  }, 300);
});
