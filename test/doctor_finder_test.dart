import 'package:flutter_test/flutter_test.dart';
import 'package:doctalk/models/doctor_model.dart';

void main() {
  group('DoctorModel Specialization Inference Tests', () {
    test('Infers Dermatologist for skin and derma clinics', () {
      expect(
        DoctorModel.inferSpecialization(name: 'Dr. Jindal Skin Clinic'),
        'Dermatologist',
      );
      expect(
        DoctorModel.inferSpecialization(name: 'Cosmetic & Derma Care'),
        'Dermatologist',
      );
    });

    test('Infers Ophthalmologist for eye hospitals', () {
      expect(
        DoctorModel.inferSpecialization(name: 'PC Sharma Eye Hospital'),
        'Ophthalmologist',
      );
      expect(
        DoctorModel.inferSpecialization(name: 'Drishti Netra Kendra'),
        'Ophthalmologist',
      );
    });

    test('Infers Dentist for dental clinics', () {
      expect(
        DoctorModel.inferSpecialization(name: 'Smile Dental Care'),
        'Dentist',
      );
    });

    test('Infers Cardiologist for heart clinics', () {
      expect(
        DoctorModel.inferSpecialization(name: 'Advance Heart & Cardio Center'),
        'Cardiologist',
      );
    });

    test('Infers Pediatrician for child care', () {
      expect(
        DoctorModel.inferSpecialization(name: 'Shishu Child Clinic'),
        'Pediatrician',
      );
    });

    test('Infers Orthopedic for bone and joint clinics', () {
      expect(
        DoctorModel.inferSpecialization(name: 'Bone & Joint Fracture Clinic'),
        'Orthopedic',
      );
    });

    test('Infers Gynecologist for maternity hospitals', () {
      expect(
        DoctorModel.inferSpecialization(name: 'Matru Maternity & Women Hospital'),
        'Gynecologist',
      );
    });

    test('Defaults to Multi-Speciality Hospital or General Physician', () {
      expect(
        DoctorModel.inferSpecialization(name: 'KD Hospital', amenity: 'hospital'),
        'Multi-Speciality Hospital',
      );
      expect(
        DoctorModel.inferSpecialization(name: 'Ambala Medical Center'),
        'General Physician',
      );
    });
  });

  group('DoctorModel Distance Formatting Tests', () {
    test('Formats distances properly', () {
      final doc1 = DoctorModel(
        placeId: '1',
        name: 'Dr. A',
        specialization: 'General Physician',
        address: 'Ambala',
        latitude: 30.378,
        longitude: 76.776,
        distanceKm: 0.8,
      );
      expect(doc1.distanceFormatted, '0.8 km away');

      final doc2 = DoctorModel(
        placeId: '2',
        name: 'Dr. B',
        specialization: 'Cardiologist',
        address: 'Ambala Cantt',
        latitude: 30.337,
        longitude: 76.860,
        distanceKm: 2.3,
      );
      expect(doc2.distanceFormatted, '2.3 km away');
    });

    test('Handles missing or zero coordinates gracefully', () {
      final doc = DoctorModel(
        placeId: '3',
        name: 'Dr. C',
        specialization: 'Dermatologist',
        address: 'Unknown',
        latitude: 0.0,
        longitude: 0.0,
        distanceKm: 0.0,
      );
      expect(doc.distanceFormatted, 'Distance unavailable');
    });
  });

  group('DoctorModel Sorting Tests', () {
    test('Sorts doctors by nearest distance first', () {
      final docNear = DoctorModel(
        placeId: '1',
        name: 'KD Hospital Specialist',
        specialization: 'Multi-Speciality Hospital',
        address: 'Near KD Hospital, Ambala',
        latitude: 30.379,
        longitude: 76.776,
        distanceKm: 0.5,
      );

      final docMid = DoctorModel(
        placeId: '2',
        name: 'Dr. Jindal Skin Clinic',
        specialization: 'Dermatologist',
        address: 'Ambala City',
        latitude: 30.340,
        longitude: 76.842,
        distanceKm: 2.4,
      );

      final docFar = DoctorModel(
        placeId: '3',
        name: 'Chandigarh Specialty',
        specialization: 'Cardiologist',
        address: 'Chandigarh',
        latitude: 30.733,
        longitude: 76.779,
        distanceKm: 42.0,
      );

      final list = [docFar, docNear, docMid];
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      expect(list.first.name, 'KD Hospital Specialist');
      expect(list[1].name, 'Dr. Jindal Skin Clinic');
      expect(list.last.name, 'Chandigarh Specialty');
      expect(list.first.distanceKm, 0.5);
    });
  });
}
