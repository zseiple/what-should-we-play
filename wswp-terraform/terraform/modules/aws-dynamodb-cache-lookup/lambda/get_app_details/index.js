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
*/

/*
 * This function handles checking the DynamoDB instance for requested app_ids and pulls any information on that app.
 * If the app id is not present in the DB, this function will call another lambda function (fetchStoreInfo) to fetch the info from the Steam
 * Store page. When that function returns the info from the missing app ids, this function will also handle the inserts to the table.
 */
exports.handler = async function (event, context) {
    console.log("EVENT: \n" + JSON.stringify(event, null, 2));

    const MAX_ITERATIONS = 10;
    const BATCH_SIZE = 100;
    let batch = [];

    //Copy input array
    let requestedAppIds = event.app_ids.slice();

    let foundIds = [], missedIds = [];
    let ongoingPromises = [];

    let currentIteration = 0;
    //Continue while there are still batches
    while (requestedAppIds.length > 0 && currentIteration < MAX_ITERATIONS) {
        //Split into batches
        batch = requestedAppIds.splice(0, BATCH_SIZE);

        let batchPromise = fetchAppDetails(batch)
            .then(response => {
                //Add Found Ids to collection
                response["Hit"].forEach(appDetail => {
                    let id, clone = { ...appDetail };
                    clone[id = Object.keys(appDetail)[0]] = { ...appDetail[id] }
                    foundIds.push(clone);

                    //Add Missed Ids to collection, once loop completes these will be added into table
                    missedIds = missedIds.concat(response["Miss"]);

                    //Add Unprocessed Ids back into requestedAppIds to get reprocessed
                    requestedAppIds = requestedAppIds.concat(response["Unprocessed"]);
                });
            })
            .catch(e => console.log(`Error in requesting from cache: ${e}`));

        ongoingPromises.push(batchPromise);

    }

    if (currentIteration >= MAX_ITERATIONS)
        console.log("[GetAppDetails] Maximum Iterations Reached");

    //Batches Finished, now missed ID info need to be fetched. Missed IDs must be passed to fetchStoreInfo lambda function
    return Promise.all(ongoingPromises)
        .then(() => { //
            console.log(`Missed Ids that need requested to Lambda: ${missedIds.join(',')}`);
            return invokeLambda(context, { "app_ids": missedIds });
        })
        .then(response => {
            console.log("[GetAppDetails] Returned Response: \n" + response.Payload);
            return response;
        })
        .catch(e => {
            console.log(`Some error: ${e}`);
        });


    //let response = await invokeLambda(context, missedIds);
}

//Sends the dynamoDB request and transforms response into a simple map
const fetchAppDetails = async function (ids) {
    let response = await ddb.batchGetItem(generateBatchGetItemParams(ids)).promise()
        .then(data => data)
        .catch(error => { console.log(error); });
    //{Responses: [<TABLENAME> : { <ATTRIBUTENAME> : {S: string}, <ATTRIBUTENAME2>: {}}]}

    console.log("DynamoDB Response \n" + JSON.stringify(response, null, 2));

    let result = {
        //Found Ids --  map of app id to all attributes found in DB
        "Hit": [{}],
        //Missed Ids -- apps not found in DB
        "Miss": [],
        //Ids that were unprocessed for any reason. These will get reprocessed
        "Unprocessed": []
    };

    for (const item of response["Responses"][process.env.tableName]) {
        //Populate Hit field of result ==> { "Hit: [{ <app_id>: {<attribute2>: val, <attribute3>: val, ...}}]}
        //result["Hit"][item[process.env.primaryKeyName][process.env.primaryKeyType]] = {};
        let formattedItem = {};
        formattedItem[item[process.env.primaryKeyName][process.env.primaryKeyType]] = {};

        Object.entries(item).forEach(([key, value]) => {
            if (key != process.env.primaryKeyName) {
                Object.entries(value).forEach(([subKey, subValue]) => {
                    formattedItem[item[process.env.primaryKeyName][process.env.primaryKeyType]][key] = subValue;
                });
            }
        });

        result["Hit"].push(formattedItem);
    }

    //Populate Miss field
    result["Miss"] = ids.filter(id => !result["Hit"].hasOwnProperty(id));

    //Populate Unprocessed field (if needed)
    if (response["UnprocessedKeys"][process.env.tableName] != undefined) {

        for (const item of response["UnprocessedKeys"][process.env.tableName]["Keys"]) {
            result["Unprocessed"].push(item[process.env.primaryKeyName][process.env.primaryKeyType]);
        }
    }

    return result;
}

const invokeLambda = async function (context, payload) {
    const params = {
        FunctionName: process.env.helperLambdaFunctionName,
        ClientContext: AWS.util.base64.encode(JSON.stringify(context)),
        InvocationType: "RequestResponse",
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