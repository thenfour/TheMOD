
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
		var navLink = this.config.navProc(this, allPages[i]);
		// set up something? events?
		$(navLink).click(function(){
			var id = $(this).attr('href').split('#')[1];
			__globalCMS.__navigateTo(id);
		});
	}

	// figure out which page we're currently on.
	var hash = window.location.hash.substring(1);
	this.__navigateTo(hash);
};


TheModCMS.prototype.__navigateTo = function(id)
{
	if(!id)
		this.currentPage = this.config.storageEngine.GetDefaultPage();
	else
		this.currentPage = this.config.storageEngine.GetPage(id);

	this.config.contentProc(this, this.currentPage);
}

TheModCMS.prototype.GetHref = function(navItem)
{
	return "#" + navItem.id;
}




