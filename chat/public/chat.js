window.onload = function() {
	var messages = [];
	var socket = io.connect('http://10.1.201.112:9999');
	var field = document.getElementById("field");
	var sendButton = document.getElementById("send");
	var content = document.getElementById("content");
	var name = document.getElementById("name");
 
	socket.on('message', function (data) {
	if(data.message) {
		messages.push(data.message);
		var html = '';
		for(var i=0; i<messages.length; i++) {
			html += messages[i] + '<br />';
		}
		content.innerHTML = html;
		content.scrollTop = content.scrollHeight;
	} else {
		console.log("There is a problem:", data);
	}
	});
 
	sendButton.onclick = sendMessage = function() {
		var text = field.value;
		if(text) {
			socket.emit('send', { message: name.value+': '+text });
			field.value = "";
		}
	};
 
}

$(document).ready(function(){
	$("#field").keyup(function(e){
		if(e.which == 13) {
			sendMessage();
		}
	});
});
