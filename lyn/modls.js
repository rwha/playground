var ls = require('./modules/ls.js')

ls(process.argv[2], process.argv[3], function (err, data) {
	if (!err) {
		data.forEach(function(item){
			console.log(item);
		})
	} 
})
