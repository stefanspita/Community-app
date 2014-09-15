require('coffee-script');
var express = require('express');
_ = require("underscore");
fs = require("fs");
var MongoClient = require('mongodb').MongoClient;
var bodyParser = require('body-parser');
var calculateCorrelation = require("./calculateCorrelation");

// configure express.js with the body parser library used to send and receive data in the correct JSON format
var app = express();
app.use(express.static(__dirname + '/client/public'));
app.use(bodyParser.urlencoded({ extended:false, limit:"100mb" }));

// open the database connection to be used whenever needed
var db;
MongoClient.connect('mongodb://127.0.0.1:27017/communityData', function (err, database) {
    if (err) throw err;
    db = database;
});

// route used by the client to get the questionnaire data from the database
app.get('/getData/initialData', function(req, res) {
    var collection = db.collection('initialData');
    collection.find().toArray(function (err, results) {
        res.json({data:results});
    });
});

// route used by the client to get the communities data saved in the database
app.get('/getData/finalData', function(req, res) {
    var collection = db.collection('finalData');
    collection.find().toArray(function (err, results) {
        res.json({data:results});
    });
});

// route used by the client to get the community defining attribute probabilities
// if the probabilities are cached in the database, they are being returned, otherwise the "calculateCorrelation.coffee" file is used to calculate them
// once they are calculated, the results are saved in the database and they are also sent to the client, as requested
app.get('/getCommunityAttributes', function(req, res) {
    var collection = db.collection('correlationData');
    collection.find().toArray(function (err, results) {
        if(!results.length) {
            calculateCorrelation(db, function(err, results){
                if(err) throw err;
                else
                    collection.insert({correlation:results}, function (err) {
                        if (err) throw err;
                    });
                res.json({data:results});
            });
        }
        else res.json({data:results[0].correlation});
    });

});

// when a user uploads the questionnaire data file, this route is used by the client to send the whole chunk of data
// to the server, for the whole set to be saved onto the database, to be used for future uses
app.post('/saveData/initialData', function(req, res) {
    var data = JSON.parse(_.keys(req.body)[0]);
    var collection = db.collection("initialData");

    // when a new questionnaire data file is saved in the database, the probabilities calculated for the previous file are deleted,
    // because they lose their relevancy
    var correlationData = db.collection('correlationData');
    correlationData.remove({}, function(err){
        if (err) throw err;
    });

    // the previously saved questionnaire data is fully deleted before the new uploaded one is being saved
    collection.remove({}, function(err) {
        if (err) throw err;
        else {
            for (var i = 0; i < data.length; i++) {
                collection.insert(data[i], function (err) {
                    if (err) throw err;
                });
            }
        }
        res.json({success: true});
    });
});

// when a user uploads a community list file, this route is used by the client to send the whole chunk of data
// to the server, for the whole set to be saved onto the database, to be used for future uses
app.post('/saveData/finalData', function(req, res) {
    var data = JSON.parse(_.keys(req.body)[0]);
    var collection = db.collection("finalData");

    // when a new community list file is saved in the database, the probabilities calculated for the previous community list are deleted,
    // because they lose their relevancy
    var correlationData = db.collection('correlationData');
    correlationData.remove({}, function(err){
        if (err) throw err;
    });

    // the previously saved community list is fully deleted before the new uploaded one is being saved
    collection.remove({}, function(err){
        if (err) throw err;
        else {
            collection.insert(data, function (err) {
                if (err) throw err;
                res.json({success: true});
            });
        }
    });
});

// tell the developer running the server how the web application can be accessed and run the web server
console.log("App listening on http://localhost:3000");
app.listen(3000);