import ballerina/http;
import ballerina/lang.runtime;

// Mock data storage
map<Patient> mockPatients = {
    "patient-001": {
        id: "patient-001",
        name: "John Doe",
        gender: "male",
        birthDate: "1985-06-15",
        phone: "+1-555-0123",
        email: "john.doe@email.com",
        address: {
            line1: "123 Main St",
            city: "Boston",
            state: "MA",
            postalCode: "02101",
            country: "USA"
        }
    },
    "patient-002": {
        id: "patient-002",
        name: "Jane Smith",
        gender: "female",
        birthDate: "1990-03-22",
        phone: "+1-555-0456",
        email: "jane.smith@email.com",
        address: {
            line1: "456 Oak Ave",
            city: "Boston",
            state: "MA",
            postalCode: "02102",
            country: "USA"
        }
    }
};

map<Appointment> mockAppointments = {
    "appt-001": {
        id: "appt-001",
        status: "scheduled",
        patientId: "patient-001",
        practitionerId: "dr-smith",
        startTime: {year: 2024, month: 12, day: 20, hour: 10, minute: 0},
        endTime: {year: 2024, month: 12, day: 20, hour: 11, minute: 0},
        appointmentType: "consultation",
        description: "Regular checkup",
        location: "Room 101"
    }
};

// Mock EHR Service
listener http:Listener mockEhrListener = new (8081);

service /fhir on mockEhrListener {
    
    // Get all patients
    resource function get Patient() returns Bundle|ErrorResponse {
        runtime:sleep(0.1); // Simulate network delay
        
        Patient[] patientList = mockPatients.toArray();
        return {
            resourceType: "Bundle",
            total: patientList.length(),
            entry: patientList
        };
    }
    
    // Get patient by ID
    resource function get Patient/[string patientId]() returns Patient|ErrorResponse {
        runtime:sleep(0.1);
        
        if mockPatients.hasKey(patientId) {
            Patient patient = mockPatients.get(patientId);
            return patient;
        }
        
        return {
            message: "Patient not found",
            code: 404
        };
    }
    
    // Get all appointments or filter by patient ID (using query param)
    resource function get Appointment(@http:Query string? patientId) returns Bundle|ErrorResponse {
        runtime:sleep(0.1);

        Appointment[] appointmentList = mockAppointments.toArray();
        if patientId is string {
            appointmentList = appointmentList.filter(a => a.patientId == patientId);
        }
        return {
            resourceType: "Bundle",
            total: appointmentList.length(),
            entry: appointmentList
        };
    }
    
    // Get appointment by ID
    resource function get Appointment/[string appointmentId]() returns Appointment|ErrorResponse {
        runtime:sleep(0.1);
        
        if mockAppointments.hasKey(appointmentId) {
            Appointment appointment = mockAppointments.get(appointmentId);
            return appointment;
        }
        
        return {
            message: "Appointment not found",
            code: 404
        };
    }
    
    // Create new appointment
    resource function post Appointment(@http:Payload CreateAppointmentRequest request) returns Appointment|ErrorResponse {
        runtime:sleep(0.2);
        
        // Validate patient exists
        if !mockPatients.hasKey(request.patientId) {
            return {
                message: "Patient not found",
                code: 400
            };
        }
        
        // Generate new appointment ID
        string appointmentId = "appt-" + (mockAppointments.length() + 1).toString().substring(startIndex = 0);
        
        Appointment newAppointment = {
            id: appointmentId,
            status: "scheduled",
            patientId: request.patientId,
            practitionerId: request.practitionerId,
            startTime: request.startTime,
            endTime: request.endTime,
            appointmentType: request.appointmentType,
            description: request.description,
            location: request.location
        };
        
        mockAppointments[appointmentId] = newAppointment;
        return newAppointment;
    }
    
    // Update appointment
    resource function put Appointment/[string appointmentId](@http:Payload UpdateAppointmentRequest request) returns Appointment|ErrorResponse {
        runtime:sleep(0.2);
        
        if !mockAppointments.hasKey(appointmentId) {
            return {
                message: "Appointment not found",
                code: 404
            };
        }
        
        Appointment existingAppointment = mockAppointments.get(appointmentId);
        
        // Update fields if provided
        Appointment updatedAppointment = {
            id: existingAppointment.id,
            status: request.status ?: existingAppointment.status,
            patientId: existingAppointment.patientId,
            practitionerId: existingAppointment.practitionerId,
            startTime: request.startTime ?: existingAppointment.startTime,
            endTime: request.endTime ?: existingAppointment.endTime,
            appointmentType: request.appointmentType ?: existingAppointment.appointmentType,
            description: request.description ?: existingAppointment.description,
            location: request.location ?: existingAppointment.location
        };
        
        mockAppointments[appointmentId] = updatedAppointment;
        return updatedAppointment;
    }
    
    // Cancel appointment
    resource function delete Appointment/[string appointmentId]() returns http:Ok|ErrorResponse {
        runtime:sleep(0.1);
        
        if !mockAppointments.hasKey(appointmentId) {
            return {
                message: "Appointment not found",
                code: 404
            };
        }
        
        Appointment existingAppointment = mockAppointments.get(appointmentId);
        Appointment cancelledAppointment = existingAppointment.clone();
        cancelledAppointment.status = "cancelled";
        
        mockAppointments[appointmentId] = cancelledAppointment;
        return http:OK;
    }
    
    // Get available slots
    resource function get Appointment/availability(string date, string? practitionerId) returns AppointmentSlot[]|ErrorResponse {
        runtime:sleep(0.1);
        
        // Mock available slots for the requested date
        AppointmentSlot[] availableSlots = [
            {
                startTime: {year: 2024, month: 12, day: 20, hour: 9, minute: 0},
                endTime: {year: 2024, month: 12, day: 20, hour: 10, minute: 0},
                available: true,
                practitionerId: practitionerId ?: "dr-smith"
            },
            {
                startTime: {year: 2024, month: 12, day: 20, hour: 11, minute: 0},
                endTime: {year: 2024, month: 12, day: 20, hour: 12, minute: 0},
                available: true,
                practitionerId: practitionerId ?: "dr-smith"
            },
            {
                startTime: {year: 2024, month: 12, day: 20, hour: 14, minute: 0},
                endTime: {year: 2024, month: 12, day: 20, hour: 15, minute: 0},
                available: true,
                practitionerId: practitionerId ?: "dr-jones"
            }
        ];
        
        return availableSlots;
    }
}