var app = Elm.Main.init({
	node: document.getElementById("root"),
	flags: {
		height: window.innerHeight,
		width: window.innerWidth
	}
});

app.ports.newTab.subscribe(url => window.open(url, '_blank'));

app.ports.focusButton.subscribe(buttonId => {
    var button = document.getElementById(buttonId);
    if (button) {
        button.focus();
    }
});

app.ports.scrollElement.subscribe(function (scrollData) {
    var element = document.getElementById(scrollData.id);
    if (element) {
        element.scrollBy({ top: scrollData.delta, behavior: "smooth" });
    }
});

app.ports.scrollToElement.subscribe(function (elementId) {
    var element = document.getElementById(elementId);
    if (element) {
        element.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "nearest" });
    }
});
