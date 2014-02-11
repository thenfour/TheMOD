// structs:
// * navitem
// * page
// * song


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
			Annotation: []
		},
		{
			UrlMP3: "mp3/If Only It Were You.mp3",
			UrlOGG: null,
			Title: "If Only It Were You",
			CanBeOpeningSong: true,
			Annotation: []
		},
		{
			UrlMP3: "mp3/Go Anywhere.mp3",
			UrlOGG: null,
			Title: "Go Anywhere",
			CanBeOpeningSong: false,
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

TheModFakeStorage.prototype.__getSongIndex = function(id)
{
	for(var i = 0; i < this.songs.length; ++ i)
	{
		var song = this.songs[i];
		if(song.title == id)
			return i;
	}
}

TheModFakeStorage.prototype.GetNextSong = function(id)
{
	var i = __getSongIndex(id);
	i = (i + 1) % this.songs.length;
	return this.songs[i];
}

TheModFakeStorage.prototype.GetPreviousSong = function(id)
{
	var i = __getSongIndex(id);
	i = i - 1;
	if(i < 0)
		i = this.songs.length - 1;
	return this.songs[i];
}

TheModFakeStorage.prototype.GetOpeningSong = function()
{
	for(var i = 0; i < this.songs.length; ++ i)
	{
		var song = this.songs[i];
		if(song.CanBeOpeningSong)
			return song;
	}
}


//////////////////////////////////////////////////////////////////////////
var TheModCMS = function(storageEngine, navEnumProc, contentProc, mediaControls)
{
	this.storageEngine = storageEngine;

	// http://drumcoder.co.uk/blog/2011/feb/20/controlling-html5-audio-javascript/
	/*
		mediaControls = {
			playElementID: 'play',
			pauseElementID: 'pause',
			volume slider
			mute button
			position slider ?
		};
	*/
	// initialize audio stuff.....
	// play / pause events
	// auto play
	this.audioElement = document.createElement('audio');
	var song = this.storageEngine.GetOpeningSong();
	var source = document.createElement('source');
	if (this.audioElement.canPlayType('audio/mpeg'))
	{
		source.type = 'audio/mpeg';
		source.src = song.UrlMP3;
	}
	else
	{
		source.type = 'audio/ogg';
		source.src = song.UrlOGG;
	}
	this.audioElement.appendChild(source);
	//this.audioElement.play();



	// fill nav

	// figure out which page we're currently on.
	
	// set title
	
	// fill content area
};

TheModCMS.prototype.__onNav = function(element)
{
	// user is navigating to some other page.
}









