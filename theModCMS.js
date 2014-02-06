
//////////////////////////////////////////////////////////////////////////
var TheModFakeStorage = function()
{
	this.pages =
	[
		{
			markdown: 'hi there',
			html: 'hi there',
			navItem:
			{
				id: 'default',
				title: 'The MOD homepage',
				url: '#default',
				anchor: 'default'
			}
		},
		{
			markdown: 'omg call me!',
			html: 'omg call me!',
			navItem:
			{
				id: 'contact',
				title: 'The MOD contact us',
				url: '#contact',
				anchor: 'contact'
			}
		}
	];
};

// returns a NavItem object
TheModFakeStorage.prototype.GetAllPages = function()
{
	var ret = [];
	for(var i = 0; i < this.pages.length; ++ i)
	{
		ret.push(this.pages[i].navItem);
	}
	return ret;
};

TheModFakeStorage.prototype.GetPage = function(id)
{
	for(var i = 0; i < this.pages.length; ++ i)
	{
		var page = this.pages[i];
		if(page.id == id)
			return page;
	}
	return null;
};


//////////////////////////////////////////////////////////////////////////
var TheModCMS = function(storageEngine, navEnumProc, contentProc)
{
	this.storageEngine = storageEngine;

	// fill nav

	// figure out which page we're currently on.
	
	// set title
	
	// fill content area
};

TheModCMS.prototype.__onNav = function(element)
{
	// user is navigating to some other page.
}









