import 'package:attendance_app/models/attendance_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get attendance records for a user (real-time stream)
  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) {
    return _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AttendanceRecord.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  // get today's attendace record (real-time stream)
  Stream<AttendanceRecord?> getTodayRecordStream(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_time', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          // filter today's record on client side
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final checkInTime = DateTime.parse(data['check_in_time'] as String);

            if (checkInTime.isAfter(startOfDay) && checkInTime.isBefore(endOfDay)) {
              return AttendanceRecord.fromJson({...data, 'id': doc.id});
            }
          }
          return null;
        });
  }

  // get today's attendance record (one-time fetch)
  Future<AttendanceRecord?> getTodayRecord(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

      if (querySnapshot.docs.isEmpty) return null;

      return AttendanceRecord.fromJson(
        {...querySnapshot.docs.first.data(), 'id': querySnapshot.docs.first.id}
      );

  }

  // create new attendace record
  Future<String> createAttendanceRecord(AttendanceRecord record) async {
    final docRef = await _firestore.collection('attendance').add(record.toJson());
    return docRef.id;
  }

  // update existing attendance record
  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await _firestore
        .collection('attendance')
        .doc(record.id)
        .update(record.toJson());
  }

  // create or update attendance record
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    if (record.id == '1' || record.id.isEmpty) {
      // new record for creating auto generated ID
      await createAttendanceRecord(record);
    } else {
      // update existing record
      await updateAttendanceRecord(record);
    }
  }
}