import ballerina/http;
import ballerinax/ai;

listener ai:Listener AppointmentCoordinatorAgentListener = new (listenOn = check http:getDefaultListener());

service /AppointmentCoordinatorAgent on AppointmentCoordinatorAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {

        string stringResult = check _AppointmentCoordinatorAgentAgent->run(request.message, request.sessionId);
        return {message: stringResult};
    }
}