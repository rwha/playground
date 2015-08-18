var http = require('http');
var fs = require('fs');
var file = fs.createReadStream(process.argv[3]);

var server = http.createServer(function(req, res) {
	res.writeHead(200, { 'content-type': 'text/javascript' })
	file.pipe(res);
});

server.listen(Number(process.argv[2]));
