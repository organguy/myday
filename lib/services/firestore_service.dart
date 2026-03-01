import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dday.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 고정 userId (로그인 없이 단일 유저 사용)
  static const String _userId = 'default_user';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users').doc(_userId).collection('ddays');

  /// 디데이 목록 실시간 스트림 (생성일 최신순)
  Stream<List<DDay>> getDDays() {
    return _collection
        .orderBy('targetDate', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DDay.fromMap(doc.data()))
            .toList());
  }

  /// 디데이 추가
  Future<void> addDDay(DDay dday) async {
    await _collection.doc(dday.id).set(dday.toMap());
  }

  /// 디데이 수정
  Future<void> updateDDay(DDay dday) async {
    await _collection.doc(dday.id).update(dday.toMap());
  }

  /// 디데이 삭제
  Future<void> deleteDDay(String id) async {
    await _collection.doc(id).delete();
  }
}
