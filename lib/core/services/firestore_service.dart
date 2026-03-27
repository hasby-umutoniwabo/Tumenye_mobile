import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/module_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_result_model.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Modules ────────────────────────────────────────────────────────────────

  Stream<List<ModuleModel>> getModules() => _db
      .collection('modules')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(ModuleModel.fromFirestore).toList());

  Future<ModuleModel?> getModule(String moduleId) async {
    final doc = await _db.collection('modules').doc(moduleId).get();
    if (!doc.exists) return null;
    return ModuleModel.fromFirestore(doc);
  }

  // ─── Lessons ────────────────────────────────────────────────────────────────

  Future<List<LessonModel>> getLessonsForModule(String moduleId) async {
    final snap = await _db
        .collection('lessons')
        .where('moduleId', isEqualTo: moduleId)
        .orderBy('order')
        .get();
    return snap.docs.map(LessonModel.fromFirestore).toList();
  }

  Stream<List<LessonModel>> streamLessonsForModule(String moduleId) => _db
      .collection('lessons')
      .where('moduleId', isEqualTo: moduleId)
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(LessonModel.fromFirestore).toList());

  // ─── Quiz ────────────────────────────────────────────────────────────────────

  Future<QuizModel?> getQuizForLesson(String lessonId) async {
    final doc = await _db.collection('quizzes').doc(lessonId).get();
    if (!doc.exists) return null;
    return QuizModel.fromFirestore(doc);
  }

  // ─── Progress ────────────────────────────────────────────────────────────────

  Stream<List<ModuleProgress>> getUserProgress(String userId) => _db
      .collection('progress')
      .doc(userId)
      .collection('modules')
      .snapshots()
      .map((s) => s.docs
          .map((doc) => ModuleProgress.fromFirestore(doc.id, doc))
          .toList());

  Stream<ModuleProgress?> getModuleProgress(String userId, String moduleId) =>
      _db
          .collection('progress')
          .doc(userId)
          .collection('modules')
          .doc(moduleId)
          .snapshots()
          .map((doc) =>
              doc.exists ? ModuleProgress.fromFirestore(moduleId, doc) : null);

  Future<bool> isLessonCompleted(String userId, String lessonId) async {
    final doc = await _db
        .collection('progress')
        .doc(userId)
        .collection('lessons')
        .doc(lessonId)
        .get();
    return doc.exists;
  }

  Future<void> markLessonComplete(
      String userId, String lessonId, String moduleId, int totalLessons,
      {int estimatedMinutes = 5}) async {
    final now = DateTime.now();

    // Record lesson completion
    await _db
        .collection('progress')
        .doc(userId)
        .collection('lessons')
        .doc(lessonId)
        .set({'completedAt': Timestamp.fromDate(now)});

    // Count how many lessons are now done in this module
    final completed = await _db
        .collection('progress')
        .doc(userId)
        .collection('lessons')
        .where('__name__', isGreaterThanOrEqualTo: '${moduleId}_')
        .where('__name__', isLessThan: '${moduleId}_z')
        .get();

    final count = completed.docs.length;
    final isDone = count >= totalLessons;

    // Update module progress
    await _db
        .collection('progress')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .set({
      'completedLessons': count,
      'totalLessons': totalLessons,
      'isCompleted': isDone,
      'lastAccessed': Timestamp.fromDate(now),
    });

    // Log screen time for this lesson
    await _logScreenTime(userId, estimatedMinutes);

    if (isDone) {
      final name = FirebaseAuth.instance.currentUser?.displayName ??
          FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          'Student';
      await _recordActivity(ActivityModel(
        id: '',
        type: 'module_completed',
        userId: userId,
        userName: name,
        moduleId: moduleId,
        createdAt: now,
      ));
    }
  }

  Future<void> saveQuizResult({
    required String userId,
    required String quizId,
    required String moduleId,
    required int score,
    required int total,
  }) async {
    final passed = total > 0 && (score / total) >= 0.7;
    final now = DateTime.now();
    await _db
        .collection('progress')
        .doc(userId)
        .collection('quizResults')
        .doc(quizId)
        .set({
      'score': score,
      'total': total,
      'passed': passed,
      'moduleId': moduleId,
      'attemptedAt': Timestamp.fromDate(now),
    });
    if (passed) {
      final name = FirebaseAuth.instance.currentUser?.displayName ??
          FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          'Student';
      await _recordActivity(ActivityModel(
        id: '',
        type: 'quiz_passed',
        userId: userId,
        userName: name,
        moduleId: moduleId,
        score: score,
        total: total,
        createdAt: now,
      ));
    }
  }

  // ─── Admin / Activity ────────────────────────────────────────────────────────

  Stream<List<UserModel>> getAllStudents() => _db
      .collection('users')
      .where('role', isEqualTo: 'student')
      .snapshots()
      .map((s) => s.docs.map(UserModel.fromFirestore).toList());

  Stream<int> watchStudentCount() => _db
      .collection('users')
      .where('role', isEqualTo: 'student')
      .snapshots()
      .map((s) => s.docs.length);

  Future<int> getLessonCount() async {
    final snap = await _db.collection('lessons').count().get();
    return snap.count ?? 0;
  }

  Stream<List<ActivityModel>> getRecentActivity({int limit = 8}) => _db
      .collection('recentActivity')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(ActivityModel.fromFirestore).toList());

  Future<void> _recordActivity(ActivityModel activity) async {
    await _db.collection('recentActivity').add(activity.toMap());
  }

  // ─── Quiz Results (per user) ─────────────────────────────────────────────────

  Stream<List<QuizResultModel>> getUserQuizResults(String userId) => _db
      .collection('progress')
      .doc(userId)
      .collection('quizResults')
      .orderBy('attemptedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(QuizResultModel.fromFirestore).toList());

  // ─── Admin: Module CRUD ──────────────────────────────────────────────────────

  Future<void> saveModule(ModuleModel module) async {
    if (module.id.isEmpty) {
      await _db.collection('modules').add(module.toMap());
    } else {
      await _db.collection('modules').doc(module.id).set(module.toMap());
    }
  }

  Future<void> deleteModule(String moduleId) async {
    final lessons = await _db
        .collection('lessons')
        .where('moduleId', isEqualTo: moduleId)
        .get();
    final batch = _db.batch();
    for (final doc in lessons.docs) {
      batch.delete(doc.reference);
      batch.delete(_db.collection('quizzes').doc(doc.id));
    }
    batch.delete(_db.collection('modules').doc(moduleId));
    await batch.commit();
  }

  // ─── Admin: Lesson & Quiz CRUD ───────────────────────────────────────────────

  Future<void> addLesson(LessonModel lesson) async {
    await _db.collection('lessons').doc(lesson.id).set(lesson.toMap());
    // Update totalLessons count on the module
    await _db.collection('modules').doc(lesson.moduleId).update({
      'totalLessons': FieldValue.increment(1),
    });
  }

  Future<void> updateLesson(LessonModel lesson) async {
    await _db.collection('lessons').doc(lesson.id).update(lesson.toMap());
  }

  Future<void> deleteLesson(String lessonId, String moduleId) async {
    await _db.collection('lessons').doc(lessonId).delete();
    await _db.collection('quizzes').doc(lessonId).delete();
    await _db.collection('modules').doc(moduleId).update({
      'totalLessons': FieldValue.increment(-1),
    });
  }

  Future<void> saveQuiz(QuizModel quiz) async {
    await _db.collection('quizzes').doc(quiz.id).set(quiz.toMap());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _db.collection('quizzes').doc(quizId).delete();
  }

  // ─── Parent–Child Linking ────────────────────────────────────────────────────

  /// Returns null on success, or an error message string on failure.
  Future<String?> linkChildByEmail(String parentId, String childEmail) async {
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: childEmail.trim().toLowerCase())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return 'No student found with that email.';

    final childDoc = snap.docs.first;
    final role = childDoc.data()['role'] as String? ?? '';
    if (role != 'student') return 'That account is not a student account.';
    if (childDoc.id == parentId) return 'You cannot link your own account.';

    await _db
        .collection('parentLinks')
        .doc(parentId)
        .collection('children')
        .doc(childDoc.id)
        .set({
      'childId': childDoc.id,
      'childName': childDoc.data()['name'] ?? childDoc.data()['email'],
      'linkedAt': Timestamp.fromDate(DateTime.now()),
    });

    return null;
  }

  Future<void> unlinkChild(String parentId, String childId) async {
    await _db
        .collection('parentLinks')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .delete();
  }

  Stream<List<UserModel>> getLinkedChildren(String parentId) => _db
      .collection('parentLinks')
      .doc(parentId)
      .collection('children')
      .snapshots()
      .asyncMap((snap) async {
        if (snap.docs.isEmpty) return <UserModel>[];
        final futures = snap.docs.map((d) async {
          final childId = d.id;
          final userDoc =
              await _db.collection('users').doc(childId).get();
          if (!userDoc.exists) return null;
          return UserModel.fromFirestore(userDoc);
        });
        final results = await Future.wait(futures);
        return results.whereType<UserModel>().toList();
      });

  // ─── Screen Time ─────────────────────────────────────────────────────────────

  Future<void> _logScreenTime(String userId, int minutes) async {
    if (minutes <= 0) return;
    final now = DateTime.now();
    final key =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _db
        .collection('screenTime')
        .doc(userId)
        .collection('days')
        .doc(key)
        .set({
      'minutes': FieldValue.increment(minutes),
      'date': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  /// Returns a map of date-string → minutes for the last [days] days.
  Stream<Map<String, int>> getWeeklyScreenTime(String userId) => _db
      .collection('screenTime')
      .doc(userId)
      .collection('days')
      .snapshots()
      .map((snap) => {
            for (final doc in snap.docs)
              doc.id: (doc.data()['minutes'] as num?)?.toInt() ?? 0
          });

  /// Returns a list of lesson IDs the user has completed.
  Future<List<String>> getCompletedLessonIds(String userId) async {
    final snap = await _db
        .collection('progress')
        .doc(userId)
        .collection('lessons')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  // ─── Seed Initial Data ───────────────────────────────────────────────────────

  Future<void> seedInitialData() async {
    // Check if already seeded
    final existing = await _db.collection('modules').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();

    // ── Modules ──────────────────────────────────────────────────────────────
    final modules = [
      {
        'id': 'word',
        'title': 'Word Processing',
        'description': 'Learn to create and format documents using Microsoft Word.',
        'iconKey': 'word',
        'order': 1,
        'totalLessons': 3,
        'difficulty': 'beginner',
        'colorValue': 0xFF4A90E2,
        'isOfflineAvailable': true,
      },
      {
        'id': 'excel',
        'title': 'Spreadsheets',
        'description': 'Organize data and use formulas with Microsoft Excel.',
        'iconKey': 'excel',
        'order': 2,
        'totalLessons': 3,
        'difficulty': 'beginner',
        'colorValue': 0xFF3DDC84,
        'isOfflineAvailable': true,
      },
      {
        'id': 'email',
        'title': 'Email Skills',
        'description': 'Write professional emails and communicate effectively online.',
        'iconKey': 'email',
        'order': 3,
        'totalLessons': 3,
        'difficulty': 'beginner',
        'colorValue': 0xFFFF8C42,
        'isOfflineAvailable': true,
      },
      {
        'id': 'safety',
        'title': 'Internet Safety',
        'description': 'Stay safe online and protect your personal information.',
        'iconKey': 'safety',
        'order': 4,
        'totalLessons': 3,
        'difficulty': 'intermediate',
        'colorValue': 0xFF7B61FF,
        'isOfflineAvailable': true,
      },
    ];

    for (final m in modules) {
      final id = m['id'] as String;
      final data = Map<String, dynamic>.from(m)..remove('id');
      batch.set(_db.collection('modules').doc(id), data);
    }

    // ── Lessons ──────────────────────────────────────────────────────────────
    final lessons = [
      // Word lessons
      LessonModel(
        id: 'word_1',
        moduleId: 'word',
        title: 'What is Word?',
        content:
            'Microsoft Word is a digital tool used to write and format documents. '
            'You can use it to create letters, school reports, and stories. '
            'It runs on computers and is widely used in schools and offices.',
        translation:
            'Microsoft Word ni porogaramu ikoreshwa mu kwandika no gutegura inyandiko zitandukanye nk\'amabaruwa, raporo z\'ishuri, n\'inkuru.',
        order: 1,
      ),
      LessonModel(
        id: 'word_2',
        moduleId: 'word',
        title: 'Opening Word',
        content:
            'To open Microsoft Word, click on the Start menu at the bottom-left of your screen. '
            'Find "Word" in the list of applications and double-click to open it. '
            'A blank white page will appear — this is your document.',
        translation:
            'Kugirango ugure Word, kanda ku butumwa bwa "Start" munsi ibumoso by\'ibibaho cyawe. '
            'Ubonere "Word" mu rutonde rw\'porogaramu hanyuma uyikande kabiri kugirango uyifungure.',
        order: 2,
      ),
      LessonModel(
        id: 'word_3',
        moduleId: 'word',
        title: 'Typing Your First Document',
        content:
            'Once Word is open, click anywhere on the blank page and start typing. '
            'The blinking cursor shows where your text will appear. '
            'Use the keyboard to type letters, numbers, and symbols. '
            'Press Enter to start a new paragraph.',
        translation:
            'Nuko Word ifunguye, kanda ahantu hose ku ipaji itagira inyandiko hanyuma utangire kwandika. '
            'Ikimenyetso cy\'inkariso gikora bwa nde kigaragaza aho inyandiko yawe izagaragara.',
        order: 3,
      ),
      // Excel lessons
      LessonModel(
        id: 'excel_1',
        moduleId: 'excel',
        title: 'What is Excel?',
        content:
            'Microsoft Excel is a spreadsheet program used to organize, analyze, and store data in a table format. '
            'It is used in schools to track grades, in businesses to manage money, '
            'and by anyone who needs to organize numbers or lists.',
        translation:
            'Microsoft Excel ni porogaramu ikoreshwa mu gutunga no gusesengura amakuru mu buryo bw\'imbonerahamwe. '
            'Ikoreshwa mu mashuri gutunga amanota, mu bikorwa by\'ubucuruzi gutunga amafaranga.',
        order: 1,
      ),
      LessonModel(
        id: 'excel_2',
        moduleId: 'excel',
        title: 'Cells, Rows & Columns',
        content:
            'A spreadsheet is made up of cells arranged in rows (horizontal) and columns (vertical). '
            'Each cell has an address: column letter + row number. For example, the first cell is A1. '
            'Click any cell to select it, then type to enter data.',
        translation:
            'Imbonerahamwe igizwe n\'inzitizi ziteganyirizwa mu mirongo (y\'ingorofani) no mu nkingi (z\'uburebure). '
            'Buri nzitizi ifite aderesi: inzitizi z\'inkingi + inomero y\'umurongo. Urugero: inzitizi ya mbere ni A1.',
        order: 2,
      ),
      LessonModel(
        id: 'excel_3',
        moduleId: 'excel',
        title: 'Basic Formulas',
        content:
            'Formulas let Excel calculate things automatically. '
            'Start every formula with "=" sign. '
            'To add numbers in cells A1 and B1, type: =A1+B1 '
            'To find the sum of a range, use: =SUM(A1:A5) '
            'Press Enter to see the result.',
        translation:
            'Imifomule ivuga Excel gubarura ibintu vuba. '
            'Tangira buri mufomule nka "=" ikimenyetso. '
            'Kugirango wongereze imibare mu nzitizi A1 na B1, andika: =A1+B1',
        order: 3,
      ),
      // Email lessons
      LessonModel(
        id: 'email_1',
        moduleId: 'email',
        title: 'What is Email?',
        content:
            'Email (electronic mail) is a way to send messages to anyone with an internet connection. '
            'It is free, fast, and used widely in schools, businesses, and government. '
            'Every email address has two parts separated by @: username@domain.com',
        translation:
            'Imeyili (ubutumwa bwa elegitoronike) ni uburyo bwo kohereza ubutumwa ku muntu wese ufite iyunganirwa n\'internet. '
            'Ni ubuntu, inyuma, kandi ikoreshwa cyane mu mashuri, bikorwa by\'ubucuruzi, n\'leta.',
        order: 1,
      ),
      LessonModel(
        id: 'email_2',
        moduleId: 'email',
        title: 'Composing an Email',
        content:
            'To write a new email:\n'
            '1. Click "Compose" or "New Email"\n'
            '2. In the "To" field, type the recipient\'s email address\n'
            '3. Add a clear Subject line (e.g. "Meeting on Friday")\n'
            '4. Type your message in the body\n'
            '5. Click "Send" when ready',
        translation:
            'Kugirango wandike imeyili nshya:\n'
            '1. Kanda "Compose" cyangwa "New Email"\n'
            '2. Mu gace ka "To", andika aderesi imeyili y\'uwakiriye\n'
            '3. Ongeramo umutwe w\'ubutumwa (urugero: "Inama ku wa Gatanu")\n'
            '4. Andika ubutumwa bwawe mu mubiri\n'
            '5. Kanda "Send" nigitangira',
        order: 2,
      ),
      LessonModel(
        id: 'email_3',
        moduleId: 'email',
        title: 'Email Safety',
        content:
            'Stay safe when using email:\n'
            '• Never share your password with anyone.\n'
            '• Do not click links in emails from people you do not know.\n'
            '• Check the sender\'s address before replying.\n'
            '• If an email asks for personal information, it may be a scam.',
        translation:
            'Komera mu mutekano mukoresha imeyili:\n'
            '• Ntabwo ugomba gusomagura ijambo ryawe ryibanga na muntu wese.\n'
            '• Ntukande impushya mu meyili za ba bantu utazi.\n'
            '• Reba aderesi ya nyirubutumwa mbere yo gusubiza.',
        order: 3,
      ),
      // Internet Safety lessons
      LessonModel(
        id: 'safety_1',
        moduleId: 'safety',
        title: 'Staying Safe Online',
        content:
            'The internet is a powerful tool, but it has risks. '
            'To stay safe:\n'
            '• Only share personal information on trusted websites.\n'
            '• Look for "https://" and a padlock icon in the address bar.\n'
            '• Log out of accounts when using shared devices.\n'
            '• Tell a trusted adult if something online makes you uncomfortable.',
        translation:
            'Internet ni igikoresho cy\'agaciro, ariko ifite ingaruka. '
            'Kugirango ukomere mu mutekano:\n'
            '• Sangira amakuru bwite gusa ku mbuga zizewe.\n'
            '• Reba "https://" n\'ikimenyetso cy\'inzigi mu baribari y\'aderesi.',
        order: 1,
      ),
      LessonModel(
        id: 'safety_2',
        moduleId: 'safety',
        title: 'Recognizing Scams',
        content:
            'Scammers try to trick you into giving them money or personal information. '
            'Warning signs of a scam:\n'
            '• "You have won a prize!" — but you never entered a contest.\n'
            '• A stranger asking for your password or ID number.\n'
            '• Urgent messages saying your account will be closed.\n'
            'When in doubt, do not click — ask someone you trust.',
        translation:
            'Ababeshya bashaka kukwiba amafaranga cyangwa amakuru bwite. '
            'Ibimenyetso by\'uburiganya:\n'
            '• "Watsinze igihembo!" — ariko ntabwo waragaragara.\n'
            '• Umunyamahanga usaba ijambo ryawe ryibanga cyangwa inomero y\'indangamuntu.',
        order: 2,
      ),
      LessonModel(
        id: 'safety_3',
        moduleId: 'safety',
        title: 'Password Safety',
        content:
            'A strong password protects your accounts.\n'
            'Tips for strong passwords:\n'
            '• Use at least 8 characters\n'
            '• Mix letters, numbers, and symbols (e.g. Tum3nye@2025)\n'
            '• Never use your name, birthday, or "123456"\n'
            '• Use a different password for each account\n'
            '• Change passwords every few months',
        translation:
            'Ijambo ryibanga rikomeye ririnda konti zawe.\n'
            'Inama z\'amagambo y\'ibanga makomeye:\n'
            '• Koresha byibuze inyuguti 8\n'
            '• Sanganya inzitizi, imibare, n\'ibimenyetso (urugero: Tum3nye@2025)\n'
            '• Ntabwo ukoresha izina ryawe, umunsi w\'amavuko, cyangwa "123456"',
        order: 3,
      ),
    ];

    for (final lesson in lessons) {
      batch.set(
        _db.collection('lessons').doc(lesson.id),
        lesson.toMap(),
      );
    }

    // ── Quizzes (embedded questions) ─────────────────────────────────────────
    final quizzes = [
      // Word quizzes
      QuizModel(
        id: 'word_1',
        lessonId: 'word_1',
        title: 'What is Word? — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What is Microsoft Word used for?',
            options: ['Playing games', 'Writing and formatting documents', 'Editing photos', 'Browsing the internet'],
            correctIndex: 1,
            explanation: 'Microsoft Word is a word processor — it helps you create and format text documents.',
            order: 1,
          ),
          QuestionModel(
            text: 'Which of these can you create in Microsoft Word?',
            options: ['A spreadsheet', 'A school report', 'A video game', 'A music file'],
            correctIndex: 1,
            explanation: 'Word is best suited for text documents like letters, reports, and stories.',
            order: 2,
          ),
          QuestionModel(
            text: 'Microsoft Word ni ikihe gikoresho?',
            options: ['Gukina imikino', 'Kwandika no gutegura inyandiko', 'Gusesengura amakuru', 'Gutunga amafaranga'],
            correctIndex: 1,
            explanation: 'Microsoft Word ni porogaramu ikoreshwa mu kwandika no gutegura inyandiko zitandukanye.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'word_2',
        lessonId: 'word_2',
        title: 'Opening Word — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'Where do you click to find and open Microsoft Word?',
            options: ['The Taskbar', 'The Start menu', 'The Desktop background', 'The File Explorer'],
            correctIndex: 1,
            explanation: 'The Start menu (bottom-left) lists all installed programs including Word.',
            order: 1,
          ),
          QuestionModel(
            text: 'What appears on screen when you open a new Word document?',
            options: ['A spreadsheet', 'A blank white page', 'A photo album', 'A calculator'],
            correctIndex: 1,
            explanation: 'A new Word document starts as a blank white page ready for you to type on.',
            order: 2,
          ),
          QuestionModel(
            text: 'How do you open Microsoft Word from the Start menu?',
            options: ['Single click once', 'Double-click on Word', 'Right-click and delete', 'Press Escape'],
            correctIndex: 1,
            explanation: 'Double-clicking opens the program. A single click only selects it.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'word_3',
        lessonId: 'word_3',
        title: 'Typing Your First Document — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What does the blinking cursor in Word show you?',
            options: ['The document title', 'Where your text will appear', 'The word count', 'The font size'],
            correctIndex: 1,
            explanation: 'The blinking cursor (insertion point) shows exactly where new text will be placed.',
            order: 1,
          ),
          QuestionModel(
            text: 'Which key do you press to start a new paragraph?',
            options: ['Tab', 'Backspace', 'Enter', 'Shift'],
            correctIndex: 2,
            explanation: 'The Enter key moves the cursor to a new line, starting a new paragraph.',
            order: 2,
          ),
          QuestionModel(
            text: 'What should you click before you start typing in Word?',
            options: ['The Save button', 'Anywhere on the blank page', 'The Home tab', 'The Print option'],
            correctIndex: 1,
            explanation: 'Clicking on the page places the cursor there so you can begin typing.',
            order: 3,
          ),
        ],
      ),
      // Excel quizzes
      QuizModel(
        id: 'excel_1',
        lessonId: 'excel_1',
        title: 'What is Excel? — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What is Microsoft Excel primarily used for?',
            options: ['Writing stories', 'Organizing and analyzing data', 'Drawing pictures', 'Sending emails'],
            correctIndex: 1,
            explanation: 'Excel is a spreadsheet program for organizing, analyzing, and storing data in tables.',
            order: 1,
          ),
          QuestionModel(
            text: 'In which of these situations would Excel be most useful?',
            options: ['Writing a letter to a friend', 'Tracking student grades', 'Watching a video', 'Sending a message'],
            correctIndex: 1,
            explanation: 'Excel is ideal for tracking data like grades because it can organize and calculate automatically.',
            order: 2,
          ),
          QuestionModel(
            text: 'Microsoft Excel ikoreshwa cyane he?',
            options: ['Kwandika inkuru', 'Gutunga no gusesengura amakuru', 'Guherekeza amashusho', 'Gukina imikino'],
            correctIndex: 1,
            explanation: 'Excel ni porogaramu ikoreshwa mu gutunga no gusesengura amakuru mu buryo bw\'imbonerahamwe.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'excel_2',
        lessonId: 'excel_2',
        title: 'Cells, Rows & Columns — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What is the address of the first cell in an Excel spreadsheet?',
            options: ['1A', 'A1', 'AA', '11'],
            correctIndex: 1,
            explanation: 'Cell addresses use column letter first, then row number — so the first cell is A1.',
            order: 1,
          ),
          QuestionModel(
            text: 'Which direction do rows go in a spreadsheet?',
            options: ['Vertical (up and down)', 'Horizontal (left and right)', 'Diagonal', 'Circular'],
            correctIndex: 1,
            explanation: 'Rows go horizontally (left to right). Columns go vertically (up and down).',
            order: 2,
          ),
          QuestionModel(
            text: 'How do you select a cell in Excel?',
            options: ['Press Escape', 'Click on it', 'Double-click and delete', 'Right-click and format'],
            correctIndex: 1,
            explanation: 'A single click selects the cell and shows its address in the Name Box.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'excel_3',
        lessonId: 'excel_3',
        title: 'Basic Formulas — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What symbol must every Excel formula start with?',
            options: ['+', '#', '=', '@'],
            correctIndex: 2,
            explanation: 'All Excel formulas must begin with the "=" sign so Excel knows it\'s a calculation.',
            order: 1,
          ),
          QuestionModel(
            text: 'Which formula adds all numbers from A1 to A5?',
            options: ['=ADD(A1,A5)', '=TOTAL(A1:A5)', '=SUM(A1:A5)', '=COUNT(A1-A5)'],
            correctIndex: 2,
            explanation: 'SUM is the function for adding a range of cells. A1:A5 means from A1 to A5.',
            order: 2,
          ),
          QuestionModel(
            text: 'What do you press after typing a formula to see the result?',
            options: ['Escape', 'Tab', 'Enter', 'Backspace'],
            correctIndex: 2,
            explanation: 'Pressing Enter confirms the formula and Excel displays the calculated result.',
            order: 3,
          ),
        ],
      ),
      // Email quizzes
      QuizModel(
        id: 'email_1',
        lessonId: 'email_1',
        title: 'What is Email? — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What does the "@" symbol in an email address separate?',
            options: ['First name and last name', 'Username and domain', 'Subject and body', 'Sender and receiver'],
            correctIndex: 1,
            explanation: 'An email address is structured as username@domain.com — the @ separates username from domain.',
            order: 1,
          ),
          QuestionModel(
            text: 'Which of these is an advantage of email?',
            options: ['It requires a stamp', 'It is free and fast', 'It only works offline', 'It needs a fax machine'],
            correctIndex: 1,
            explanation: 'Email is free, fast, and can reach anyone with an internet connection.',
            order: 2,
          ),
          QuestionModel(
            text: 'Imeyili ikoreshwa he cyane?',
            options: ['Gusa mu rugo', 'Mu mashuri, bikorwa by\'ubucuruzi no mu leta', 'Gusa mu bihugu by\'Uburayi', 'Gusa n\'inzobere'],
            correctIndex: 1,
            explanation: 'Imeyili ikoreshwa cyane mu mashuri, bikorwa by\'ubucuruzi, no mu nzego za leta.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'email_2',
        lessonId: 'email_2',
        title: 'Composing an Email — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What goes in the "Subject" line of an email?',
            options: ['Your password', 'A short description of the email topic', 'Your home address', 'The date only'],
            correctIndex: 1,
            explanation: 'The Subject line gives the reader a brief idea of what the email is about.',
            order: 1,
          ),
          QuestionModel(
            text: 'Where do you type the recipient\'s email address?',
            options: ['In the Subject field', 'In the "To" field', 'In the body of the email', 'In the attachment area'],
            correctIndex: 1,
            explanation: 'The "To" field is where you enter the email address of the person you are sending to.',
            order: 2,
          ),
          QuestionModel(
            text: 'What do you click when your email is ready to send?',
            options: ['Delete', 'Save Draft', 'Send', 'Archive'],
            correctIndex: 2,
            explanation: 'Clicking "Send" delivers your email to the recipient.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'email_3',
        lessonId: 'email_3',
        title: 'Email Safety — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'Ugomba gukora iki niba umutazi akubajije ijambo ryibanga (password) ryawe?',
            options: ['Kumubwira', 'Kuceceka', 'Kuyimwima no kubibwira umubyeyi', 'Kugena ijambo rishya mubibwire'],
            correctIndex: 2,
            explanation: 'Ntabwo ugomba gusomagura amakuru yawe yibanga ra bantu utazi. Bwira umubyeyi cyangwa umwarimu wawe.',
            order: 1,
          ),
          QuestionModel(
            text: 'What should you do before clicking a link in an unknown email?',
            options: ['Click it immediately', 'Verify the sender\'s address first', 'Forward it to a friend', 'Print it out'],
            correctIndex: 1,
            explanation: 'Always check who sent the email before clicking any links — it could be a scam.',
            order: 2,
          ),
          QuestionModel(
            text: 'Which of these is a warning sign that an email may be unsafe?',
            options: ['It has a clear subject line', 'It comes from your teacher', 'It asks for your password urgently', 'It has your name spelled correctly'],
            correctIndex: 2,
            explanation: 'Legitimate services never ask for your password by email. This is a common scam tactic.',
            order: 3,
          ),
        ],
      ),
      // Internet Safety quizzes
      QuizModel(
        id: 'safety_1',
        lessonId: 'safety_1',
        title: 'Staying Safe Online — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'What does "https://" at the start of a website address mean?',
            options: ['The website is free', 'The connection is secure', 'The website is popular', 'The website is new'],
            correctIndex: 1,
            explanation: 'HTTPS means the connection between your browser and the website is encrypted and secure.',
            order: 1,
          ),
          QuestionModel(
            text: 'What should you do when using a shared computer?',
            options: ['Save your passwords on it', 'Log out of all accounts when done', 'Leave the browser open', 'Share your login with others'],
            correctIndex: 1,
            explanation: 'Always log out of accounts on shared devices so others cannot access your information.',
            order: 2,
          ),
          QuestionModel(
            text: 'Ni ikihe kimenyetso cy\'umutekano kuri interineti?',
            options: ['Aderesi itangira na "http://"', 'Aderesi itangira na "https://" n\'inzigi', 'Urubuga rufite amashusho menshi', 'Urubuga rutanga ibikinisho buntu'],
            correctIndex: 1,
            explanation: 'HTTPS n\'ikimenyetso cy\'inzigi bigaragaza ko iyunganirwa ryawe rifite umutekano.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'safety_2',
        lessonId: 'safety_2',
        title: 'Recognizing Scams — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'You receive a message: "You have won \$1000! Click here now!" What should you do?',
            options: ['Click the link immediately', 'Share it with friends', 'Ignore or delete it — it\'s a scam', 'Send your bank details'],
            correctIndex: 2,
            explanation: 'This is a classic scam. If something sounds too good to be true, it usually is.',
            order: 1,
          ),
          QuestionModel(
            text: 'A stranger online asks for your ID number. What should you do?',
            options: ['Give it — they seem friendly', 'Refuse and tell a trusted adult', 'Give only your first name', 'Send a photo of your ID'],
            correctIndex: 1,
            explanation: 'Never share personal identification numbers online with strangers.',
            order: 2,
          ),
          QuestionModel(
            text: 'Which is a warning sign of an online scam?',
            options: ['A message from your known school email', 'An urgent message saying your account will close', 'A reminder to change your password from a known service', 'An email with your correct full name'],
            correctIndex: 1,
            explanation: 'Scammers create urgency to pressure you into acting without thinking.',
            order: 3,
          ),
        ],
      ),
      QuizModel(
        id: 'safety_3',
        lessonId: 'safety_3',
        title: 'Password Safety — Quiz',
        passingScore: 70,
        questions: [
          QuestionModel(
            text: 'How often should you update your password?',
            options: ['Never — it\'s fine as is', 'Every few months', 'Only when you forget it', 'Once a year only'],
            correctIndex: 1,
            explanation: 'Changing passwords regularly keeps your accounts safer against unauthorized access.',
            order: 1,
          ),
          QuestionModel(
            text: 'Which of these is the strongest password?',
            options: ['12345678', 'yourname2005', 'Tum3nye@2025!', 'password'],
            correctIndex: 2,
            explanation: 'A strong password mixes uppercase, lowercase, numbers, and symbols — and avoids common words.',
            order: 2,
          ),
          QuestionModel(
            text: 'Should you use the same password for all your accounts?',
            options: ['Yes — it\'s easier to remember', 'No — use a different password for each account', 'Yes — if it\'s a strong password', 'It doesn\'t matter'],
            correctIndex: 1,
            explanation: 'Using unique passwords per account ensures that if one is compromised, others remain safe.',
            order: 3,
          ),
        ],
      ),
    ];

    for (final quiz in quizzes) {
      batch.set(
        _db.collection('quizzes').doc(quiz.id),
        quiz.toMap(),
      );
    }

    await batch.commit();
  }
}
