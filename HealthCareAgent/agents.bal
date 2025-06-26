import ballerinax/ai;

final ai:OpenAiProvider _AppointmentCoordinatorAgentModel = check new (openAIApiKey, "gpt-4o-mini");

final ai:Agent _AppointmentCoordinatorAgentAgent = check new (
    systemPrompt = {
        role: "Patient Support Agent",
        instructions: string `You are a smart AI healthcare assistant helping patients manage their appointments and prepare for visits effortlessly.

Your primary responsibilities include:

Appointment Scheduling & Rescheduling: Helping patients book, modify, and confirm appointments by checking availability via hospital EHR systems.

Automated Reminders: Sending proactive, personalized reminders through SMS or voice calls to keep patients informed about upcoming visits.

Pre-Appointment Guidance: Providing clear instructions and checklists before appointments to ensure patients come prepared (e.g., fasting requirements, documents to bring).

Live Assistance Routing: Connecting patients to live staff or care coordinators whenever further human help is needed or requested.

Guidelines:

Respond in a warm, clear, and professional tone, using simple language that's easy to understand.

Always verify patient identity securely before sharing or changing sensitive information.

Confirm appointment changes explicitly with the patient before finalizing any bookings or updates.

Provide concise, actionable options when offering new appointment slots or instructions.

Respect patient privacy and never provide medical advice or diagnoses. Refer patients to their healthcare providers for clinical questions.

Escalate to human staff promptly if the patient requests it or if complex situations arise.`
    },
    model = _AppointmentCoordinatorAgentModel,
    tools = [getPatientInfo, getPatientAppointments, checkAvailability, scheduleAppointment, rescheduleAppointment, cancelAppointment, getAppointmentDetails, listAllPatients]
);

// testGet patient information by patient ID
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testgetPatientInfo() returns string|error {
    return getPatientInfo("sample-patient-id");
}

// testGet all appointments for a specific patient
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testgetPatientAppointments() returns string|error {
    return getPatientAppointments("sample-patient-id");
}

// testCheck available appointment slots for a specific date
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testcheckAvailability() returns string|error {
    return checkAvailability("2025-06-30", "sample-practitioner-id");
}

// testSchedule a new appointment for a patient
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testscheduleAppointment() returns string|error {
    return scheduleAppointment("sample-patient-id", "sample-practitioner-id", 2025, 7, 1, 10, 0, 30, "General Checkup", "Routine visit", "Clinic A");
}

// testReschedule an existing appointment
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testrescheduleAppointment() returns string|error {
    return rescheduleAppointment("appointment-id-123", 2025, 7, 2, 11, 0, 30);
}

// testCancel an existing appointment
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testcancelAppointment() returns string|error {
    return cancelAppointment("appointment-id-123");
}

// testGet details of a specific appointment
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testgetAppointmentDetails() returns string|error {
    return getAppointmentDetails("appointment-id-123");
}

// testList all patients in the system (administrative function)
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function testlistAllPatients() returns string|error {
    return listAllPatients();
}