import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';
import '../models/formula.dart';
import '../models/question.dart';
import '../models/exam.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Documents
  Future<List<Document>> getDocumentsBySubject(String subject) async {
    final snapshot =
        await _firestore
            .collection('documents')
            .where('subject', isEqualTo: subject)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList();
  }

  Future<Document?> getDocumentById(String id) async {
    final doc = await _firestore.collection('documents').doc(id).get();
    return doc.exists ? Document.fromFirestore(doc) : null;
  }

  // Formulas
  Future<List<Formula>> getFormulasBySubject(String subject) async {
    final snapshot =
        await _firestore
            .collection('formulas')
            .where('subject', isEqualTo: subject)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => Formula.fromFirestore(doc)).toList();
  }

  Future<Formula?> getFormulaById(String id) async {
    final doc = await _firestore.collection('formulas').doc(id).get();
    return doc.exists ? Formula.fromFirestore(doc) : null;
  }

  // Questions
  Future<List<Question>> getQuestionsBySubject(String subject) async {
    final snapshot =
        await _firestore
            .collection('questions')
            .where('subject', isEqualTo: subject)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
  }

  Future<List<Question>> getQuestionsByIds(List<String> ids) async {
    final questions = <Question>[];
    for (final id in ids) {
      final doc = await _firestore.collection('questions').doc(id).get();
      if (doc.exists) {
        questions.add(Question.fromFirestore(doc));
      }
    }
    return questions;
  }

  // Exams
  Future<List<Exam>> getExamsBySubject(String subject) async {
    final snapshot =
        await _firestore
            .collection('exams')
            .where('subject', isEqualTo: subject)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => Exam.fromFirestore(doc)).toList();
  }

  Future<Exam?> getExamById(String id) async {
    final doc = await _firestore.collection('exams').doc(id).get();
    return doc.exists ? Exam.fromFirestore(doc) : null;
  }

  // Create operations
  Future<String> createDocument(Document document) async {
    final docRef = await _firestore
        .collection('documents')
        .add(document.toMap());
    return docRef.id;
  }

  Future<String> createFormula(Formula formula) async {
    final docRef = await _firestore.collection('formulas').add(formula.toMap());
    return docRef.id;
  }

  Future<String> createQuestion(Question question) async {
    final docRef = await _firestore
        .collection('questions')
        .add(question.toMap());
    return docRef.id;
  }

  Future<String> createExam(Exam exam) async {
    final docRef = await _firestore.collection('exams').add(exam.toMap());
    return docRef.id;
  }

  // Update operations
  Future<void> updateDocument(String id, Document document) async {
    await _firestore.collection('documents').doc(id).update(document.toMap());
  }

  Future<void> updateFormula(String id, Formula formula) async {
    await _firestore.collection('formulas').doc(id).update(formula.toMap());
  }

  Future<void> updateQuestion(String id, Question question) async {
    await _firestore.collection('questions').doc(id).update(question.toMap());
  }

  Future<void> updateExam(String id, Exam exam) async {
    await _firestore.collection('exams').doc(id).update(exam.toMap());
  }

  // Delete operations
  Future<void> deleteDocument(String id) async {
    await _firestore.collection('documents').doc(id).delete();
  }

  Future<void> deleteFormula(String id) async {
    await _firestore.collection('formulas').doc(id).delete();
  }

  Future<void> deleteQuestion(String id) async {
    await _firestore.collection('questions').doc(id).delete();
  }

  Future<void> deleteExam(String id) async {
    await _firestore.collection('exams').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final snapshot = await _firestore.collection('subjects').get();
    return snapshot.docs
        .map(
          (doc) => {
            'id': doc.id,
            'name': doc['name'],
            'description': doc['description'],
          },
        )
        .toList();
  }
}
