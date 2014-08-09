var fs = require('fs');
var fluent = require("fluent-async");
var _ = require("underscore");
var possibleValues = require("./client/app/data/possibleValues");

var getInitialData = function(db, callback) {
    var collection = db.collection('initialData');
    collection.find().toArray(callback);
};
var getCommunityData = function(db, callback) {
    var collection = db.collection('finalData');
    collection.find().toArray(callback);
};

function getJsonData(initial, final) {
    if(possibleValues) console.log("JSON FINE");
    return ["cct1001"];
}

module.exports = function(db, callback) {
    fluent.create({
        db:db
    }).strict().async({
        getInitialData:getInitialData
    }, "db").async({
        getCommunityData:getCommunityData
    }, "db").sync({
        getJsonData:getJsonData
    }, "getInitialData", "getCommunityData").run(callback, "getJsonData");
}
