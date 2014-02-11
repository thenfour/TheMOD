

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
				title: 'The MOD homepage',
				//url: '#default',
				id: 'default'// used as an ID.
			}
		},
		{
			markdown: 'omg call me!',
			html: 'omg call me!',
			navItem:
			{
				title: 'The MOD contact us',
				//url: '#contact',
				id: 'contact'
			}
		}
	];


	this.songs = 
	[
		{
			UrlMP3: "mp3/Big Truffle in little China.mp3",
			UrlOGG: null,
			Title: "Big Truffle In Little China",// used as an ID.
			CanBeOpeningSong: true,
			//StartAt: 180,
			Annotation: []
		},
		{
			UrlMP3: "mp3/If Only It Were You.mp3",
			UrlOGG: null,
			Title: "If Only It Were You",
			CanBeOpeningSong: true,
			//StartAt: 180,
			Annotation: []
		},
		{
			UrlMP3: "mp3/Go Anywhere.mp3",
			UrlOGG: null,
			Title: "Go Anywhere",
			CanBeOpeningSong: false,
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
		if(page.id == id)
			return page;
	}
	return null;
};

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


