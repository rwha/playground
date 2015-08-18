module.exports = function(p, x, callback) {
	var ret = [];
	var fs = require('fs')
	var path = require('path');
	fs.readdir(p, function (err,data) {
		if(!err) {
			data.forEach(function(file) {
				if(path.extname(file) == '.'+x){
					ret.push(file);
				}
			})
			callback(null, ret)
		} else {
			callback(err)
		}
	})
}
