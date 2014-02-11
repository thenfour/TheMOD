
//////////////////////////////////////////////////////////////////////////
var __globalAudio = null;// assume only 1 running per page, for performance this avoids closures.

var TheModAudio = function(storageEngine, mediaControls, autoPlay, initialAudioDelay)
{
	__globalAudio = this;

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
	$('#' + mediaControls.playElementID).click(function() { __globalAudio.Play(); });
	$('#' + mediaControls.pauseElementID).click(function() { __globalAudio.Pause(); });
	$('#' + mediaControls.previousSongElementID).click(function() { __globalAudio.PreviousSong(); });
	$('#' + mediaControls.nextSongElementID).click(function() { __globalAudio.NextSong(); });

	this.audioElement = document.createElement('audio');
	$(this.audioElement).on("ended", function() { __globalAudio.NextSong();});
	$(this.audioElement).on("loadedmetadata", function() { __globalAudio.OnPlay(); });

	// start out in a paused state always
	$('#' + this.mediaControls.playElementID).css('display', 'inline-block');
	$('#' + this.mediaControls.pauseElementID).css('display', 'none');

	this.currentSong = this.storageEngine.GetOpeningSong();
	this.CueAudio();

	setTimeout(function() {
		if(autoPlay)
			__globalAudio.Play();
		else
			__globalAudio.Pause();
	},
	initialAudioDelay);

};

TheModAudio.prototype.OnPlay = function()
{
	if(this.currentSong.StartAt)
	{
		this.audioElement.currentTime = this.currentSong.StartAt;
	}
}

TheModAudio.prototype.CueAudio = function()
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

TheModAudio.prototype.Play = function()
{
	if(!this.audioElement)
		return;
	this.audioElement.play();
	$('#' + this.mediaControls.playElementID).css('display', 'none');
	$('#' + this.mediaControls.pauseElementID).css('display', 'inline-block');
}

TheModAudio.prototype.Pause = function()
{
	if(!this.audioElement)
		return;
	this.audioElement.pause();
	$('#' + this.mediaControls.playElementID).css('display', 'inline-block');
	$('#' + this.mediaControls.pauseElementID).css('display', 'none');
}

TheModAudio.prototype.PreviousSong = function()
{
	if(!this.audioElement)
		return;
	this.currentSong = this.storageEngine.GetPreviousSong(this.currentSong);
	this.CueAudio();
	this.Play();
}

TheModAudio.prototype.NextSong = function()
{
	if(!this.audioElement)
		return;
	this.currentSong = this.storageEngine.GetNextSong(this.currentSong);
	this.CueAudio();
	this.Play();
}


TheModAudio.prototype.getCurrentSongPosition = function()
{
	if(!this.audioElement)
		return 0;
	return this.audioElement.currentTime;
}






