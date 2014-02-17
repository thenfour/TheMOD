
#pragma once

typedef unsigned int uint;

#include <random>
#include <map>




////////////////////////////////////////////////
constexpr uint lightBlue() { return 0x660000; };
constexpr uint darkBlue() { return 0x440000; }
constexpr uint lightYellow() { return 0xf2d700; }
constexpr uint darkYellow() { return 0x633c00; }
constexpr uint darkGray() { return 0x6a5f5e; }
constexpr uint lightPurple() { return 0x5e506f; }
constexpr uint medPurple() { return 0x40364b; }
constexpr uint darkPurple() { return 0x221d28; }
constexpr uint darkDarkPurple() { return 0x0c0c15; }
constexpr uint lightGray() { return 0xd3d3d3; }
constexpr uint black() { return 0x0; }


////////////////////////////////////////////////
constexpr double pi() { return 3.141592653589793238463; }
constexpr float pif() { return 3.14159265358979f; }

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
inline double my_mod(double a, double N)
{
	return a - N*floor(a/N);
} //return in range [0, N)

////////////////////////////////////////////////
class RandEnvelope
{
private:
	double periodFn(double x) const
	{
		//return sin(x);
		return fabs(fmod(x, 4) - 2 );
	//	return fabs(my_mod(x, 4) - 2 );
	}

	Rand r;
	double seed;
	double a;
	double b;
	double c;

public:
	RandEnvelope(int seed, double cyclesPerSecond) :
		r(seed)
	{
		this->seed = this->r.random() * 0.0063 * cyclesPerSecond;
		this->a = 1 - (this->r.random() * 0.11);
		this->b = 1 - (this->r.random() * 0.12);
		this->c = 1 - (this->r.random() * 0.13);
	}

	RandEnvelope() :
		r(9)
	{
		this->seed = this->r.random() * 0.0063;
		this->a = 1 - (this->r.random() * 0.11);
		this->b = 1 - (this->r.random() * 0.12);
		this->c = 1 - (this->r.random() * 0.13);
	}

	RandEnvelope(const RandEnvelope& rhs) :
		a(rhs.a),
		b(rhs.b),
		c(rhs.c),
		seed(rhs.seed),
		r(rhs.r)
	{
	}

  RandEnvelope& operator= (const RandEnvelope& rhs)
  {
		this->a = rhs.a;
		this->b = rhs.b;
		this->c = rhs.c;
		this->seed = rhs.seed;
		this->r = rhs.r;
		return *this;
  }

	// given the time in MS, return a value from -1 to 1
	// speed = 1 roughly means "1 cycle per second", but of course perturbed greatly via our functions
	double varianceFactor(double timeMS) const
	{
		double x = 1000 + (this->seed * timeMS);
		double ret = periodFn(x / this->a) + periodFn(x * this->b);
		ret = (ret / 2) - 1;// it should normally be divided by the height at this point, 3, but dividing smaller means getting bigger numbers that will be clamped out.
		if(ret < -1) ret = -1;
		if(ret > 1) ret = 1;
		return ret;
	}

	// returns -1 to 1
	double height(int timeMS) const
	{
		return varianceFactor(timeMS);
	}

	// return 0 to 1
	double factor(int timeMS) const
	{
		return (varianceFactor(timeMS) + 1) / 2;
	}

	double vary(int timeMS, double originalValue, double variationAmt) const
	{
		return originalValue + (variationAmt * varianceFactor(timeMS));
	}

};


// last key arg is speed * 100
std::map<std::tuple<uint, uint, uint>, RandEnvelope> __cachedRandEnvelopes;
uint __cachedRandEnvelopeCount = 0;

RandEnvelope& CachedRandEnvelope(uint x, uint y, double speed)
{
	uint speed2 = (uint)(round(speed * 100));
	auto key = std::tuple<uint, uint, uint>(x,y,speed2);
	if(__cachedRandEnvelopes.find(key) == __cachedRandEnvelopes.end())
	{
		__cachedRandEnvelopes[key] = RandEnvelope(__cachedRandEnvelopeCount, speed);
		__cachedRandEnvelopeCount ++;
	}
	return __cachedRandEnvelopes[key];

/*
	if(!__cachedRandEnvelopes[x])
	{
		__cachedRandEnvelopes[x] = [];
	}
	if(!__cachedRandEnvelopes[x][y])
	{
		__cachedRandEnvelopes[x][y] = new RandEnvelope(__cachedRandEnvelopeCount, speed);
		__cachedRandEnvelopeCount ++;
	}
	return __cachedRandEnvelopes[x][y];*/
}



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


// optimization:don't disassemble & reassemble colors.
class TheModColor
{
public:
	uint r;
	uint g;
	uint b;
	TheModColor() : r(0),g(0),b(0) {}
	TheModColor(uint c) :
		b(c & 0xff),
		g((c >> 8) & 0xff),
		r((c >> 16) & 0xff)
	{
	}
	TheModColor(uint r, uint g, uint b) :
		b(b),
		g(g),
		r(r)
	{
	}

	inline uint rgb() const
	{
		return (r << 16) | (g << 8) | b;
	}
};


inline TheModColor MixColors(TheModColor c1, TheModColor c2, double c2amt)
{
	uint r = (c2amt * (c2.r - c1.r)) + c1.r;
	uint g = (c2amt * (c2.g - c1.g)) + c1.g;
	uint b = (c2amt * (c2.b - c1.b)) + c1.b;
	return TheModColor(r,g,b);
}


class TheModColorMixingTable
{
public:
	TheModColor c1;
	TheModColor c2;
	uint steps;
	std::vector<TheModColor> t;

	TheModColorMixingTable(TheModColor c1_, uint c2_, uint steps_) :
		c1(c1_),
		c2(c2_),
		steps(steps_)
	{
		for(uint i = 0; i < steps; ++ i)
		{
			t.push_back(
				// maybe do this in such a way that i will REACH steps and result in 1.0?
				MixColors(c1, c2, (double)i / (steps - 1)));
		}
	}

	TheModColor GetColor(double amt) const
	{
		if(amt <= 0)
			return this->t[0];
		if(amt >= 1)
			return this->t[this->steps - 1];
		return this->t[(int)round(amt * this->steps)];
	}

};
