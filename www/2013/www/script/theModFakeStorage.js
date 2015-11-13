
//////////////////////////////////////////////////////////////////////////
var TheModFakeStorage = function()
{
	this.pages =
	[
		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				id: 'default'// used as an ID.
			},
			isDefault: true,
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: About" },
				{ lang: "nl-BE", value: "The MOD: Over ons" },
				{ lang: "fr-BE", value: "The MOD: Sur nous" }
			]
		},
		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				id: 'musicians'
			},
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: Musicians" },
				{ lang: "nl-BE", value: "The MOD: Muzikanten" },
				{ lang: "fr-BE", value: "The MOD: Les Musiciens" }
			]		},

		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				id: 'contact'
			},
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: Contact" },
				{ lang: "nl-BE", value: "The MOD: Contact" },
				{ lang: "fr-BE", value: "The MOD: Contactez-Nous" }
			]
		},

		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				id: 'listen'
			},
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: Listen" },
				{ lang: "nl-BE", value: "The MOD: Audio" },
				{ lang: "fr-BE", value: "The MOD: Écoutez" }
			]
		}
	];
	//-------------------------------------------------------------------------------------


	this.songs = 
	[
		{
			UrlMP3: "mp3/Big Truffle In Little China.mp3",
			UrlOGG: "mp3/Big Truffle In Little China.ogg",
			Title: "Big Truffle In Little China",// used as an ID.
			CanBeOpeningSong: true,
			//StartAt: 180,
			Annotation: []
		},
		{
			UrlMP3: "mp3/If Only It Were You.mp3",
			UrlOGG: "mp3/If Only It Were You.ogg",
			Title: "If Only It Were You",
			CanBeOpeningSong: true,
			//StartAt: 180,
			Annotation: []
		},
		{
			UrlMP3: "mp3/Go Anywhere.mp3",
			UrlOGG: "mp3/Go Anywhere.ogg",
			Title: "Go Anywhere",
			CanBeOpeningSong: true,
			//StartAt: 180,
			Annotation: []
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
		if(page.navItem.id == id)
			return page;
	}
	return null;
};

TheModFakeStorage.prototype.GetDefaultPage = function()
{	
	for(var i = 0; i < this.pages.length; ++ i)
	{
		var page = this.pages[i];
		if(page.isDefault)
			return page;
	}
	return null;
}

TheModFakeStorage.prototype.GetLocalizedValue = function(o, lang)
{
	for(var i = 0; i < o.length; ++ i)
	{
		if(o[i].lang == lang)
			return o[i].value;
	}
	return "ERROR-TEXT-NOT-FOUND";
}

TheModFakeStorage.prototype.GetPageTitle = function(pageInfo, lang)
{
	return this.GetLocalizedValue(pageInfo.pageTitle, lang);
}


TheModFakeStorage.prototype.GetDefaultLanguage = function()
{
	return "en-US";
}

TheModFakeStorage.prototype.__getSongIndex = function(song)
{
	for(var i = 0; i < this.songs.length; ++ i)
	{
		var o = this.songs[i];
		if(o.Title == song.Title)
			return i;
	}
}

TheModFakeStorage.prototype.GetNextSong = function(song)
{
	var i = this.__getSongIndex(song);
	i = (i + 1) % this.songs.length;
	return this.songs[i];
}

TheModFakeStorage.prototype.GetPreviousSong = function(song)
{
	var i = this.__getSongIndex(song);
	i = i - 1;
	if(i < 0)
		i = this.songs.length - 1;
	return this.songs[i];
}

TheModFakeStorage.prototype.GetOpeningSong = function()
{
	var ioffset = Math.floor(Math.random() * this.songs.length);
	for(var i = 0; i < this.songs.length; ++ i)
	{
		var realIndex = (ioffset + i) % this.songs.length;
		var song = this.songs[realIndex];
		if(song.CanBeOpeningSong)
			return song;
	}
}


