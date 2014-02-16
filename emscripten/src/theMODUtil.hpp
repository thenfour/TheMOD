
#pragma once

#include <random>

////////////////////////////////////////////////
class Rand
{
	std::mt19937 mt;
	std::uniform_real_distribution<double> dist;

public:
	Rand(int seed) :
		mt(seed),
		dist(0, 1)
	{
	}

	double random()
	{
		return dist(mt);
	}
};


////////////////////////////////////////////////
class RandEnvelopeCPP
{
private:
	double periodFn(double x)
	{
		return abs(fmod(x, 4) - 2 );
	}

	Rand r;
	double seed;
	double a;
	double b;
	double c;

public:
	RandEnvelopeCPP(int seed, double cyclesPerSecond) :
		r(seed)
	{
		this->seed = this->r.random() * 0.0063 * cyclesPerSecond;
		this->a = 1 - (this->r.random() * 0.11);
		this->b = 1 - (this->r.random() * 0.12);
		this->c = 1 - (this->r.random() * 0.13);
	}

	// given the time in MS, return a value from -1 to 1
	// speed = 1 roughly means "1 cycle per second", but of course perturbed greatly via our functions
	double varianceFactor(int timeMS)
	{
		double x = 1000 + (this->seed * timeMS);
		double ret = periodFn(x / this->a) + periodFn(x * this->b);
		ret = (ret / 2) - 1;// it should normally be divided by the height at this point, 3, but dividing smaller means getting bigger numbers that will be clamped out.
		if(ret < -1) ret = -1;
		if(ret > 1) ret = 1;
		return ret;
	}

	// returns -1 to 1
	double height(int timeMS)
	{
		return varianceFactor(timeMS);
	}

	// return 0 to 1
	double factor(int timeMS)
	{
		return (varianceFactor(timeMS) + 1) / 2;
	}

	double vary(int timeMS, double originalValue, double variationAmt)
	{
		return originalValue + (variationAmt * varianceFactor(timeMS));
	}

};


// var __cachedRandEnvelopes = [];
// var __cachedRandEnvelopeCount = 0;

// function CachedRandEnvelope(x, y, speed)
// {
// 	if(!__cachedRandEnvelopes[x])
// 	{
// 		__cachedRandEnvelopes[x] = [];
// 	}
// 	if(!__cachedRandEnvelopes[x][y])
// 	{
// 		__cachedRandEnvelopes[x][y] = new RandEnvelope(__cachedRandEnvelopeCount, speed);
// 		__cachedRandEnvelopeCount ++;
// 	}
// 	return __cachedRandEnvelopes[x][y];
// }



// // Find the points where the two circles intersect.
// function FindCircleCircleIntersections(cx0, cy0, radius0, cx1, cy1, radius1)
// {
// 	// Find the distance between the centers.
// 	var dx = cx0 - cx1;
// 	var dy = cy0 - cy1;
// 	var dist = Math.sqrt(dx * dx + dy * dy);

// 	// See how many solutions there are.
// 	if (dist > radius0 + radius1) return [];// No solutions, the circles are too far apart.
// 	else if (dist < Math.abs(radius0 - radius1)) return [];// No solutions, one circle contains the other.
// 	else if ((dist == 0) && (radius0 == radius1)) return [];// No solutions, the circles coincide.

// 	// Find a and h.
// 	var a = (radius0 * radius0 - radius1 * radius1 + dist * dist) / (2 * dist);
// 	var h = Math.sqrt(radius0 * radius0 - a * a);

// 	// Find P2.
// 	var cx2 = cx0 + a * (cx1 - cx0) / dist;
// 	var cy2 = cy0 + a * (cy1 - cy0) / dist;

// 	// Get the points P3.
// 	var intersection1 = {
// 		x: cx2 + h * (cy1 - cy0) / dist, 
// 		y: cy2 - h * (cx1 - cx0) / dist
// 	};

// 	var intersection2 = {
// 		x: cx2 - h * (cy1 - cy0) / dist,
// 		y: cy2 + h * (cx1 - cx0) / dist
// 	};

// 	return [intersection1, intersection2];
// }

// function CircleCircleIntersectionLower(p0, radius0, p1, radius1)
// {
// 	var i = FindCircleCircleIntersections(p0.x, p0.y, radius0, p1.x, p1.y, radius1);
// 	if(i.length == 0)
// 		return p0;// just forget about it, return a valid value.
// 	if(i[0].y < i[1].y)
// 		return i[1];
// 	return i[0];
// }
// /*
// function lineDistance( point1, point2 )
// {
//   var xs = 0;
//   var ys = 0;
 
//   xs = point2.x - point1.x;
//   xs = xs * xs;
 
//   ys = point2.y - point1.y;
//   ys = ys * ys;
 
//   return Math.sqrt( xs + ys );
// }
// */
// function angleBetweenPointsOnCircle(p1, p2, r)
// {
// 	return Math.asin(lineDistance(p1, p2) / 2 / r);
// }
// function angleOnCircle(o, p)
// {
// 	return Math.atan2(p.y - o.y, p.x - o.x);
// }

// // parses to r, g, b, rgbString
// function ParseHTMLColor(htmlColor)
// {
// 	if(!htmlColor)
// 		return null;
// 	//return {r:80,g:80,b:80,rgb:"rgba(255,255,255,"};
// 	if(htmlColor.length == 4)
// 	{
// 		// parse #fff
// 		var r = parseInt(htmlColor.substr(1,1), 16);
// 		var g = parseInt(htmlColor.substr(2,1), 16);
// 		var b = parseInt(htmlColor.substr(3,1), 16);
// 			r = ((r<<4)|r);
// 			g = ((g<<4)|g);
// 			b = ((b<<4)|b);
// 		return {
// 			r: r,
// 			g: g,
// 			b: b,
// 			rgb: "rgba(" + r + "," + g + "," + b + ","
// 		};
// 	}
// 	if(htmlColor.length == 7)
// 	{
// 		var r = parseInt(htmlColor.substr(1,2), 16);
// 		var g = parseInt(htmlColor.substr(3,2), 16);
// 		var b = parseInt(htmlColor.substr(5,2), 16);
// 		return {
// 			r: r,
// 			g: g,
// 			b: b,
// 			rgb: "rgba(" + r + "," + g + "," + b + ","
// 		};
// 	}
// 	return { r:255, g:0, b:255, rgb:"rgba(255,0,255," };
// }

// /*
// // accepts a string html color like #fff or #010340,
// // returns "rgba(r,g,b,a)"
// function ColorToRGBASpecial(htmlColor, A)
// {
// 	return htmlColor.rgb + A + ")";
// }

// // pretty specific funciton here that will mix between 2 HTML colors.
// // pos is 0-1
// // and add A, returning "rgba(r,g,b,a)"
// function MixColorsAndAddAlphaSpecial(c1, c2, pos, A)
// {
// 	return "rgba(".concat(
// 		Math.round(((c2.r - c1.r) * pos) + c1.r), ",",
// 		Math.round(((c2.g - c1.g) * pos) + c1.g), ",",
// 		Math.round(((c2.b - c1.b) * pos) + c1.b), ",",
// 		(Math.round(A*100)/100), ")");
// }

// function MixColorsSpecial(c1, c2, pos)
// {
// 	return "rgba(128,128,128,0.5)";
// 	return "#888";
// 	return "rgb(".concat(
// 		Math.round(((c2.r - c1.r) * pos) + c1.r), ",",
// 		Math.round(((c2.g - c1.g) * pos) + c1.g), ",",
// 		Math.round(((c2.b - c1.b) * pos) + c1.b)
// 		);
// }

// // mixes from c1->c2 along pos1, then mixes that result to c3 along pos2.
// function MixColorsTwiceSpecial(c1, c2, pos1, c3, pos2)
// {
// 	return "rgba(128,128,128,0.5)";
// 	return "#888";
// 	var r = ((c2.r - c1.r) * pos1) + c1.r;
// 	r = ((c3.r - r) * pos2) + r;
// 	var g = ((c2.g - c1.g) * pos1) + c1.g;
// 	g = ((c3.g - g) * pos2) + g;
// 	var b = ((c2.b - c1.b) * pos1) + c1.b;
// 	b = ((c3.b - b) * pos2) + b;
// 	return "rgb(".concat(
// 		Math.round(r), ",",
// 		Math.round(g), ",",
// 		Math.round(b), ")"
// 		);
// }
// */
// function rgbToHex(r, g, b) {
//     return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
// }

// function MixColors(c1, c2, c2amt)
// {
// 	var r = ((c2.r - c1.r) * c2amt) + c1.r;
// 	var g = ((c2.g - c1.g) * c2amt) + c1.g;
// 	var b = ((c2.b - c1.b) * c2amt) + c1.b;
// 	return rgbToHex(Math.round(r), Math.round(g), Math.round(b));
// }

// // precomputed table of colors
// var TheModColorMixingTable = function(c1, c2, steps)
// {
// 	this.c1 = c1;
// 	this.c2 = c2;
// 	this.c1parsed = ParseHTMLColor(c1);
// 	this.c2parsed = ParseHTMLColor(c2);
// 	this.steps = steps;
// 	this.t = [];
// 	for(var i = 0; i < steps; ++ i)
// 	{
// 		this.t.push(MixColors(this.c1parsed, this.c2parsed, i / (steps - 1)));// maybe do this in such a way that i will REACH steps and result in 1.0?
// 	}
// }

// TheModColorMixingTable.prototype.GetColor = function(amt)
// {
// 	if(amt <= 0)
// 		return this.t[0];
// 	if(amt >= 1)
// 		return this.t[this.steps - 1];
// 	return this.t[(this.steps * amt) | 0];
// }

