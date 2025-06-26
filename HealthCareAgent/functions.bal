import ballerina/time;
import ballerinax/ai;

// Tool function to get patient information
@ai:AgentTool
@display {label: "Get Patient Info", iconPath: ""}
public isolated function getPatientInfo(string patientId) returns string|error {
    Patient|error patientResult = ehrConnector.getPatient(patientId);
    
    if patientResult is error {
        return "Patient not found or error occurred: " + patientResult.message();
    }
    
    Patient patient = patientResult;
    string patientInfo = string `Patient Information:
- ID: ${patient.id}
- Name: ${patient.name}
- Gender: ${patient.gender ?: "Not specified"}
- Birth Date: ${patient.birthDate ?: "Not specified"}
- Phone: ${patient.phone ?: "Not specified"}
- Email: ${patient.email ?: "Not specified"}`;
    
    if patient.address is Address {
        Address address = <Address>patient.address;
        patientInfo += string `
- Address: ${address.line1 ?: ""}, ${address.city ?: ""}, ${address.state ?: ""} ${address.postalCode ?: ""}`;
    }
    
    return patientInfo;
}

// Tool function to get patient appointments
@ai:AgentTool
@display {label: "Get Patient Appointments", iconPath: ""}
public isolated function getPatientAppointments(string patientId) returns string|error {
    Appointment[]|error appointmentsResult = ehrConnector.getPatientAppointments(patientId);
    
    if appointmentsResult is error {
        return "Error retrieving appointments: " + appointmentsResult.message();
    }
    
    Appointment[] appointments = appointmentsResult;
    
    if appointments.length() == 0 {
        return "No appointments found for this patient.";
    }
    
    string appointmentsList = "Patient Appointments:\n";
    foreach Appointment appointment in appointments {
        time:Civil startTime = appointment.startTime;
        time:Civil endTime = appointment.endTime;
        
        appointmentsList += string `
- Appointment ID: ${appointment.id}
- Status: ${appointment.status}
- Date: ${startTime.year}-${startTime.month}-${startTime.day}
- Time: ${startTime.hour}:${startTime.minute.toString().padStart(2, "0")} - ${endTime.hour}:${endTime.minute.toString().padStart(2, "0")}
- Type: ${appointment.appointmentType ?: "Not specified"}
- Description: ${appointment.description ?: "Not specified"}
- Location: ${appointment.location ?: "Not specified"}
- Practitioner: ${appointment.practitionerId ?: "Not specified"}`;
    }
    
    return appointmentsList;
}

// Tool function to check available appointment slots
@ai:AgentTool
@display {label: "Check Availability", iconPath: ""}
public isolated function checkAvailability(string date, string? practitionerId = ()) returns string|error {
    AppointmentSlot[]|error slotsResult = ehrConnector.getAvailableSlots(date, practitionerId);
    
    if slotsResult is error {
        return "Error checking availability: " + slotsResult.message();
    }
    
    AppointmentSlot[] slots = slotsResult;
    
    if slots.length() == 0 {
        return "No available slots found for the requested date.";
    }
    
    string availabilityInfo = string `Available appointment slots for ${date}:\n`;
    foreach AppointmentSlot slot in slots {
        if slot.available {
            time:Civil startTime = slot.startTime;
            time:Civil endTime = slot.endTime;
            
            availabilityInfo += string `
- Time: ${startTime.hour}:${startTime.minute.toString().padStart(2, "0")} - ${endTime.hour}:${endTime.minute.toString().padStart(2, "0")}
- Practitioner: ${slot.practitionerId ?: "Not specified"}`;
        }
    }
    
    return availabilityInfo;
}

// Tool function to schedule a new appointment
@ai:AgentTool
@display {label: "Schedule Appointment", iconPath: ""}
public isolated function scheduleAppointment(string patientId, string practitionerId, int year, int month, int day, int hour, int minute, int durationMinutes, string appointmentType, string description, string location) returns string|error {
    time:Civil startTime = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    };
    
    time:Civil endTime = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute + durationMinutes
    };
    
    // Handle hour overflow if minutes exceed 60
    if endTime.minute >= 60 {
        endTime.hour = endTime.hour + (endTime.minute / 60);
        endTime.minute = endTime.minute % 60;
    }
    
    CreateAppointmentRequest request = {
        patientId: patientId,
        practitionerId: practitionerId,
        startTime: startTime,
        endTime: endTime,
        appointmentType: appointmentType,
        description: description,
        location: location
    };
    
    Appointment|error appointmentResult = ehrConnector.createAppointment(request);
    
    if appointmentResult is error {
        return "Error scheduling appointment: " + appointmentResult.message();
    }
    
    Appointment appointment = appointmentResult;
    time:Civil appointmentStart = appointment.startTime;
    time:Civil appointmentEnd = appointment.endTime;
    
    return string `Appointment successfully scheduled!
- Appointment ID: ${appointment.id}
- Patient ID: ${appointment.patientId}
- Date: ${appointmentStart.year}-${appointmentStart.month}-${appointmentStart.day}
- Time: ${appointmentStart.hour}:${appointmentStart.minute.toString().padStart(2, "0")} - ${appointmentEnd.hour}:${appointmentEnd.minute.toString().padStart(2, "0")}
- Type: ${appointment.appointmentType ?: "Not specified"}
- Description: ${appointment.description ?: "Not specified"}
- Location: ${appointment.location ?: "Not specified"}
- Practitioner: ${appointment.practitionerId ?: "Not specified"}`;
}

// Tool function to reschedule an existing appointment
@ai:AgentTool
@display {label: "Reschedule Appointment", iconPath: ""}
public isolated function rescheduleAppointment(string appointmentId, int year, int month, int day, int hour, int minute, int durationMinutes) returns string|error {
    time:Civil newStartTime = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    };
    
    time:Civil newEndTime = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute + durationMinutes
    };
    
    // Handle hour overflow if minutes exceed 60
    if newEndTime.minute >= 60 {
        newEndTime.hour = newEndTime.hour + (newEndTime.minute / 60);
        newEndTime.minute = newEndTime.minute % 60;
    }
    
    UpdateAppointmentRequest request = {
        startTime: newStartTime,
        endTime: newEndTime
    };
    
    Appointment|error appointmentResult = ehrConnector.updateAppointment(appointmentId, request);
    
    if appointmentResult is error {
        return "Error rescheduling appointment: " + appointmentResult.message();
    }
    
    Appointment appointment = appointmentResult;
    time:Civil appointmentStart = appointment.startTime;
    time:Civil appointmentEnd = appointment.endTime;
    
    return string `Appointment successfully rescheduled!
- Appointment ID: ${appointment.id}
- New Date: ${appointmentStart.year}-${appointmentStart.month}-${appointmentStart.day}
- New Time: ${appointmentStart.hour}:${appointmentStart.minute.toString().padStart(2, "0")} - ${appointmentEnd.hour}:${appointmentEnd.minute.toString().padStart(2, "0")}
- Status: ${appointment.status}`;
}

// Tool function to cancel an appointment
@ai:AgentTool
@display {label: "Cancel Appointment", iconPath: ""}
public isolated function cancelAppointment(string appointmentId) returns string|error {
    error? cancelResult = ehrConnector.cancelAppointment(appointmentId);
    
    if cancelResult is error {
        return "Error cancelling appointment: " + cancelResult.message();
    }
    
    return string `Appointment ${appointmentId} has been successfully cancelled.`;
}

// Tool function to get appointment details
@ai:AgentTool
@display {label: "Get Appointment Details", iconPath: ""}
public isolated function getAppointmentDetails(string appointmentId) returns string|error {
    Appointment|error appointmentResult = ehrConnector.getAppointment(appointmentId);
    
    if appointmentResult is error {
        return "Appointment not found or error occurred: " + appointmentResult.message();
    }
    
    Appointment appointment = appointmentResult;
    time:Civil startTime = appointment.startTime;
    time:Civil endTime = appointment.endTime;
    
    return string `Appointment Details:
- ID: ${appointment.id}
- Status: ${appointment.status}
- Patient ID: ${appointment.patientId}
- Date: ${startTime.year}-${startTime.month}-${startTime.day}
- Time: ${startTime.hour}:${startTime.minute.toString().padStart(2, "0")} - ${endTime.hour}:${endTime.minute.toString().padStart(2, "0")}
- Type: ${appointment.appointmentType ?: "Not specified"}
- Description: ${appointment.description ?: "Not specified"}
- Location: ${appointment.location ?: "Not specified"}
- Practitioner: ${appointment.practitionerId ?: "Not specified"}`;
}

// Tool function to list all patients (for administrative purposes)
@ai:AgentTool
@display {label: "List All Patients", iconPath: ""}
public isolated function listAllPatients() returns string|error {
    Patient[]|error patientsResult = ehrConnector.getPatients();
    
    if patientsResult is error {
        return "Error retrieving patients: " + patientsResult.message();
    }
    
    Patient[] patients = patientsResult;
    
    if patients.length() == 0 {
        return "No patients found in the system.";
    }
    
    string patientsList = "All Patients:\n";
    foreach Patient patient in patients {
        patientsList += string `
- ID: ${patient.id}, Name: ${patient.name}, Phone: ${patient.phone ?: "Not specified"}`;
    }
    
    return patientsList;
}