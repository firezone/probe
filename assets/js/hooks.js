let DarkModeToggle = {
  mounted() {
    var themeToggleDarkIcon = document.getElementById("theme-toggle-dark-icon");
    var themeToggleLightIcon = document.getElementById(
      "theme-toggle-light-icon"
    );

    // Change the icons inside the button based on previous settings
    if (
      localStorage.getItem("color-theme") === "dark" ||
      (!("color-theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      themeToggleLightIcon.classList.remove("hidden");
    } else {
      themeToggleDarkIcon.classList.remove("hidden");
    }

    var themeToggleBtn = document.getElementById("theme-toggle");

    // Add event listener to the button
    themeToggleBtn.addEventListener("click", function () {
      // toggle icons inside button
      themeToggleDarkIcon.classList.toggle("hidden");
      themeToggleLightIcon.classList.toggle("hidden");

      // if set via local storage previously
      if (localStorage.getItem("color-theme")) {
        if (localStorage.getItem("color-theme") === "light") {
          document.documentElement.classList.add("dark");
          localStorage.setItem("color-theme", "dark");
        } else {
          document.documentElement.classList.remove("dark");
          localStorage.setItem("color-theme", "light");
        }

        // if NOT set via local storage previously
      } else {
        if (document.documentElement.classList.contains("dark")) {
          document.documentElement.classList.remove("dark");
          localStorage.setItem("color-theme", "light");
        } else {
          document.documentElement.classList.add("dark");
          localStorage.setItem("color-theme", "dark");
        }
      }
    });
  },
  // Update the button again when view is updated
  updated() {
    var themeToggleDarkIcon = document.getElementById("theme-toggle-dark-icon");
    var themeToggleLightIcon = document.getElementById(
      "theme-toggle-light-icon"
    );

    // Change the icons inside the button based on previous settings
    if (
      localStorage.getItem("color-theme") === "dark" ||
      (!("color-theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      themeToggleLightIcon.classList.remove("hidden");
    } else {
      themeToggleDarkIcon.classList.remove("hidden");
    }
  },

  destroyed() {
    var themeToggleBtn = document.getElementById("theme-toggle");
    themeToggleBtn.removeEventListener("click", function () {});
  },
};

let InitFlowbite = {
  updated() {
    window.initFlowbite();
  },
};

let ResetCopyIcon = {
  mounted() {
    window.addEventListener("delayed-show", function (event) {
      setTimeout(() => {
        event.target.classList.remove("hidden");
      }, 2000);
    });
    window.addEventListener("delayed-hide", function (event) {
      setTimeout(() => {
        event.target.classList.add("hidden");
      }, 2000);
    });
  },
  updated() {
    // Reset button state on update. Otherwise will replace it with the copied icon.
    const defaultIcon = document.querySelector("[id*='default-icon-']");
    const successIcon = document.querySelector("[id*='success-icon-']");
    defaultIcon.classList.remove("hidden");
    successIcon.classList.add("hidden");
  },
  destroyed() {
    window.removeEventListener("delayed-show", function () {});
    window.removeEventListener("delayed-hide", function () {});
  },
};

export { DarkModeToggle, ResetCopyIcon, InitFlowbite };
