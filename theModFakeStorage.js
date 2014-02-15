/*

scene jazz music


musicians:
carl corcoran
angelo


*/

//////////////////////////////////////////////////////////////////////////
var TheModFakeStorage = function()
{
	this.pages =
	[
		{
			html: "<p>The MOD is a jazz fusion quintet performing arrangements of underground "
			+ "electro jazz/funk. We collaborate with electro jazz artists around the world to "
			+ "add the human element to the music that deserves it the most. The result is a "
			+ "blissful combination of catchy melodies, danceable beats, skewed surprises, and"
			+ " ground-shaking grooves.</p>"
			+ "<p>Electro-jazz artists since the 90's have been composing ground-breaking music"
			+ ", hidden mostly in the demoscene, a subculture associated mainly with computer "
			+ "hacking and digital graffiti. The MOD has formed a collaboration with the best "
			+ "of these artists with the goal of adding a sense of spontaneity, improvisation, "
			+ "and a live connection with an audience. The MOD satisfies this potential through "
			+ "an all-star cast of musicians: Angelo Gregorio on saxophone, Damiano La Rocca on "
			+ "guitar, Carl Corcoran on keyboards, Iënad Friedman on electric bass, "
			+ "Wilfried Manzanza on drums."

			,
			isDefault: true,
			pageTitle: 'The MOD: About',
			navItem:
			{
				title: 'About The MOD',
				id: 'default'// used as an ID.
			}
		},
		{
			html: 'carl, angelo, damiano, ienad, wilfried',
			pageTitle: 'The MOD: Musicians',
			navItem:
			{
				title: 'Musicians',
				id: 'musicians'
			}
		},
		{
			html: 'Go ahead and contact us. ...',
			pageTitle: 'The MOD: Contact',
			navItem:
			{
				title: 'Contact Us',
				id: 'contact'
			}
		}
	];


	this.songs = 
	[
		{
			UrlMP3: "mp3/Big Truffle in Little China.mp3",
			UrlOGG: "mp3/Big Truffle in Little China.ogg",
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


