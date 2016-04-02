
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


// This gets the score of each location
Parse.Cloud.define("totalScore", function(request, response) {
                   var query = new Parse.Query("BouncePost");
                   query.equalTo("locationID", request.params.key);
                   
                   query.find({
                              success: function(results) {
                              var sum = 0;
                              for (var i = 0; i < results.length; ++i) {
                              sum += results[i].get("score");
                              }
                              response.success(sum);
                              },
                              error: function() {
                              response.error("score lookup failed");
                              }
                              });
                   });

