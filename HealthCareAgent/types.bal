import ballerina/time;

// FHIR-like resource types
public type Patient record {|
    string id;
    string name;
    string gender?;
    string birthDate?;
    string phone?;
    string email?;
    Address address?;
|};

public type Address record {|
    string line1?;
    string city?;
    string state?;
    string postalCode?;
    string country?;
|};

public type Appointment record {|
    string id;
    string status; // scheduled, confirmed, cancelled, completed
    string patientId;
    string practitionerId?;
    time:Civil startTime;
    time:Civil endTime;
    string appointmentType?;
    string description?;
    string location?;
|};

public type AppointmentSlot record {|
    time:Civil startTime;
    time:Civil endTime;
    boolean available;
    string practitionerId?;
|};

// Request/Response types
public type CreateAppointmentRequest record {|
    string patientId;
    string practitionerId?;
    time:Civil startTime;
    time:Civil endTime;
    string appointmentType?;
    string description?;
    string location?;
|};

public type UpdateAppointmentRequest record {|
    string status?;
    time:Civil startTime?;
    time:Civil endTime?;
    string appointmentType?;
    string description?;
    string location?;
|};

public type AvailabilityRequest record {|
    string practitionerId?;
    string date; // YYYY-MM-DD format
|};

// Bundle type for FHIR-like responses
public type Bundle record {|
    string resourceType = "Bundle";
    int total;
    Patient[]|Appointment[] entry;
|};

// Error response type
public type ErrorResponse record {|
    string message;
    int code;
|};