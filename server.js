var express = require('express');
fs = require("fs");
var app = express();
app.use(express.static(__dirname + '/client/public'));

app.get('/', function(req, res){

});

console.log("App listening on http://localhost:3000");
app.listen(3000);