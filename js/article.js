const popup = document.getElementById('imagePopup');
const popupImg = document.getElementById('popupImg');

document.querySelectorAll('main img:not(.popup-image)').forEach(img => {
    img.addEventListener('click', function() {
        popup.style.display = 'block';
        popupImg.src = this.src;
        document.body.style.overflow = 'hidden';
    });
});


popup.addEventListener('click', function(e) {
    if (e.target === popup) {
        popup.style.display = 'none';
        document.body.style.overflow = '';
    }
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && popup.style.display === 'block') {
        popup.style.display = 'none';
        document.body.style.overflow = '';
    }
});

let pressedKeys = [];

document.addEventListener("keydown", (event) => {
  const scrollAmount = 300; // Pixels to scroll per key press

  // Detect 'j' for scrolling down
  if (event.key === "j") {
    window.scrollBy({ top: scrollAmount, behavior: "smooth" });
  }

  // Detect 'k' for scrolling up
  else if (event.key === "k") {
    window.scrollBy({ top: -scrollAmount, behavior: "smooth" });
  }

  // Track keys pressed for 'gh' shortcut
  pressedKeys.push(event.key);

  // Check for 'gh' sequence
  if (pressedKeys.join("").endsWith("gh")) {
    window.location.href = "/index.html";
  }

  // Check for 'gb' sequence to go back in history
  if (pressedKeys.join("").endsWith("gb")) {
    window.history.back();
  }

  // Limit the size of pressedKeys to avoid excessive memory usage
  if (pressedKeys.length > 2) {
    pressedKeys.shift();
  }
});
