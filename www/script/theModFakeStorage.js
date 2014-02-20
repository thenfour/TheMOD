
//////////////////////////////////////////////////////////////////////////
var TheModFakeStorage = function()
{
	this.pages =
	[
		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				title:
				[
					{ lang: "en-US", value: "About The MOD" },
					{ lang: "nl-BE", value: "Over The MOD" },
					{ lang: "fr-BE", value: "Sur The MOD" }
				],
				id: 'default'// used as an ID.
			},
			isDefault: true,
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: About" },
				{ lang: "nl-BE", value: "The MOD: Over ons" },
				{ lang: "fr-BE", value: "The MOD: Sur nous" }
			],
			content:
			[
				{ lang: "en-US", value: "<p>The MOD is a jazz fusion quintet performing arrangements of underground "
					+ "electro jazz/funk. We collaborate with electro jazz artists around the world to "
					+ "add the human element to the music that deserves it the most. The result is a "
					+ "blissful combination of catchy melodies, danceable beats, asymmetric surprises, and"
					+ " ground-shaking grooves.</p><img style=\"width:527px;height:351px\" src=\"img/themodphoto.jpg\" />" },// it's important to specify dimensions so the scroll container can init properly before the image has even loaded.

				{ lang: "nl-BE", value: "<p>The MOD is a jazz fusion quintet performing arrangements of underground "
					+ "electro jazz/funk. We collaborate with electro jazz artists around the world to "
					+ "add the human element to the music that deserves it the most. The result is a "
					+ "blissful combination of catchy melodies, danceable beats, asymmetric surprises, and"
					+ " ground-shaking grooves.</p><img style=\"width:527px;height:351px\" src=\"img/themodphoto.jpg\" />" },

				{ lang: "fr-BE", value: "<p>The MOD is a jazz fusion quintet performing arrangements of underground "
					+ "electro jazz/funk. We collaborate with electro jazz artists around the world to "
					+ "add the human element to the music that deserves it the most. The result is a "
					+ "blissful combination of catchy melodies, danceable beats, asymmetric surprises, and"
					+ " ground-shaking grooves.</p><img style=\"width:527px;height:351px\" src=\"img/themodphoto.jpg\" />" }
			]
		},
		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				title:
				[
					{ lang: "en-US", value: "Musicians" },
					{ lang: "nl-BE", value: "Muzikanten" },
					{ lang: "fr-BE", value: "Les Musiciens" }
				],
				id: 'musicians'
			},
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: Musicians" },
				{ lang: "nl-BE", value: "The MOD: Muzikanten" },
				{ lang: "fr-BE", value: "The MOD: Les Musiciens" }
			],
			content: 
			[
				{ lang: "en-US", value:
					"<p><h2>Carl Corcoran, keyboard</h2></p>"
					+ "<p><h2>Angelo Gregorio, saxophone</h2></p>"
					+ "<p><h2>Damiano La Rocca, guitar</h2></p>"
					+ "<p><h2>Iënad Friedman, bass</h2></p>"
					+ "<p><h2>Wilfried Manzanza, drums</h2></p>"
				},
				{ lang: "nl-BE", value:
					"<p><h2>Carl Corcoran, keyboard</h2></p>"
					+ "<p><h2>Angelo Gregorio, saxophone</h2></p>"
					+ "<p><h2>Damiano La Rocca, guitar</h2></p>"
					+ "<p><h2>Iënad Friedman, bass</h2></p>"
					+ "<p><h2>Wilfried Manzanza, drums</h2></p>"
				},

				{ lang: "fr-BE", value:
					"<p><h2>Carl Corcoran, keyboard</h2></p>"
					+ "<p><h2>Angelo Gregorio, saxophone</h2></p>"
					+ "<p><h2>Damiano La Rocca, guitar</h2></p>"
					+ "<p><h2>Iënad Friedman, bass</h2></p>"
					+ "<p><h2>Wilfried Manzanza, drums</h2></p>"
				}
			]
		},

		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				title:
				[
					{ lang: "en-US", value: "Contact Us" },
					{ lang: "nl-BE", value: "Contact" },
					{ lang: "fr-BE", value: "Contactez-Nous" }
				],
				id: 'contact'
			},
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: Contact" },
				{ lang: "nl-BE", value: "The MOD: Contact" },
				{ lang: "fr-BE", value: "The MOD: Contactez-Nous" }
			],
			content: 
			[
				{ lang: "en-US", value: "+32 (0)499 315 763<br /><a href=\"contact@themod.be\">contact@themod.be</a>" },
				{ lang: "nl-BE", value: "+32 (0)499 315 763<br /><a href=\"contact@themod.be\">contact@themod.be</a>" },
				{ lang: "fr-BE", value: "+32 (0)499 315 763<br /><a href=\"contact@themod.be\">contact@themod.be</a>" }
			]
		},

		//-------------------------------------------------------------------------------------
		{
			navItem:
			{
				title:
				[
					{ lang: "en-US", value: "Listen" },
					{ lang: "nl-BE", value: "Audio" },
					{ lang: "fr-BE", value: "Écoutez" }
				],
				id: 'listen'
			},
			pageTitle:
			[
				{ lang: "en-US", value: "The MOD: Listen" },
				{ lang: "nl-BE", value: "The MOD: Audio" },
				{ lang: "fr-BE", value: "The MOD: Écoutez" }
			],
			content: 
			[
				{ lang: "en-US", value: 
					"<p>Visit us on soundcloud: <a href=\"https://soundcloud.com/the-mod\">https://soundcloud.com/the-mod</a></p>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723587&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723539&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723141&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
				},

				{ lang: "nl-BE", value:
					"<p>Luister ons op SoundCloud: <a href=\"https://soundcloud.com/the-mod\">https://soundcloud.com/the-mod</a></p>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723587&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723539&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723141&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
				},

				{ lang: "fr-BE", value:
					"<p>Écoutez-nous sur SoundCloud: <a href=\"https://soundcloud.com/the-mod\">https://soundcloud.com/the-mod</a></p>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723587&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723539&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
					+ "<iframe width=\"550\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"https:\/\/w.soundcloud.com\/player\/?url=https%3A\/\/api.soundcloud.com\/tracks\/135723141&amp;color=5e506f&amp;auto_play=false&amp;hide_related=true&amp;show_artwork=false\"><\/iframe>"
				}
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

TheModFakeStorage.prototype.GetPageContentHTML = function(pageInfo, lang)
{
	return this.GetLocalizedValue(pageInfo.content, lang);
}

TheModFakeStorage.prototype.GetPageNavTitle = function(navItem, lang)
{
	return this.GetLocalizedValue(navItem.title, lang);
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


