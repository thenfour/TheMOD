

//////////////////////////////////////////////////////////////////////////
var __globalCMS = null;// assume only 1 running per page, for performance this avoids closures.

var TheModCMS = function(config)
{
	__globalCMS = this;
	this.config = config;

	// fill nav
	$("a").each(function(i, o) {
		var pageID = $(this).data('navlinkforpage');
		if(!pageID)
			return;
		var lang = $(this).data("lang");
		if(!lang)
			return;

		// add a lang attribute for the heck of it; browsers like it.
		if(!$(this).attr("lang"))
		{
			$(this).attr("lang", lang);
		}

		var hash = __globalCMS.MakeHash(pageID, lang);

		$(this)
			.attr("href", hash)
			.click(function(e) {
				//e.preventDefault();
				__globalCMS.__navigateToHash($(this).attr('href'));
			});
	});

	// configure language selection.
	$("a").each(function(i, o) {
		var lang = $(this).data('navlinkforlanguage');
		if(!lang)
			return;

		// add a lang attribute for the heck of it; browsers like it.
		if(!$(this).attr("lang"))
		{
			$(this).attr("lang", lang);
		}

		$(this).click(function (e) {
				//e.preventDefault();
				__globalCMS.__navigateToHash($(this).attr('href'));
		});
	});

	// figure out which page we're currently on. the following is required by chrome for some reason.
	setTimeout(function() {
		var hash = window.location.hash.substring(1);
		__globalCMS.__navigateToHash(hash);
	}, 1);
};

TheModCMS.prototype.MakeHash = function(pageID, langID)
{
	return "#" + langID + "_" + pageID;
}


TheModCMS.prototype.ParseHash = function(hash)
{
	if(hash.indexOf("#") == 0)
		hash = hash.substring(1);

	// langID_pageID
	var parts = hash.split("_");
	return { lang: parts[0], pageID: parts[1] };
}


TheModCMS.prototype.__navigateToHash = function(hash)
{
	var hashInfo = this.ParseHash(hash);
	this.currentPage = this.config.storageEngine.GetPage(hashInfo.pageID);
	this.currentLanguage = hashInfo.lang;
	this.__navigateExec();
}


TheModCMS.prototype.__navigateExec = function()
{
	if(!this.currentPage)
		this.currentPage = this.config.storageEngine.GetDefaultPage();
	if(!this.currentLanguage)
		this.currentLanguage = this.config.storageEngine.GetDefaultLanguage();

	// fix nav-to-page links
	$("a").each(function(i, o) {
		var pageID = $(this).data('navlinkforpage');
		if(!pageID)
			return;
		var lang = $(this).data("lang");
		if(!lang)
			return;

		// no need to set href; each page/lang combo has a unique element.

		if(lang == __globalCMS.currentLanguage)
		{
			$(this).show();
		}
		else
			$(this).hide();
	});

	// fix nav-to-language links
	$("a").each(function(i, o) {
		var lang = $(this).data('navlinkforlanguage');
		if(!lang)
			return;

		$(this)
			.attr("href", __globalCMS.MakeHash(__globalCMS.currentPage.navItem.id, lang))

	});

	// reveal the right content. to do this, first hide all content, then remove jscroller stuff, then show, then add jscroll.
	// this is the safest way to ensure sizes and things are done properly.
	$("div").each(function(i, o) {
		var lang = $(this).data("contentforlanguage");
		if(!lang)
			return;
		var pageID = $(this).data("contentforpage");
		if(!pageID)
			return;

		//if($(this).data('jsp'))
		//	$(this).data('jsp').destroy();// remove the jquery scroller thingy.

		$(this).hide();// this is a content div; hide it.
	});

	$("div").each(function(i, o) {
		var lang = $(this).data("contentforlanguage");
		if(!lang)
			return;
		var pageID = $(this).data("contentforpage");
		if(!pageID)
			return;
		var match = (pageID == __globalCMS.currentPage.navItem.id) && (lang.indexOf(__globalCMS.currentLanguage) != -1);
		if(match)
		{
			$(this).show();
		  //$(this).jScrollPane();
			// i don't know why but it will set width:0 and margin-left:some_huge_value *sometimes*.
			// this hacks it away.
		  //$('.jspPane').css("margin-left", "0");
		  //$('.jspPane').css("width", "");

		}
	});

  reinitScrollContainers();

	window.document.title = this.config.storageEngine.GetPageTitle(this.currentPage, this.currentLanguage);
}



