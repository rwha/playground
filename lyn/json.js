var http = require('http');
var url = require('url');
var response = {};

var server = http.createServer(function(req, res) {
//	req.setEncoding('utf8');
	req.on('data', function(data) {
		var pd = data;
	});
	req.on('end', function() {
		var rurl = url.parse(req.url, true);
		var gt = rurl.query.iso
		var rt = new Date(gt);
		if (rurl.pathname === '/api/parsetime'){
			response['hour'] = rt.getHours();
			response['minute'] = rt.getMinutes();
			response['second'] = rt.getSeconds();
		} else {
			response['unixtime'] = rt.getTime();
		};
//	});
//	req.on('end', function() {
		res.writeHead(200, "OK", {'Content-Type': 'application/json'});
		res.end(JSON.stringify(response));
		response = {};
	});

});
server.listen(Number(process.argv[2]));
