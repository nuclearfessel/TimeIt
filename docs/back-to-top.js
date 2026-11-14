(function () {
  var LABEL = "Back to top";
  var SHOW_AFTER = 120;
  var button = document.getElementById("back-to-top");
  if (!button) return;

  button.textContent = LABEL;
  button.setAttribute("aria-label", LABEL);
  button.title = LABEL;

  function scrollTop() {
    return window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
  }

  function syncTop() {
    if (scrollTop() >= SHOW_AFTER) {
      button.hidden = false;
      button.classList.add("is-visible");
    } else {
      button.hidden = true;
      button.classList.remove("is-visible");
    }
  }

  window.addEventListener("scroll", syncTop, { passive: true });
  window.addEventListener("resize", syncTop, { passive: true });
  syncTop();
})();
