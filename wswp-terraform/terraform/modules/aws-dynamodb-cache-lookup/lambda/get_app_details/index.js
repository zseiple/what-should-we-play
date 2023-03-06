const AWS = require("aws-sdk");
AWS.config.update({ region: "us-east-2" });

const ddb = new AWS.DynamoDB({
    apiVersion: '2012-08-10',
    endpoint: process.env.dynamoEndpoint
});

const lambda = new AWS.Lambda({
    apiVersion: "2015-03-31",
    endpoint: process.env.lambdaEndpoint
});

/* Expected Input Payload
 * {
 *      #The app ids to check dynamodb for
 *      app_ids = []
 * }
 *
 * Expected Output
 * {
 *      app_details: [
 *      {
 *          app_id: <string>
 *          features: {
 *              <feature1>: <bool>,
 *              <feature2>: <bool>,
 *              <featureN>: <bool>
 *          }
 *      }
 *      ]
 * }
*/

/*
 * | getAppDetails | 
 * This function handles checking the DynamoDB instance for requested app_ids and pulls any information on that app.
 * If the app id is not present in the DB, this function will call another lambda function (fetchStoreInfo) to fetch the info from the Steam
 * Store page. When that function returns the info from the missing app ids, this function will also handle the inserts to the table.
 */
exports.handler = async function (event, context) {
    console.log("EVENT: \n" + JSON.stringify(event, null, 2));

    const MAX_BATCHES = 5;
    const BATCH_SIZE = 100;

    console.log(`Event being received:\n${JSON.stringify(event)}`);

    //Copy input array
    let requestedAppIds = JSON.parse(JSON.parse(event.body));
    console.log(`Keys:\n${Object.keys(requestedAppIds)}`);
    console.log(`requestedAppIds:\n${requestedAppIds}`);
    console.log(`Accessing app_ids:\n${requestedAppIds["app_ids"]}`);
    requestedAppIds = requestedAppIds.app_ids.slice();

    let foundIds = [], missedIds = [];
    let ongoingPromises = [];

    let currentBatch = 1;
    //Continue while there are still batches
    while (requestedAppIds.length > 0 && currentBatch <= MAX_BATCHES) {
        //Split into batch
        let batch = requestedAppIds.splice(0, BATCH_SIZE);

        let batchPromise = fetchAppDetails(batch)
            .then(response => {
                console.log(`fetchAppDetails func response:\n${JSON.stringify(response)}`)
                //Add Found Ids to collection
                response["Hit"].forEach(appDetail => { foundIds.push(appDetail); });

                //Add Missed Ids to collection, once loop completes these will be added into table
                missedIds = missedIds.concat(response["Miss"]);

                //Add Unprocessed Ids back into requestedAppIds to get reprocessed
                requestedAppIds = requestedAppIds.concat(response["Unprocessed"]);

            })
            .catch(e => console.log(`Error in requesting from cache: ${e}`));

        //Queue this batch on promise array to wait for completion
        ongoingPromises.push(batchPromise);
        currentBatch++;
    }

    if (currentBatch >= MAX_BATCHES)
        console.log("Maximum Iterations Reached");



    const NO_WRITE = false;
    //Batches Finished, now missed ID info need to be fetched. Missed IDs must be passed to fetchStoreInfo lambda function
    return Promise.all(ongoingPromises)
        .then(() => {
            //Check which App IDs/Details were not found in cache, pass those to helper lambda to check
            console.log(missedIds.length > 0 ?
                `Missed Ids that need requested to Lambda: ${missedIds.join(',')}` :
                `There are no missed Ids. We will not write to DynamoDB this run`
            );

            //Perform subsequent write operations IF there were ids not found in the cache
            return missedIds.length > 0 ? invokeLambda(lambdaFunctions.FetchStoreInfo, context, { "app_ids": missedIds }) : Promise.resolve(NO_WRITE);
        })
        .then(missedIdDetails => {

            //Write to DB and format response
            if (missedIdDetails != NO_WRITE) {
                missedIdDetails = JSON.parse(missedIdDetails.Payload);
                console.log("Writing to DB..");

                //User does not need to wait for the write, just start it and log response
                invokeLambda(lambdaFunctions.WriteToCache, context, missedIdDetails);

                //Format Missed IDs for foundIds response
                missedIdDetails["app_id_features"].forEach(appDetail => { foundIds.push(appDetail); });
            }
            else
                console.log("No DB Write is needed");

            const finalResponse = {
                "isBase64Encoded": false,
                "statusCode": 200,
                "headers": {},
                "multiValueHeaders": {},
                "body": JSON.stringify({ "app_details": foundIds })
            };
            console.log(finalResponse);
            //Final response return
            return finalResponse;
        })
        .catch(e => {
            console.log(`Some error: ${e}`);
        });

}

//Sends the dynamoDB request and transforms response into a simple map
const fetchAppDetails = async function (ids) {
    let response = await ddb.batchGetItem(generateBatchGetItemParams(ids)).promise()
        .then(data => data)
        .catch(error => { console.log(`fetchAppDetails error: ${error}`); });
    //{Responses: [<TABLENAME> : { <ATTRIBUTENAME> : {S: string}, <ATTRIBUTENAME2>: {}}]}

    console.log("DynamoDB Response \n" + JSON.stringify(response, null, 2));

    let result = {
        //Found Ids --  map of app id to all attributes found in DB
        "Hit": [],
        //Missed Ids -- apps not found in DB
        "Miss": [],
        //Ids that were unprocessed for any reason. These will get retried in next batch
        "Unprocessed": []
    };

    //Copy All ids, as we process the DynamoDB response
    let missedIds = ids.slice();

    //Format Hit Elements
    for (const item of response["Responses"][process.env.tableName]) {
        //Populate Hit field of result ==> { "Hit: [{ <app_id>: {<attribute2>: val, <attribute3>: val, ...}}]}
        let formattedItem = {};
        let currentId = item[process.env.primaryKeyName][process.env.primaryKeyType]

        formattedItem["app_id"] = currentId;
        formattedItem["features"] = {};

        Object.entries(item).forEach(([key, value]) => {
            if (key != process.env.primaryKeyName) {
                Object.entries(value).forEach(([subKey, subValue]) => {
                    formattedItem["features"][key] = subValue;
                });
            }
        });

        //This one was successful so we know it was not missed
        missedIds.splice(missedIds.indexOf(currentId), 1);

        //Add details to result object
        result["Hit"].push(formattedItem);
    }

    //Populate Miss field
    result["Miss"] = missedIds

    //Populate Unprocessed field (if needed)
    if (response["UnprocessedKeys"][process.env.tableName] != undefined) {

        for (const item of response["UnprocessedKeys"][process.env.tableName]["Keys"]) {
            result["Unprocessed"].push(item[process.env.primaryKeyName][process.env.primaryKeyType]);
        }
    }

    console.log(`formatted DynamoDB result:\n${JSON.stringify(result)}`);
    return result;
}

//Lambda Options
const lambdaFunctions = {
    "FetchStoreInfo": process.env.fetchStoreInfoFunctionName,
    "WriteToCache": process.env.writeToCacheFunctionName
}

const invokeLambda = async function (functionName, context, payload) {
    const params = {
        FunctionName: functionName,
        ClientContext: AWS.util.base64.encode(JSON.stringify(context)),
        //FetchStoreInfo needs to wait. WriteToCache does not need a response
        InvocationType: functionName == lambdaFunctions.FetchStoreInfo ? "RequestResponse" : "Event",
        LogType: "Tail",
        Payload: JSON.stringify(payload)
    }

    let response = await lambda.invoke(params).promise()
        .then(response => response)
        .catch(err => console.log(err));

    return response;
}


//Based on IDs formats a request payload to check with DynamoDB
const generateBatchGetItemParams = function (ids) {
    const params = {
        "RequestItems": {
            [process.env.tableName]: {
                "Keys": ids.map(id => {
                    return {
                        [process.env.primaryKeyName]: {
                            [process.env.primaryKeyType]: id
                        }
                    }
                })
            }
        }
    }

    return params;
}