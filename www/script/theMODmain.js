


var lightBlue = "#600";
var darkBlue = "#440000";
var lightYellow = "#f2d700";
var darkYellow = "#633c00";
var darkGray = "#6a5f5e";

var lightPurple = "#5e506f";
var medPurple = '#40364b';
var darkPurple = "#221d28";
var darkDarkPurple = '#0c0c15';

var lightGray = "#d3d3d3";
var black = "#000";
var backgroundColor = darkPurple;

var demoEngine;
var contentEngine;
var audioEngine;


function reinitScrollContainers()
{
  $('#content').data('jsp').reinitialise();
}

function isCanvasSupported(){
	//return false;
  var elem = document.createElement('canvas');
  return !!(elem.getContext && elem.getContext('2d'));
}

function isAudioSupported() {
	var elem = document.createElement('audio');
	return !!(elem.pause);
}


function OnPrereqsLoaded()
{
	// http://stackoverflow.com/questions/3537615/jscrollpane-resize
	// or http://jscrollpane.kelvinluck.com/dynamic_height.html
  $(window).resize(reinitScrollContainers);

	var autoPlay = (window.location.href.indexOf("themod.be") != -1);

	contentEngine = new TheModCMS({
		storageEngine: new TheModFakeStorage(),
		languages: [
			{ lang: "en-US", anchorID: "taalEN" },
			{ lang: "nl-BE", anchorID: "taalNL" },
			{ lang: "fr-BE", anchorID: "taalFR" }
		]
	});
	
	if(isAudioSupported())
	{
		audioEngine = new TheModAudio(new TheModFakeStorage(), {
			playElementID: 'playButton',
			pauseElementID: 'pauseButton',
			previousSongElementID: 'previousSongButton',
			nextSongElementID: 'nextSongButton',
			songNameElementID: 'songName'
		}, autoPlay, 2000);
	}
	else
	{
		$('#mediaContainer')
			.css('display', 'none');
	}

	if(isCanvasSupported())
		demoEngine = new TheModEngine('canvasHere', new TheModRenderer(), 'container', audioEngine);
	else
		demoEngine = new TheModNonCanvasDemo('canvasHere');
}



$(document).ready(function() {
	OnPrereqsLoaded();
});

