var http = require('http');
var all = [[],[],[]];
all[0][0] = process.argv[2];
all[1][0] = process.argv[3];
all[2][0] = process.argv[4];
all[0][1] = '';
all[1][1] = '';
all[2][1] = '';

var i = 0;

all.forEach(function(url) {	
	http.get(url[0], function(response) {
		response.setEncoding('utf8');
		response.on("data", function (data) { 
			url[1] += data;
		});
		response.on("end", function () {
			i++
			if(i == 3) {
					console.log(all[0][1]);
					console.log(all[1][1]);
					console.log(all[2][1]);
			}
		});
	});
});

