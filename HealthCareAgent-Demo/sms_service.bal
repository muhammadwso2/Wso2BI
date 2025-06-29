import ballerina/http;
import ballerina/log;

service /sms on new http:Listener(8082) {

    // Simulate receiving an SMS via webhook
    resource function post webhook(@http:Payload SmsMessage msg) returns string {
        log:printInfo("📤 SMS SENT");
        log:printInfo("To     : " + msg.to);
        log:printInfo("From   : " + msg.sender);
        log:printInfo("Message: \"" + msg.message + "\"");
        return "SMS received successfully";
    }

    // Optional: Simulate sending an SMS
    resource function post send(@http:Payload SmsMessage msg) returns string {
        log:printInfo("📤 Sending SMS to " + msg.to + ": " + msg.message);

        // Simulate webhook trigger after sending
        SmsMessage simulatedInbound = {
            to: msg.to,
            sender: msg.sender,
            message: msg.message
        };

        // Local HTTP client to call the webhook
        http:Client|error webhookClientResult = new (smsURL);
        if webhookClientResult is http:Client {
            http:Response|error responseResult = webhookClientResult->post("/sms/webhook", simulatedInbound);
            if responseResult is http:Response {
                return "SMS sent and webhook triggered";
            } else {
                log:printError("Failed to trigger webhook: " + responseResult.toString());
                return "SMS sent but failed to trigger webhook";
            }
        } else {
            log:printError("Failed to create webhook client: " + webhookClientResult.toString());
            return "SMS sent but failed to trigger webhook";
        }
    }
}