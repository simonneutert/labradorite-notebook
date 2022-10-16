ready(() => {
  if (document.getElementById("memos-edit")) {
    window.deleteAttachmentXHR = function (elem) {
      if (confirm("Are you sure you want to delete this item?")) {
        const filePath = elem?.dataset?.path;
        if (filePath) {
          fetch(`/api/v1/attachments${filePath}`, {
            method: "delete",
          })
            .then((data) => {
              elem.parentElement.remove();
            })
            .catch((e) => {
              alert("There was an Error, please check the logs!");
              console.error(e);
            });
        }
      }
    };
  }
});
