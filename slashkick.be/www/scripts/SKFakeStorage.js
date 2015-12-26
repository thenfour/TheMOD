// holds a sort of site map. stuff here corresponds with data tags in html.
// holds info about pages, languages, available songs.
// also defines a sort of primitive prototype that could theoretically be used for real storage.

var SK = SK || {};
SK.__globalAudio = null;// assume only 1 running per page, for performance this avoids closures.


//////////////////////////////////////////////////////////////////////////
SK.FakeStorage = function()
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
				{ lang: "en-US", value: "/KICK: About" },
				{ lang: "nl-BE", value: "/KICK: Over ons" },
				{ lang: "fr-BE", value: "/KICK: Sur nous" }
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
				{ lang: "en-US", value: "Listen" },
				{ lang: "nl-BE", value: "Audio" },
				{ lang: "fr-BE", value: "Écoutez" }
			]
		}
	];
	//-------------------------------------------------------------------------------------


	this.songs = 
	[
		{
			UrlMP3: "audio/WhenNorthernLightsGoDownXRNS.mp3",
			UrlOGG: "audio/WhenNorthernLightsGoDownXRNS.ogg",
			Title: "When Northern Lights Go Down",// used as an ID.
			CanBeOpeningSong: true,
			//StartAt: 180,
			Annotation: []
		}
	];
};


// returns a NavItem object
SK.FakeStorage.prototype.GetAllPages = function()
{
	var ret = [];
	for(var i = 0; i < this.pages.length; ++ i)
	{
		ret.push(this.pages[i].navItem);
	}
	return ret;
};

SK.FakeStorage.prototype.GetPage = function(id)
{
	for(var i = 0; i < this.pages.length; ++ i)
	{
		var page = this.pages[i];
		if(page.navItem.id == id)
			return page;
	}
	return null;
};

SK.FakeStorage.prototype.GetDefaultPage = function()
{	
	for(var i = 0; i < this.pages.length; ++ i)
	{
		var page = this.pages[i];
		if(page.isDefault)
			return page;
	}
	return null;
}

SK.FakeStorage.prototype.GetLocalizedValue = function(o, lang)
{
	for(var i = 0; i < o.length; ++ i)
	{
		if(o[i].lang == lang)
			return o[i].value;
	}
	return "ERROR-TEXT-NOT-FOUND";
}

SK.FakeStorage.prototype.GetPageTitle = function(pageInfo, lang)
{
	return this.GetLocalizedValue(pageInfo.pageTitle, lang);
}


SK.FakeStorage.prototype.GetDefaultLanguage = function()
{
	return "en-US";
}

SK.FakeStorage.prototype.__getSongIndex = function(song)
{
	for(var i = 0; i < this.songs.length; ++ i)
	{
		var o = this.songs[i];
		if(o.Title == song.Title)
			return i;
	}
}

SK.FakeStorage.prototype.GetNextSong = function(song)
{
	var i = this.__getSongIndex(song);
	i = (i + 1) % this.songs.length;
	return this.songs[i];
}

SK.FakeStorage.prototype.GetPreviousSong = function(song)
{
	var i = this.__getSongIndex(song);
	i = i - 1;
	if(i < 0)
		i = this.songs.length - 1;
	return this.songs[i];
}

SK.FakeStorage.prototype.GetOpeningSong = function()
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


