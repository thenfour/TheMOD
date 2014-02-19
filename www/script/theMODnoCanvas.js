

var TheModNonCanvasDemo = function(containerID)
{
	var containerEl = document.getElementById(containerID);
	$("#" + containerID).css("background-color", "#FFF");

	// create background.
	var backgroundEl = document.createElement("div");
	$(backgroundEl)
		.css("background-color", darkDarkPurple)
		.css("width", "100%")
		.css("height", "100%");
	containerEl.appendChild(backgroundEl);

	// title area
	var headerEl = document.createElement("div");
	$(headerEl)
		.css("background-color", lightPurple)
		.css("width", "100%")
		.css("height", "220px");
	backgroundEl.appendChild(headerEl);

	// create nav bar
	var navEl = document.createElement("div");
	$(navEl)
		.css("background-color", medPurple)
		.css("width", "200px")
		.css("height", "100%");
	backgroundEl.appendChild(navEl);

	// create footer
	var footerEl = document.createElement("div");
	$(footerEl)
		.css("background-color", medPurple)
		.css("position", "absolute")
		.css("width", "100%")
		.css("bottom", "0")
		.css("height", "40px");
	backgroundEl.appendChild(footerEl);

	// LOGO
	var logoEl = document.createElement("img");
	$(logoEl)
		.attr("src", "img/themod.png")
		.css("position", "absolute")
		.css("left", "0")
		.css("top", "0")
		;
	backgroundEl.appendChild(logoEl);

}
