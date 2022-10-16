if (document.getElementsByClassName("enable-tagin").length) {
  const options = {
    separator: ",", // default: ','
    duplicate: false, // default: false
    enter: true, // default: false
    transform: "input => input.toLowerCase()", // default: input => input
    placeholder: "Add a tag...", // default: ''
  };
  const tagin = new Tagin(document.querySelector(".tagin"), options);
}
