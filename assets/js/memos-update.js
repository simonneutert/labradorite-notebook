if (document.getElementById("memos-edit")) {
  window.initMemosUpdate = (formId, url) => {
    document.getElementById(formId).addEventListener("submit", function (e) {
      e.preventDefault();

      let form = document.getElementById(formId);

      // Get all field data from the form
      // returns a FormData object
      let data = new FormData(form);

      // transform to query string
      fetch(url, {
        //signal: searchAbortController.signal,
        method: "POST",
        cache: "no-cache",
        // TODO: google why 'dont send headers 🥰 for form submission'
        body: data,
      })
        .then((response) => response.json())
        .then((data) => {
          console.log(data);
        });

      return false;
    });
  };
}
