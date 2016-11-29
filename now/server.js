var app = require('http').createServer(handler)
var io = require('socket.io')(app);
var fs = require('fs');
var os = require('os');
var run = require('child_process');

app.listen(9090);

function read(file) {
	fs.readFile('/proc/'+file, function(e,d) {
		 d.toString()
	});
}



function handler (req, res) {
	res.writeHead(200);
	res.end();
}

io.on('connection', function(socket) {
	io.emit('status', 'connection');
/*	
	var resp = {};
	resp.host = os.hostname();
	resp.up = os.uptime();
	resp.mem = os.totalmem();
	resp.cpu = os.cpus().length;
	resp.load = os.loadavg();
	socket.emit('conn', resp);

	run.exec('vmstat 1 2 |tail -1', function(e,so,se) {
		socket.emit('stat', so);
	});

	run.exec('iostat 1 2 -x -d dm-0|tail -2|head -1', function(e,so,se) {
		socket.emit('iostat', so);
	});
*/


	//send regular updates
	setInterval(function(){
		run.exec('vmstat 1 2 |tail -1', function(e,so,se) {
			var data = {};
			data.stat = so;
			data.cpu = os.loadavg();
			socket.emit('stat', data);
		});
	}, 1000 );

	//setInterval(function(){
	//	run.exec('iostat 1 2 -x -d dm-0|tail -2|head -1', function(e,so,se) {
	//		socket.emit('iostat', so);
	//	});
	//}, 10000);

});


