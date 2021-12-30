

var port = 1337;


console.log("");
console.log("Starting web server...");
console.log("");
console.log("http://localhost:"+port+"/default.html");
console.log("Press CTRL+C to exit web server.");
console.log("");


var connect = require('connect');
var serveStatic = require('serve-static');

connect().use(serveStatic("./www-release")).listen(port);

