
glowfi.sh in iOS + Parse for the Big Web
-----------

**Installation**

    Download Glowfish.swift and PFGlowfish.swift and drop it in your app.
    Also, make sure to get the amazing framework https://github.com/Alamofire/Alamofire which is used for our framework.
    
    Then you'll need to setup a parse account and install it in your app. I think it's best you just follow these instructions: https://parse.com/apps/quickstart

**Setup**
    
    Parse.enableLocalDatastore()
    Parse.setApplicationId('<PARSE_ID>', clientKey: '<PARSE_KEY>')
    
    PFGlowfish.setCredentials('<GLOWFISH_SID>', '<GLOWFISH_AUTH_TOKEN>')
    PFGlowfish.findAllResultsWhenUsingParse() // optional, if you want us to grab ALL data from your queries instead of Parse's imposed limits...yeah we can do that.
    

**Useage**

Get ready for some simple machine learning...

*Training*

    var dataQuery = PFQuery(className: "StuffData")
    var responseQuery = PFQuery(className: "StuffData")
    
    PFGlowfish.train(dataQuery: dataQuery, parseDataFields: ["field_name1", "field_name2"], parseResponseQuery: responseQuery, parseResponseField: "response", complete: { (objects, error) -> () in
      if error != nil {
        // looks like there's a problem here
      } else {
        // we're all good here
      }
    })

*Predict*
It's important to note that predicting will throw an error if you have not trained against a data set first.

    var dataQuery = PFQuery(className: "StuffData")
    var responseQuery = PFQuery(className: "StuffData")

    PFGlowfish.predict(dataQuery: dataQuery, parseDataFields: ["field_name1", "field_name2"], parseResponseQuery: responseQuery, parseResponseField: "response", complete: { (objects, error) -> () in
      if error != nil {
        // looks like there's a problem here
      } else {
        // we're all good here
      }
    })

*Clustering*

    var dataQuery = PFQuery(className: "StuffData")
    var responseQuery = PFQuery(className: "StuffData")

    PFGlowfish.cluster(dataQuery: dataQuery, parseDataFields: ["field_name1", "field_name2"], parseResponseQuery: responseQuery, parseResponseField: "response", complete: { (objects, error) -> () in
      if error != nil {
        // looks like there's a problem here
      } else {
        // we're all good here
      }
    })

*Feature Selection*

    var dataQuery = PFQuery(className: "StuffData")
    var responseQuery = PFQuery(className: "StuffData")

    PFGlowfish.feature_select(dataQuery: dataQuery, parseDataFields: ["field_name1", "field_name2"], parseResponseQuery: responseQuery, parseResponseField: "response", complete: { (objects, error) -> () in
      if error != nil {
        // looks like there's a problem here
      } else {
        // we're all good here
      }
    })

**Further Documentation**

Docs - http://glowfish.readme.io/  
Registration - http://glowfi.sh/

**Thank You**

Thanks so much to Matt Thompson (@matt) for creating Alamofire. Big props.
