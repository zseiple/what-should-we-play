const AWS = require("aws-sdk");
AWS.config.update({ region: "us-east-2" });

const ddb = new AWS.DynamoDB({
    apiVersion: '2012-08-10',
    endpoint: process.env.dynamoEndpoint
});
/*
 * Expected Input: 
 * {
 *    app_id_features: [
 *    {
 *      app_id: <string>
 *      features: {
 *         <feature1>: <t/f>
 *         <feature2>: <t/f>
 *      }
 *    }]
 * }
 */


/* 
 * | writeToCache |
 * All this function does is write to dynamodb. It needs to be it's own lambda so it doesn't have to halt execution
*/
exports.handler = async function (event, context) {
    await ddb.batchWriteItem(generateBatchWriteParams(event.app_id_features)).promise()
        .then(writeResponse => { console.log(`Done Writing, heres the result:\n${writeResponse}`); });
}

const generateBatchWriteParams = function (app_id_features) {
    const params = {
        "RequestItems": {}
    };

    console.log(`app_id_features logged:\n${JSON.stringify(app_id_features)}`)

    const formattedFeatures = app_id_features.map(app_id_feature => {

        console.log(`App ID Feature:\n${JSON.stringify(app_id_feature)}`);
        let putReq = {
            "PutRequest": {}
        };

        //First Object for Item property of DynamoDB batch write request. This object gets the app id and assigns it.
        //The rest are determined by the "features" array app_id_feature.features
        const firstItemObj = {
            [process.env.primaryKeyName]: {
                [process.env.primaryKeyType]: app_id_feature.app_id
            }
        }

        //Populate the item field by reducing array into a new object
        putReq["PutRequest"]["Item"] = Object.entries(app_id_feature.features).reduce((accumulator, currentValue) => {
            accumulator[currentValue[0]] = { "BOOL": currentValue[1] }
            return accumulator;
        }, firstItemObj);

        return putReq;
    });


    params["RequestItems"][process.env.tableName] = formattedFeatures;

    console.log("Write Params Generated");

    return params;

}