var http = require('http');
var d = '';
http.get(process.argv[2], function(response) {
	response.setEncoding('utf8');
	response.on("data", function (data) { 
		d += data;
	});
	response.on("end", function () {
		console.log(d.length);
		console.log(d);
	});
});

