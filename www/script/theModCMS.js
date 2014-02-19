

//////////////////////////////////////////////////////////////////////////
var __globalCMS = null;// assume only 1 running per page, for performance this avoids closures.

var TheModCMS = function(config)
{
	__globalCMS = this;
	this.config = config;

	// fill nav
	var allPages = this.config.storageEngine.GetAllPages();
	for(var i = 0; i < allPages.length; ++ i)
	{
		var navItem = allPages[i];
		var newLink = document.createElement('a');
		$(newLink)
			.attr("id", navItem.id)
			.addClass('navLink')
			.click(function(){
				__globalCMS.__navigateToHash($(this).attr('href'));
			});
			;
		document.getElementById('navLinks').appendChild(newLink);
	}

	// configure language selection.
	var allLanguages = this.config.languages;
	for(var i = 0; i < allLanguages.length; ++ i)
	{
		var thisLangInfo = allLanguages[i];
		var langID = thisLangInfo.lang;
		$("#" + thisLangInfo.anchorID)
			.click(function(){
				__globalCMS.__navigateToHash($(this).attr('href'));
			})
			;
	}

	// figure out which page we're currently on.
	var hash = window.location.hash.substring(1);
	this.__navigateToHash(hash);
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

	// fix nav links (lang could have changed)
	var allPages = this.config.storageEngine.GetAllPages();
	for(var i = 0; i < allPages.length; ++ i)
	{
		var navItem = allPages[i];
		$("#" + navItem.id)
			.text(this.config.storageEngine.GetPageNavTitle(navItem, this.currentLanguage))
			.attr("href", this.MakeHash(navItem.id, this.currentLanguage))
	}

	// configure language selection links (page could have changed)
	var allLanguages = this.config.languages;
	for(var i = 0; i < allLanguages.length; ++ i)
	{
		var thisLangInfo = allLanguages[i];
		$("#" + thisLangInfo.anchorID)
			.attr("href", this.MakeHash(this.currentPage.navItem.id, thisLangInfo.lang))
			;
	}

	$('#contentPlaceholder').html(this.config.storageEngine.GetPageContentHTML(this.currentPage, this.currentLanguage));

  reinitScrollContainers();

	window.document.title = this.config.storageEngine.GetPageTitle(this.currentPage, this.currentLanguage);
}



