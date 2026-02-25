import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Toggle Follow/Unfollow
  Future<void> toggleFollow(
      String currentUserEmail, String targetUserEmail) async {
    final userRef = _db.collection('users').doc(currentUserEmail);
    final targetRef = _db.collection('users').doc(targetUserEmail);

    // Check if already following
    final followingDoc =
        await userRef.collection('following').doc(targetUserEmail).get();
    final isFollowing = followingDoc.exists;

    WriteBatch batch = _db.batch();

    if (isFollowing) {
      // --- UNFOLLOW LOGIC ---

      // 1. Remove from 'following' subcollection
      batch.delete(userRef.collection('following').doc(targetUserEmail));

      // 2. Remove from 'followers' subcollection
      batch.delete(targetRef.collection('followers').doc(currentUserEmail));

      // 3. Decrement counts
      batch.update(userRef, {'followingCount': FieldValue.increment(-1)});
      batch.update(targetRef, {'followersCount': FieldValue.increment(-1)});
    } else {
      // --- FOLLOW LOGIC ---

      // 1. Add to 'following' subcollection (store basic info for listing)
      batch.set(userRef.collection('following').doc(targetUserEmail), {
        'email': targetUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Add to 'followers' subcollection
      batch.set(targetRef.collection('followers').doc(currentUserEmail), {
        'email': currentUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Increment counts
      batch.update(userRef, {'followingCount': FieldValue.increment(1)});
      batch.update(targetRef, {'followersCount': FieldValue.increment(1)});
    }

    await batch.commit();
  }

  // Check if currently following (for UI button state)
  Stream<bool> isFollowingStream(
      String currentUserEmail, String targetUserEmail) {
    return _db
        .collection('users')
        .doc(currentUserEmail)
        .collection('following')
        .doc(targetUserEmail)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
}
