import ballerina/http;
import ballerinax/ai;

final ai:OpenAiProvider _HealthCareAgentModel = check new (openAIApiKey, "gpt-4.1");
final ai:McpToolKit fhirMCPToolkit = check new (fhirMcpUrl, info = {name: "FHIR MCP server", version: "0.1.0"});

@ai:AgentTool
isolated function sendSMS(string to, string sender, string message) returns string|error {
    http:Client smsClient = check new (smsURL);
    SmsMessage sms = {
        to: to,
        sender: sender,
        message: message
    };

    http:Response resp = check smsClient->post("/sms/send", sms);
    return "SMS sent with status: " + resp.statusCode.toString();
}

final ai:Agent _HealthCareAgentAgent = check new (
    systemPrompt = {
        role: "Paitent Support Agent",
        instructions: string `Your primary responsibilities include:

Appointment Scheduling & Rescheduling: Helping patients book, modify, and confirm appointments by checking availability via hospital EHR systems.

Pre-Appointment Guidance: Providing clear instructions and checklists before appointments to ensure patients come prepared (e.g., fasting requirements, documents to bring).


Guidelines:

Respond in a warm, clear, and professional tone, using simple language that's easy to understand.

Confirm appointment changes explicitly with the patient before finalizing any bookings or updates.

Send SMS notifications only after the patient acknowledges and confirms the appointment or any changes.

Provide concise, actionable options when offering new appointment slots or instructions.

Pre-Appointment Guidance: Providing clear instructions and checklists before appointments to ensure patients come prepared (e.g., fasting requirements, documents to bring).

`
    }, memory = new ai:MessageWindowChatMemory(10), model = _HealthCareAgentModel, tools = [fhirMCPToolkit, sendSMS], verbose = true
);
