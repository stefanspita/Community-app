var express = require('express');
_ = require("underscore");
fs = require("fs");
var MongoClient = require('mongodb').MongoClient;
var bodyParser = require('body-parser');

var app = express();
app.use(express.static(__dirname + '/client/public'));
app.use(bodyParser.urlencoded({ extended:false, limit:"100mb" }));

app.get('/getData/initialData', function(req, res) {
    MongoClient.connect('mongodb://127.0.0.1:27017/communityData', function (err, db) {
        if (err) throw err;
        var collection = db.collection('initialData');
        collection.find().toArray(function (err, results) {
            res.json({data:results});
            db.close();
        });
    });
});

app.get('/getData/finalData', function(req, res) {
    MongoClient.connect('mongodb://127.0.0.1:27017/communityData', function (err, db) {
        if (err) throw err;
        var collection = db.collection('finalData');
        collection.find().toArray(function (err, results) {
            res.json({data:results});
            db.close();
        });
    });
});

app.post('/saveData/finalData', function(req, res) {
    var data = JSON.parse(_.keys(req.body)[0]);
    var temp;

    MongoClient.connect('mongodb://127.0.0.1:27017/communityData', function (err, db) {
        if (err) throw err;
        var collection = db.collection("finalData");
        collection.insert(data, function (err, docs) {
            if (err) throw err;
            db.close();
        });
        res.json({success: true});

    });
});

app.post('/saveData/initialData', function(req, res) {
    var data = JSON.parse(_.keys(req.body)[0]);

    MongoClient.connect('mongodb://127.0.0.1:27017/communityData', function (err, db) {
        if (err) throw err;
        var collection = db.collection("initialData");
        for (var i = 0; i < data.length; i++) {
            collection.insert(data[i], function (err, docs) {
                if (err) throw err;
            });
        }
        res.json({success: true});
    });
});

console.log("App listening on http://localhost:3000");
app.listen(3000);