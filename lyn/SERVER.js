var http = require('http');
var post = '';

var server = http.createServer(function(req, res) {
	req.setEncoding('utf8');
	req.on('data', function(pd) {
		post += pd;
	});
	req.on('end', function() {
		res.writeHead(200, "OK", {'Content-Type': 'text/plain'});
		res.end(post.toUpperCase());
	});

});

server.listen(Number(process.argv[2]));
