import 'package:cloud_firestore/cloud_firestore.dart';

enum DocKeyPhotoMemoComment {
  authorID,
  commentID,
  commentText,
  createdAt,
  reportedBy,
  postID,
  createBy
  // id,
  // timestamp,
  // imageLabels,
  // sharedWith
}

class PhotoComment {
  late String authorID;

  late String commentID;

  late String commentText;
  late List<dynamic> reportedBy;


  late Timestamp createdAt;

  //String id;

  late String postID;
  late String createdBy;

  PhotoComment(
      {this.authorID = '',
      this.commentID = '',
      this.commentText = '',
      createdAt,
      this.createdBy = '',
        List<dynamic>? reportedBy,
      // this.id = '',
      this.postID = ''}){
    print("time is ${createdAt}");
    createdAt = createdAt ?? Timestamp.now();
    this.reportedBy = reportedBy == null ? [] : [...reportedBy];

  }

  PhotoComment.clone(PhotoComment photoComment) {
    authorID = photoComment.authorID;
    commentID = photoComment.commentID;
    commentText = photoComment.commentText;
    createdAt = photoComment.createdAt;
    reportedBy = [...photoComment.reportedBy];
    postID = photoComment.postID;
    createdBy = photoComment.createdBy;
  }

  void copyFrom(PhotoComment p) {
    authorID = p.authorID;
    commentID = p.commentID;
    commentText = p.commentText;
    createdAt = p.createdAt;
    postID = p.postID;
    createdBy = p.createdBy;
    reportedBy.clear();
    reportedBy.addAll(p.reportedBy);
  }

  static PhotoComment? fromFirestoreDoc(Map<String, dynamic> parsedJson) {
    return PhotoComment(
        authorID: parsedJson[DocKeyPhotoMemoComment.authorID.name] ?? '',
        commentID: parsedJson[DocKeyPhotoMemoComment.commentID.name] ?? '',
        commentText: parsedJson[DocKeyPhotoMemoComment.commentText.name] ?? '',
        createdAt: parsedJson[DocKeyPhotoMemoComment.createdAt.name] ?? Timestamp.now(),
        reportedBy: parsedJson[DocKeyPhotoMemoComment.reportedBy.name] ??=[],

        // id: parsedJson['id'] ?? '',
        postID: parsedJson[DocKeyPhotoMemoComment.postID.name] ?? '',
        createdBy: parsedJson[DocKeyPhotoMemoComment.createBy.name] ?? '');
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPhotoMemoComment.authorID.name: authorID,
      DocKeyPhotoMemoComment.commentID.name: commentID,
      DocKeyPhotoMemoComment.commentText.name: commentText,
      DocKeyPhotoMemoComment.createdAt.name: createdAt,
      DocKeyPhotoMemoComment.reportedBy.name: reportedBy,

      // 'id': this.id,  PK84NBPA1990003066927027
      DocKeyPhotoMemoComment.postID.name: postID,
      DocKeyPhotoMemoComment.createBy.name: createdBy
    };
  }
}
