import ballerina/http;

// EHR Connector Configuration
public type EhrConnectorConfig record {|
    string baseUrl = "http://localhost:8081/fhir";
    http:ClientConfiguration httpConfig?;
|};

// EHR Connector Client
public isolated client class EhrConnector {
    private final http:Client httpClient;
    
    public isolated function init(EhrConnectorConfig config = {}) returns error? {
        self.httpClient = check new (url = config.baseUrl, config = config.httpConfig ?: {});
    }
    
    // Patient operations
    public isolated function getPatients() returns Patient[]|error {
        Bundle response = check self.httpClient->get(path = "/Patient");
        Patient[] patients = <Patient[]>response.entry;
        return patients;
    }
    
    public isolated function getPatient(string patientId) returns Patient|error {
        Patient patient = check self.httpClient->get(path = "/Patient/" + patientId);
        return patient;
    }
    
    // Appointment operations
    public isolated function getAppointments() returns Appointment[]|error {
        Bundle response = check self.httpClient->get(path = "/Appointment");
        Appointment[] appointments = <Appointment[]>response.entry;
        return appointments;
    }
    
    public isolated function getPatientAppointments(string patientId) returns Appointment[]|error {
        Bundle response = check self.httpClient->get(path = "/Appointment?patientId=" + patientId);
        Appointment[] appointments = <Appointment[]>response.entry;
        return appointments;
    }
    
    public isolated function getAppointment(string appointmentId) returns Appointment|error {
        Appointment appointment = check self.httpClient->get(path = "/Appointment/" + appointmentId);
        return appointment;
    }
    
    public isolated function createAppointment(CreateAppointmentRequest request) returns Appointment|error {
        Appointment appointment = check self.httpClient->post(path = "/Appointment", message = request);
        return appointment;
    }
    
    public isolated function updateAppointment(string appointmentId, UpdateAppointmentRequest request) returns Appointment|error {
        Appointment appointment = check self.httpClient->put(path = "/Appointment/" + appointmentId, message = request);
        return appointment;
    }
    
    public isolated function cancelAppointment(string appointmentId) returns error? {
        http:Response response = check self.httpClient->delete(path = "/Appointment/" + appointmentId);
        if response.statusCode != 200 {
            return error("Failed to cancel appointment");
        }
    }
    
    public isolated function getAvailableSlots(string date, string? practitionerId = ()) returns AppointmentSlot[]|error {
        string path = "/Appointment/availability?date=" + date;
        if practitionerId is string {
            path = path + "&practitionerId=" + practitionerId;
        }
        
        AppointmentSlot[] slots = check self.httpClient->get(path = path);
        return slots;
    }
}