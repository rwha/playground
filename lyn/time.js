var net = require('net');

var server = net.createServer(function(c) {
	var CD = new Date();
	var y = CD.getFullYear();
	var m = CD.getMonth();
	var d = CD.getDate();
	var h = CD.getHours();
	var i = CD.getMinutes();
	m++
	c.end(y+'-0'+m+'-'+d+' '+h+':'+i+'\r\n');

});

server.listen(process.argv[2]);


