//$.getScript("mersenne-twister.js");


// generates a deterministic, "random" envelope bound to time
var RandEnvelope = function(seed)
{
	this.m = new MersenneTwister(seed);
	// we keep our internal position so you can adjust speed per frame.
	// 2PI = a cycle, sorta. but our cycles are not uniform so here we pick any position within 1000 frames to start from:
	this.x = this.m.random() * 1000 * (Math.PI * 2);
	this.lastTimeMS = 0;
};

// given the time in MS, return a value from -1 to 1
// speed = 1 roughly means "1 cycle per second", but of course perturbed greatly via our functions
RandEnvelope.prototype.varianceFactor = function(frame, cyclesPerSecond)
{
	var timeElapsedMS = frame.time - this.lastTimeMS;
	this.lastTimeMS = frame.time;
	this.x += (2 * Math.PI) * cyclesPerSecond * (timeElapsedMS / 1000);// where in the virtrual "cycle" are we? 2PI = 1 cycle. frame.time is milliseconds
	return (Math.sin(this.x / 0.9) + Math.sin(this.x * 0.9) + Math.sin(this.x * 0.86) + Math.sin(this.x / 0.86)) / 4;
};

RandEnvelope.prototype.height = function(frame, cyclesPerSecond)
{
	return this.varianceFactor(frame, cyclesPerSecond);
}

RandEnvelope.prototype.vary = function(frame, cyclesPerSecond, originalValue, variationAmt)
{
	return originalValue + (variationAmt * this.varianceFactor(frame, cyclesPerSecond));
};


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
