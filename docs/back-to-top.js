(function () {
  var LABEL = "Back to top";
  var button = document.getElementById("back-to-top");
  if (!button) return;

  button.textContent = LABEL;
  button.setAttribute("aria-label", LABEL);
  button.title = LABEL;

  function syncTop() {
    button.hidden = window.scrollY < 1;
  }

  window.addEventListener("scroll", syncTop, { passive: true });
  syncTop();
})();
