

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

var scrollContainer;

function reinitScrollContainers()
{
    $.each(scrollContainer, function(){
            var api = $(this).data('jsp');
            api.reinitialise();
            //api.setBorder(null);
    });
}

function OnPrereqsLoaded()
{
  scrollContainer = $('#content');
  scrollContainer.jScrollPane();

	// http://stackoverflow.com/questions/3537615/jscrollpane-resize
	// or http://jscrollpane.kelvinluck.com/dynamic_height.html
  $(window).resize(reinitScrollContainers);

	contentEngine = new TheModCMS({
		storageEngine: new TheModFakeStorage(),
		languages: [
			{ lang: "en-US", anchorID: "taalEN" },
			{ lang: "nl-BE", anchorID: "taalNL" },
			{ lang: "fr-BE", anchorID: "taalFR" }
		]
	});

	var autoPlay = (window.location.href.indexOf("themod.be") != -1);

	audioEngine = new TheModAudio(new TheModFakeStorage(), {
		playElementID: 'playButton',
		pauseElementID: 'pauseButton',
		previousSongElementID: 'previousSongButton',
		nextSongElementID: 'nextSongButton',
		songNameElementID: 'songName'
	}, autoPlay, 2000);

	demoEngine = new TheModEngine('canvasHere', new TheModRenderer(), 'container', audioEngine);
}


require(
	[
		"script/jquery-1.11.0.min.js",
		"script/jquery.mousewheel.js",
		"script/jquery.jscrollpane.min.js",
		
		"script/mersenne-twister.js",
		"script/themodengine.js",
		"script/themodImage.js",
		"script/themodrenderer.js",
		"script/themodTween.js",
		"script/themodutil.js",
		"script/layerBackground.js",
		"script/layerTopCurtain.js",
		"script/layerLogo.js",
		"script/layerSun.js",
		"script/layerScroller.js",
		"script/layerNavBackground.js",
		"script/layerTopRightSquares.js",
		"script/theModFakeStorage.js",
		"script/theModCMS.js",
		"script/theModAudio.js"
	],
	OnPrereqsLoaded
	);
