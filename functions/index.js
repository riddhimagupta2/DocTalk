const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Triggered on new appointment document creation in Firestore.
 * Sends "New Appointment Request" FCM push notification to the assigned doctor.
 */
exports.onAppointmentCreated = functions.firestore
  .document('appointments/{appointmentId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const doctorId = data.doctorId;
    const patientName = data.patientName || 'A patient';
    const date = data.date;
    const time = data.time;

    try {
      // Get Doctor's FCM Token from doctors collection
      const doctorDoc = await admin.firestore().collection('doctors').doc(doctorId).get();
      if (!doctorDoc.exists) {
        console.log(`Doctor ${doctorId} not found.`);
        return;
      }

      const fcmToken = doctorDoc.data().fcmToken;
      if (!fcmToken) {
        console.log(`No FCM Token registered for Doctor ${doctorId}.`);
        return;
      }

      const payload = {
        notification: {
          title: 'New Appointment Request 🩺',
          body: `${patientName} requested an appointment for ${date} at ${time}.`,
          sound: 'default',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          type: 'new_appointment',
          appointmentId: context.params.appointmentId,
        },
      };

      await admin.messaging().sendToDevice(fcmToken, payload);
      console.log(`Notification sent to doctor ${doctorId}`);
    } catch (error) {
      console.error('Error sending appointment notification:', error);
    }
  });

/**
 * Triggered when an appointment status is updated (Accepted, Rejected, Completed).
 * Sends status notification to the patient.
 */
exports.onAppointmentUpdated = functions.firestore
  .document('appointments/{appointmentId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger if status changed
    if (before.status === after.status) return;

    const patientId = after.patientId;
    const doctorName = after.doctorName || 'Doctor';
    const status = after.status;

    try {
      const userDoc = await admin.firestore().collection('users').doc(patientId).get();
      if (!userDoc.exists) return;

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) return;

      let title = 'Appointment Status Update 📅';
      let body = `Your appointment with Dr. ${doctorName} has been updated to ${status}.`;

      if (status === 'Accepted') {
        title = 'Appointment Accepted! 🎉';
        body = `Dr. ${doctorName} confirmed your appointment on ${after.date} at ${after.time}.`;
      } else if (status === 'Rejected') {
        title = 'Appointment Declined ⚠️';
        body = `Dr. ${doctorName} declined your request. Reason: ${after.rejectionReason || 'Schedule conflict'}.`;
      }

      const payload = {
        notification: {
          title: title,
          body: body,
          sound: 'default',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          type: 'appointment_status',
          appointmentId: context.params.appointmentId,
        },
      };

      await admin.messaging().sendToDevice(fcmToken, payload);
    } catch (error) {
      console.error('Error sending patient status notification:', error);
    }
  });
