const AWS = require("aws-sdk");
AWS.config.update({ region: "us-east-2" });

const { JSDOM } = require("jsdom");
const https = require("https");

/* Expected Input Payload
   {
        #The app ids to fetch web page info for
        app_ids = [] 
   }
 
  Expected Output:
    {
        app_id_features: [
            {
                app_id: <id (string)>
                features: {
                    <feature1>: <boolean>,
                    <feature2>: <boolean>,
                    <featureN>: <boolean>,
                }
            }
        ]
    }
*/

//This function handles scraping the Steam Store pages for missing info, and then passes it back to the main function to be added to DynamoDB
exports.handler = async function (event, context) {
    let requestURL = process.env.searchURL;
    const app_ids = event.app_ids;
    return await fetchStoreInfo(requestURL, app_ids);
};

async function fetchStoreInfo(requestURL, app_ids) {
    console.log("[fetchStoreInfo] Lambda call received");

    let response = {};
    let ongoingPromises = [];

    //Cycle through each app_id and retrieve its store page HTML. Add that HTML to htmlParserInput to be passed onto parseHTMLForGameFeatures
    for (const id of app_ids) {
        //Add ID for this request
        requestURL += id;

        const MAX_REDIRECTS = 5;

        let fetchInfoPromise = getStorePage(requestURL)
            .then(res => {
                let numRedirects = 0;
                console.log("Then statement");
                do {
                    if (res.statusCode >= 300 && res.statusCode < 400) {
                        try {
                            console.log("Redirecting");
                            let redirectURL = new URL(res.headers.location);
                            getStorePage(requestURL);
                        }
                        catch (e) { console.log(JSON.stringify(e)); }
                    }
                    else if (res.statusCode > 400) { console.log("400 Error Received"); }
                    else {
                        console.log(JSON.stringify(res));
                        return res;
                    }
                } while (numRedirects < MAX_REDIRECTS)
            })
            .then(input => parseHTMLForGameFeatures(formatHTMLForParsing(id, input.body)));

        ongoingPromises.push(fetchInfoPromise);

        //Trim ID for next iteration
        requestURL = requestURL.slice(0, requestURL.lastIndexOf("/") + 1);
    }

    return Promise.all(ongoingPromises)
        .then(valueArr => { //Format Response
            response["app_id_features"] = [];
            valueArr.forEach(val => { response["app_id_features"].push(val.app_id_features); });
            console.log(response);
            return response;
        });


}

///Expected input: URL to be requested (string)
async function getStorePage(newURL) {
    const URLObj = new URL(newURL);
    const requestOptions = {
        host: URLObj.host,
        path: URLObj.pathname,
        method: "GET"
    }

    console.log(`host: ${requestOptions.host}\npath: ${requestOptions.path}`);

    return await new Promise((resolve, reject) => {
        let req = https.request(requestOptions, function (incomingMessage) {

            let response = {
                statusCode: incomingMessage.statusCode,
                headers: incomingMessage.headers,
                body: []
            };

            incomingMessage.on('data', function (chunk) {
                console.log("Adding Data");
                response.body.push(chunk);
            });

            incomingMessage.on('end', function () {
                console.log("End Response Triggered");
                response.body = response.body.join();

                resolve(response);
            });

            incomingMessage.on('error', function (err) {
                console.log("Error response trigger");
                reject(`error: ${JSON.stringify(err)}`);
            });
        }).end();
    }).then(val => {
        console.log(`HTTP Response: ${JSON.stringify(val)}`);
        return val;
    })
        .catch(e => { console.log(e); });
}

/* Expected Input:
    {
        store_page: 
            {
                app_id: <id (string)>
                html: <html (string)>
            }
            
    }
    
    Expected Output:
    {
        app_id_features: 
            {
                app_id: <id (string)>
                features: {
                    <feature1>: <boolean>,
                    <feature2>: <boolean>,
                    <featureN>: <boolean>,
                }
            }
        
    }
*/
function parseHTMLForGameFeatures(input) {
    //Determine Game Features to Search For (probably parse some file or smthn)
    const SEARCH_STRINGS = process.env.searchStrings.split(',').map(rawString => rawString.toLowerCase());

    let response = {};
    const generateAppIdFeatureObject = (app_id, features) => { return { "app_id": app_id, "features": features }; };

    //Loop and look for game features

    const pageHtml = new JSDOM(input.store_page.html).window.document;
    let foundFeatures = {};

    //Find matches
    for (const node of pageHtml.getElementsByClassName("label")/*pageHtml.querySelectorAll("div.game_area_features_list_ctn div.label")*/) {
        let nodeTextContentLower = node.textContent.toLowerCase();
        console.log(nodeTextContentLower);
        if (SEARCH_STRINGS.includes(nodeTextContentLower)) {
            console.log("Feature Found");
            foundFeatures[`${nodeTextContentLower}`] = true;
        }
    }

    //Set all search strings that weren't found to false in response
    SEARCH_STRINGS.filter(searchString => !(searchString in foundFeatures))
        .forEach(missingString => foundFeatures[`${missingString}`] = false);

    //Create Response
    response["app_id_features"] = generateAppIdFeatureObject(input.store_page.app_id, foundFeatures);
    console.log(`Done looking for matches, here's the final object: ${response}`);
    return response;
}

//Creates input for parseHTMLForGameFeatures
function formatHTMLForParsing(app_id, html) {
    return {
        "store_page": {
            "app_id": app_id,
            "html": html
        }
    }

}