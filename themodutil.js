

// i thought this would be faster than sin(). it's not; javascript is slow maaan. maybe there's a way to combine all 4 factors into a big formula or something.
// this returns from 0 to PI.
function periodFn(x)
{
	return Math.abs((x % 4) - 2);
	// take saw wave from 0-4 (period 4 instead of 2pi)
	// shift down (now it's a saw from -2 to 2)
	// abs it, so it's a triangle from 0-2
}

// generates a deterministic, "random" envelope bound to time
var RandEnvelope = function(seed, cyclesPerSecond)
{
	var m = new MersenneTwister(seed);
	this.seed = m.random() * 0.004 * cyclesPerSecond;
	this.a = 1 - (m.random() * 0.11);
	this.b = 1 - (m.random() * 0.12);
	this.c = 1 - (m.random() * 0.13);
	//this.d = 1 - (m.random() * 0.14);
	//this.lastTimeMS = 0;//
};

var maxEnv = false;
var minEnv = false;

// given the time in MS, return a value from -1 to 1
// speed = 1 roughly means "1 cycle per second", but of course perturbed greatly via our functions
RandEnvelope.prototype.varianceFactor = function(timeMS)
{
	var x = 1000 + (this.seed * timeMS);
	var ret = periodFn(x / this.a) + periodFn(x * this.b) + periodFn(x * this.c)/* + periodFn(x / this.d)*/;// currently has range 0-8
	ret = (ret / 2.9) - 1;// it should normally be divided by the height at this point, 3, but dividing smaller means getting bigger numbers that will be clamped out.
	if(ret < -1) ret = -1;
	if(ret > 1) ret = 1;
	return ret;
	/*
	if(maxEnv === false || ret > maxEnv)
		maxEnv = ret;
	if(minEnv === false || ret < minEnv)
		minEnv = ret;
*/
};

// returns -1 to 1
RandEnvelope.prototype.height = function(timeMS)
{
	return this.varianceFactor(timeMS);
}

// return 0 to 1
RandEnvelope.prototype.factor = function(timeMS)
{
	return (this.varianceFactor(timeMS) + 1) / 2;
}

RandEnvelope.prototype.vary = function(timeMS, originalValue, variationAmt)
{
	return originalValue + (variationAmt * this.varianceFactor(timeMS));
};



var __cachedRandEnvelopes = [];
var __cachedRandEnvelopeCount = 0;

function CachedRandEnvelope(x, y, speed)
{
	if(!__cachedRandEnvelopes[x])
	{
		__cachedRandEnvelopes[x] = [];
	}
	if(!__cachedRandEnvelopes[x][y])
	{
		__cachedRandEnvelopes[x][y] = new RandEnvelope(__cachedRandEnvelopeCount, speed);
		__cachedRandEnvelopeCount ++;
	}
	return __cachedRandEnvelopes[x][y];
}



// Find the points where the two circles intersect.
function FindCircleCircleIntersections(cx0, cy0, radius0, cx1, cy1, radius1)
{
	// Find the distance between the centers.
	var dx = cx0 - cx1;
	var dy = cy0 - cy1;
	var dist = Math.sqrt(dx * dx + dy * dy);

	// See how many solutions there are.
	if (dist > radius0 + radius1) return [];// No solutions, the circles are too far apart.
	else if (dist < Math.abs(radius0 - radius1)) return [];// No solutions, one circle contains the other.
	else if ((dist == 0) && (radius0 == radius1)) return [];// No solutions, the circles coincide.

	// Find a and h.
	var a = (radius0 * radius0 - radius1 * radius1 + dist * dist) / (2 * dist);
	var h = Math.sqrt(radius0 * radius0 - a * a);

	// Find P2.
	var cx2 = cx0 + a * (cx1 - cx0) / dist;
	var cy2 = cy0 + a * (cy1 - cy0) / dist;

	// Get the points P3.
	var intersection1 = {
		x: cx2 + h * (cy1 - cy0) / dist, 
		y: cy2 - h * (cx1 - cx0) / dist
	};

	var intersection2 = {
		x: cx2 - h * (cy1 - cy0) / dist,
		y: cy2 + h * (cx1 - cx0) / dist
	};

	return [intersection1, intersection2];
}

function CircleCircleIntersectionLower(p0, radius0, p1, radius1)
{
	var i = FindCircleCircleIntersections(p0.x, p0.y, radius0, p1.x, p1.y, radius1);
	if(i.length == 0)
		return p0;// just forget about it, return a valid value.
	if(i[0].y < i[1].y)
		return i[1];
	return i[0];
}
/*
function lineDistance( point1, point2 )
{
  var xs = 0;
  var ys = 0;
 
  xs = point2.x - point1.x;
  xs = xs * xs;
 
  ys = point2.y - point1.y;
  ys = ys * ys;
 
  return Math.sqrt( xs + ys );
}
*/
function angleBetweenPointsOnCircle(p1, p2, r)
{
	return Math.asin(lineDistance(p1, p2) / 2 / r);
}
function angleOnCircle(o, p)
{
	return Math.atan2(p.y - o.y, p.x - o.x);
}

// parses to r, g, b, rgbString
function ParseHTMLColor(htmlColor)
{
	if(!htmlColor)
		return null;
	//return {r:80,g:80,b:80,rgb:"rgba(255,255,255,"};
	if(htmlColor.length == 4)
	{
		// parse #fff
		var r = parseInt(htmlColor.substr(1,1), 16);
		var g = parseInt(htmlColor.substr(2,1), 16);
		var b = parseInt(htmlColor.substr(3,1), 16);
			r = ((r<<4)|r);
			g = ((g<<4)|g);
			b = ((b<<4)|b);
		return {
			r: r,
			g: g,
			b: b,
			rgb: "rgba(" + r + "," + g + "," + b + ","
		};
	}
	if(htmlColor.length == 7)
	{
		var r = parseInt(htmlColor.substr(1,2), 16);
		var g = parseInt(htmlColor.substr(3,2), 16);
		var b = parseInt(htmlColor.substr(5,2), 16);
		return {
			r: r,
			g: g,
			b: b,
			rgb: "rgba(" + r + "," + g + "," + b + ","
		};
	}
	return { r:255, g:0, b:255, rgb:"rgba(255,0,255," };
}


// accepts a string html color like #fff or #010340,
// returns "rgba(r,g,b,a)"
function ColorToRGBASpecial(htmlColor, A)
{
	//return "rgba(255,255,180,0.5";
	return htmlColor.rgb + A + ")";
//	var c = ParseHTMLColor(htmlColor);
	//return "rgba(" + c.r + "," + c.g + "," +  c.b + "," + (Math.round(A*100)/100) + ")";
	//return "rgba(".concat(c.r, ",", c.g, ",", c.b, ",", (Math.round(A*100)/100), ")");
}

// pretty specific funciton here that will mix between 2 HTML colors.
// pos is 0-1
// and add A, returning "rgba(r,g,b,a)"
function MixColorsAndAddAlphaSpecial(c1, c2, pos, A)
{
	return "rgba(".concat(
		Math.round(((c2.r - c1.r) * pos) + c1.r), ",",
		Math.round(((c2.g - c1.g) * pos) + c1.g), ",",
		Math.round(((c2.b - c1.b) * pos) + c1.b), ",",
		(Math.round(A*100)/100), ")");
	//var c1 = ParseHTMLColor(htmlColorA);
	//var c2 = ParseHTMLColor(htmlColorB);
	// return "rgba(" +
	// 	Math.round(((c2.r - c1.r) * pos) + c1.r) + "," +
	// 	Math.round(((c2.g - c1.g) * pos) + c1.g) + "," +
	// 	Math.round(((c2.b - c1.b) * pos) + c1.b) + "," +
	// 	(Math.round(A*100)/100) + ")";
}




