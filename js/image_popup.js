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
