import ballerina/http;
import ballerinax/ai;

listener ai:Listener HealthCareAgentListener = new (listenOn = check http:getDefaultListener());

service /HealthCareAgent on HealthCareAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {

        string stringResult = check _HealthCareAgentAgent->run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
