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



//////////////////////////////////////////////////////////////////////////
var __globalCMS = null;// assume only 1 running per page, for performance this avoids closures.

var TheModCMS = function(storageEngine, navEnumProc, contentProc, mediaControls, autoPlay, initialAudioDelay)
{
	__globalCMS = this;

	this.storageEngine = storageEngine;

	// http://drumcoder.co.uk/blog/2011/feb/20/controlling-html5-audio-javascript/
	/*
		mediaControls = {
			playElementID: 'play',
			pauseElementID: 'pause',
		};
	*/
	// initialize audio stuff.....
	// play / pause events
	// auto play
	this.mediaControls = mediaControls;
	$('#' + mediaControls.playElementID).click(function() { __globalCMS.Play(); });
	$('#' + mediaControls.pauseElementID).click(function() { __globalCMS.Pause(); });
	$('#' + mediaControls.previousSongElementID).click(function() { __globalCMS.PreviousSong(); });
	$('#' + mediaControls.nextSongElementID).click(function() { __globalCMS.NextSong(); });

	this.audioElement = document.createElement('audio');
	$(this.audioElement).on("ended", function() { __globalCMS.NextSong();});
	$(this.audioElement).on("loadedmetadata", function() { __globalCMS.OnPlay(); });

	// start out in a paused state always
	$('#' + this.mediaControls.playElementID).css('display', 'inline-block');
	$('#' + this.mediaControls.pauseElementID).css('display', 'none');

	this.currentSong = this.storageEngine.GetOpeningSong();
	this.CueAudio();

	setTimeout(function() {
		if(autoPlay)
			__globalCMS.Play();
		else
			__globalCMS.Pause();
	},
	initialAudioDelay);

	// fill nav

	// figure out which page we're currently on.
	
	// set title
	
	// fill content area
};

TheModCMS.prototype.OnPlay = function()
{
	if(this.currentSong.StartAt)
	{
		this.audioElement.currentTime = this.currentSong.StartAt;
	}
}

TheModCMS.prototype.CueAudio = function()
{
	if(!this.currentSong)
		return;
	if(!this.audioElement)
		return;
	
	$("#" + this.mediaControls.songNameElementID).text(this.currentSong.Title);

	this.audioElement.pause();
	this.audioElement.innerHTML = '';
	var source = document.createElement('source');
	if (this.audioElement.canPlayType('audio/mpeg'))
	{
		source.type = 'audio/mpeg';
		source.src = this.currentSong.UrlMP3;
	}
	else
	{
		source.type = 'audio/ogg';
		source.src = this.currentSong.UrlOGG;
	}
	this.audioElement.appendChild(source);
}

TheModCMS.prototype.Play = function()
{
	if(!this.audioElement)
		return;
	this.audioElement.play();
	$('#' + this.mediaControls.playElementID).css('display', 'none');
	$('#' + this.mediaControls.pauseElementID).css('display', 'inline-block');
}

TheModCMS.prototype.Pause = function()
{
	if(!this.audioElement)
		return;
	this.audioElement.pause();
	$('#' + this.mediaControls.playElementID).css('display', 'inline-block');
	$('#' + this.mediaControls.pauseElementID).css('display', 'none');
}

TheModCMS.prototype.PreviousSong = function()
{
	if(!this.audioElement)
		return;
	this.currentSong = this.storageEngine.GetPreviousSong(this.currentSong);
	this.CueAudio();
	this.Play();
}

TheModCMS.prototype.NextSong = function()
{
	if(!this.audioElement)
		return;
	this.currentSong = this.storageEngine.GetNextSong(this.currentSong);
	this.CueAudio();
	this.Play();
}


TheModCMS.prototype.getCurrentSongPosition = function()
{
	if(!this.audioElement)
		return 0;
	return this.audioElement.currentTime;
}

TheModCMS.prototype.__onNav = function(element)
{
	// user is navigating to some other page.
}









