
// to use this CMS, you need a data storage class.
// I'm using SKFakeStorage.js.

// to initialize it on your page, do something like this:
	// this.storageEngine = new SK.FakeStorage();
	// this.cms = new SK.CMS({
	// 	storageEngine: this.storageEngine,
	// 	languages: [
	// 		{ lang: "en-US", anchorID: "taalEN" },
	// 		{ lang: "nl-BE", anchorID: "taalNL" },
	// 		{ lang: "fr-BE", anchorID: "taalFR" }
	// 	]
	// });


// specify language changing options like this:

// <div id="taalOpties">
// <a class="taalOptie" data-navlinkforlanguage="en-US">EN</a> |
// <a class="taalOptie" data-navlinkforlanguage="fr-BE">FR</a> |
// <a class="taalOptie" data-navlinkforlanguage="nl-BE">NL</a>
// </div>


// and links to pages like this:

// 				<a class="navLink" data-lang="en-US" data-navlinkforpage="default">About The MOD</a>

// and content for pages like this:

// 		<div class="content" data-contentforpage="default" data-contentforlanguage="en-US" lang="en-US">...</div>



var SK = SK || {};
SK.__globalCMS = null;// assume only 1 running per page, for performance this avoids closures.


SK.CMS = function(config)
{
	SK.__globalCMS = this;
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

		var hash = SK.__globalCMS.MakeHash(pageID, lang);

		$(this)
			.attr("href", hash)
			.click(function(e) {
				//e.preventDefault();
				SK.__globalCMS.__navigateToHash($(this).attr('href'));
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
				SK.__globalCMS.__navigateToHash($(this).attr('href'));
		});
	});

	// figure out which page we're currently on. the following is required by chrome for some reason.
	setTimeout(function() {
		var hash = window.location.hash.substring(1);
		SK.__globalCMS.__navigateToHash(hash);
	}, 1);
};

SK.CMS.prototype.MakeHash = function(pageID, langID)
{
	return "#" + langID + "_" + pageID;
}


SK.CMS.prototype.ParseHash = function(hash)
{
	if(hash.indexOf("#") == 0)
		hash = hash.substring(1);

	// langID_pageID
	var parts = hash.split("_");
	return { lang: parts[0], pageID: parts[1] };
}


SK.CMS.prototype.__navigateToHash = function(hash)
{
	var hashInfo = this.ParseHash(hash);
	this.currentPage = this.config.storageEngine.GetPage(hashInfo.pageID);
	this.currentLanguage = hashInfo.lang;
	this.__navigateExec();
}


SK.CMS.prototype.__navigateExec = function()
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

		if(lang == SK.__globalCMS.currentLanguage)
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
			.attr("href", SK.__globalCMS.MakeHash(SK.__globalCMS.currentPage.navItem.id, lang))

	});

	// reveal the right content. to do this, first hide all content
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
		var match = (pageID == SK.__globalCMS.currentPage.navItem.id) && (lang.indexOf(SK.__globalCMS.currentLanguage) != -1);
		if(match)
		{
			$(this).show();
		}
	});

  //reinitScrollContainers();

	window.document.title = this.config.storageEngine.GetPageTitle(this.currentPage, this.currentLanguage);
}



