// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PracticeProgressTable extends PracticeProgress
    with TableInfo<$PracticeProgressTable, PracticeProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta(
    'lastPositionMs',
  );
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastContentModeMeta = const VerificationMeta(
    'lastContentMode',
  );
  @override
  late final GeneratedColumn<String> lastContentMode = GeneratedColumn<String>(
    'last_content_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('transcript'),
  );
  static const VerificationMeta _practiceCountMeta = const VerificationMeta(
    'practiceCount',
  );
  @override
  late final GeneratedColumn<int> practiceCount = GeneratedColumn<int>(
    'practice_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPracticedAtUtcMeta =
      const VerificationMeta('lastPracticedAtUtc');
  @override
  late final GeneratedColumn<int> lastPracticedAtUtc = GeneratedColumn<int>(
    'last_practiced_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    lastPositionMs,
    lastContentMode,
    practiceCount,
    completed,
    lastPracticedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(
          data['last_position_ms']!,
          _lastPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('last_content_mode')) {
      context.handle(
        _lastContentModeMeta,
        lastContentMode.isAcceptableOrUnknown(
          data['last_content_mode']!,
          _lastContentModeMeta,
        ),
      );
    }
    if (data.containsKey('practice_count')) {
      context.handle(
        _practiceCountMeta,
        practiceCount.isAcceptableOrUnknown(
          data['practice_count']!,
          _practiceCountMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('last_practiced_at_utc')) {
      context.handle(
        _lastPracticedAtUtcMeta,
        lastPracticedAtUtc.isAcceptableOrUnknown(
          data['last_practiced_at_utc']!,
          _lastPracticedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPracticedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  PracticeProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeProgressData(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      lastPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position_ms'],
      )!,
      lastContentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_content_mode'],
      )!,
      practiceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practice_count'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      lastPracticedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_practiced_at_utc'],
      )!,
    );
  }

  @override
  $PracticeProgressTable createAlias(String alias) {
    return $PracticeProgressTable(attachedDatabase, alias);
  }
}

class PracticeProgressData extends DataClass
    implements Insertable<PracticeProgressData> {
  final String questionId;
  final int lastPositionMs;
  final String lastContentMode;
  final int practiceCount;
  final bool completed;
  final int lastPracticedAtUtc;
  const PracticeProgressData({
    required this.questionId,
    required this.lastPositionMs,
    required this.lastContentMode,
    required this.practiceCount,
    required this.completed,
    required this.lastPracticedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    map['last_content_mode'] = Variable<String>(lastContentMode);
    map['practice_count'] = Variable<int>(practiceCount);
    map['completed'] = Variable<bool>(completed);
    map['last_practiced_at_utc'] = Variable<int>(lastPracticedAtUtc);
    return map;
  }

  PracticeProgressCompanion toCompanion(bool nullToAbsent) {
    return PracticeProgressCompanion(
      questionId: Value(questionId),
      lastPositionMs: Value(lastPositionMs),
      lastContentMode: Value(lastContentMode),
      practiceCount: Value(practiceCount),
      completed: Value(completed),
      lastPracticedAtUtc: Value(lastPracticedAtUtc),
    );
  }

  factory PracticeProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeProgressData(
      questionId: serializer.fromJson<String>(json['questionId']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
      lastContentMode: serializer.fromJson<String>(json['lastContentMode']),
      practiceCount: serializer.fromJson<int>(json['practiceCount']),
      completed: serializer.fromJson<bool>(json['completed']),
      lastPracticedAtUtc: serializer.fromJson<int>(json['lastPracticedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
      'lastContentMode': serializer.toJson<String>(lastContentMode),
      'practiceCount': serializer.toJson<int>(practiceCount),
      'completed': serializer.toJson<bool>(completed),
      'lastPracticedAtUtc': serializer.toJson<int>(lastPracticedAtUtc),
    };
  }

  PracticeProgressData copyWith({
    String? questionId,
    int? lastPositionMs,
    String? lastContentMode,
    int? practiceCount,
    bool? completed,
    int? lastPracticedAtUtc,
  }) => PracticeProgressData(
    questionId: questionId ?? this.questionId,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    lastContentMode: lastContentMode ?? this.lastContentMode,
    practiceCount: practiceCount ?? this.practiceCount,
    completed: completed ?? this.completed,
    lastPracticedAtUtc: lastPracticedAtUtc ?? this.lastPracticedAtUtc,
  );
  PracticeProgressData copyWithCompanion(PracticeProgressCompanion data) {
    return PracticeProgressData(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      lastPositionMs: data.lastPositionMs.present
          ? data.lastPositionMs.value
          : this.lastPositionMs,
      lastContentMode: data.lastContentMode.present
          ? data.lastContentMode.value
          : this.lastContentMode,
      practiceCount: data.practiceCount.present
          ? data.practiceCount.value
          : this.practiceCount,
      completed: data.completed.present ? data.completed.value : this.completed,
      lastPracticedAtUtc: data.lastPracticedAtUtc.present
          ? data.lastPracticedAtUtc.value
          : this.lastPracticedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeProgressData(')
          ..write('questionId: $questionId, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('lastContentMode: $lastContentMode, ')
          ..write('practiceCount: $practiceCount, ')
          ..write('completed: $completed, ')
          ..write('lastPracticedAtUtc: $lastPracticedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    questionId,
    lastPositionMs,
    lastContentMode,
    practiceCount,
    completed,
    lastPracticedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeProgressData &&
          other.questionId == this.questionId &&
          other.lastPositionMs == this.lastPositionMs &&
          other.lastContentMode == this.lastContentMode &&
          other.practiceCount == this.practiceCount &&
          other.completed == this.completed &&
          other.lastPracticedAtUtc == this.lastPracticedAtUtc);
}

class PracticeProgressCompanion extends UpdateCompanion<PracticeProgressData> {
  final Value<String> questionId;
  final Value<int> lastPositionMs;
  final Value<String> lastContentMode;
  final Value<int> practiceCount;
  final Value<bool> completed;
  final Value<int> lastPracticedAtUtc;
  final Value<int> rowid;
  const PracticeProgressCompanion({
    this.questionId = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.lastContentMode = const Value.absent(),
    this.practiceCount = const Value.absent(),
    this.completed = const Value.absent(),
    this.lastPracticedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeProgressCompanion.insert({
    required String questionId,
    this.lastPositionMs = const Value.absent(),
    this.lastContentMode = const Value.absent(),
    this.practiceCount = const Value.absent(),
    this.completed = const Value.absent(),
    required int lastPracticedAtUtc,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       lastPracticedAtUtc = Value(lastPracticedAtUtc);
  static Insertable<PracticeProgressData> custom({
    Expression<String>? questionId,
    Expression<int>? lastPositionMs,
    Expression<String>? lastContentMode,
    Expression<int>? practiceCount,
    Expression<bool>? completed,
    Expression<int>? lastPracticedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (lastContentMode != null) 'last_content_mode': lastContentMode,
      if (practiceCount != null) 'practice_count': practiceCount,
      if (completed != null) 'completed': completed,
      if (lastPracticedAtUtc != null)
        'last_practiced_at_utc': lastPracticedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeProgressCompanion copyWith({
    Value<String>? questionId,
    Value<int>? lastPositionMs,
    Value<String>? lastContentMode,
    Value<int>? practiceCount,
    Value<bool>? completed,
    Value<int>? lastPracticedAtUtc,
    Value<int>? rowid,
  }) {
    return PracticeProgressCompanion(
      questionId: questionId ?? this.questionId,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      lastContentMode: lastContentMode ?? this.lastContentMode,
      practiceCount: practiceCount ?? this.practiceCount,
      completed: completed ?? this.completed,
      lastPracticedAtUtc: lastPracticedAtUtc ?? this.lastPracticedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (lastContentMode.present) {
      map['last_content_mode'] = Variable<String>(lastContentMode.value);
    }
    if (practiceCount.present) {
      map['practice_count'] = Variable<int>(practiceCount.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (lastPracticedAtUtc.present) {
      map['last_practiced_at_utc'] = Variable<int>(lastPracticedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeProgressCompanion(')
          ..write('questionId: $questionId, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('lastContentMode: $lastContentMode, ')
          ..write('practiceCount: $practiceCount, ')
          ..write('completed: $completed, ')
          ..write('lastPracticedAtUtc: $lastPracticedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeAnswersTable extends PracticeAnswers
    with TableInfo<$PracticeAnswersTable, PracticeAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedOptionIdMeta = const VerificationMeta(
    'selectedOptionId',
  );
  @override
  late final GeneratedColumn<String> selectedOptionId = GeneratedColumn<String>(
    'selected_option_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _answeredAtUtcMeta = const VerificationMeta(
    'answeredAtUtc',
  );
  @override
  late final GeneratedColumn<int> answeredAtUtc = GeneratedColumn<int>(
    'answered_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    selectedOptionId,
    isCorrect,
    attemptCount,
    answeredAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_option_id')) {
      context.handle(
        _selectedOptionIdMeta,
        selectedOptionId.isAcceptableOrUnknown(
          data['selected_option_id']!,
          _selectedOptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedOptionIdMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('answered_at_utc')) {
      context.handle(
        _answeredAtUtcMeta,
        answeredAtUtc.isAcceptableOrUnknown(
          data['answered_at_utc']!,
          _answeredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answeredAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  PracticeAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeAnswer(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      selectedOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_option_id'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      answeredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at_utc'],
      )!,
    );
  }

  @override
  $PracticeAnswersTable createAlias(String alias) {
    return $PracticeAnswersTable(attachedDatabase, alias);
  }
}

class PracticeAnswer extends DataClass implements Insertable<PracticeAnswer> {
  final String questionId;
  final String selectedOptionId;
  final bool isCorrect;
  final int attemptCount;
  final int answeredAtUtc;
  const PracticeAnswer({
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.attemptCount,
    required this.answeredAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['selected_option_id'] = Variable<String>(selectedOptionId);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['answered_at_utc'] = Variable<int>(answeredAtUtc);
    return map;
  }

  PracticeAnswersCompanion toCompanion(bool nullToAbsent) {
    return PracticeAnswersCompanion(
      questionId: Value(questionId),
      selectedOptionId: Value(selectedOptionId),
      isCorrect: Value(isCorrect),
      attemptCount: Value(attemptCount),
      answeredAtUtc: Value(answeredAtUtc),
    );
  }

  factory PracticeAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeAnswer(
      questionId: serializer.fromJson<String>(json['questionId']),
      selectedOptionId: serializer.fromJson<String>(json['selectedOptionId']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      answeredAtUtc: serializer.fromJson<int>(json['answeredAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'selectedOptionId': serializer.toJson<String>(selectedOptionId),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'answeredAtUtc': serializer.toJson<int>(answeredAtUtc),
    };
  }

  PracticeAnswer copyWith({
    String? questionId,
    String? selectedOptionId,
    bool? isCorrect,
    int? attemptCount,
    int? answeredAtUtc,
  }) => PracticeAnswer(
    questionId: questionId ?? this.questionId,
    selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    isCorrect: isCorrect ?? this.isCorrect,
    attemptCount: attemptCount ?? this.attemptCount,
    answeredAtUtc: answeredAtUtc ?? this.answeredAtUtc,
  );
  PracticeAnswer copyWithCompanion(PracticeAnswersCompanion data) {
    return PracticeAnswer(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedOptionId: data.selectedOptionId.present
          ? data.selectedOptionId.value
          : this.selectedOptionId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      answeredAtUtc: data.answeredAtUtc.present
          ? data.answeredAtUtc.value
          : this.answeredAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswer(')
          ..write('questionId: $questionId, ')
          ..write('selectedOptionId: $selectedOptionId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('answeredAtUtc: $answeredAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    questionId,
    selectedOptionId,
    isCorrect,
    attemptCount,
    answeredAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeAnswer &&
          other.questionId == this.questionId &&
          other.selectedOptionId == this.selectedOptionId &&
          other.isCorrect == this.isCorrect &&
          other.attemptCount == this.attemptCount &&
          other.answeredAtUtc == this.answeredAtUtc);
}

class PracticeAnswersCompanion extends UpdateCompanion<PracticeAnswer> {
  final Value<String> questionId;
  final Value<String> selectedOptionId;
  final Value<bool> isCorrect;
  final Value<int> attemptCount;
  final Value<int> answeredAtUtc;
  final Value<int> rowid;
  const PracticeAnswersCompanion({
    this.questionId = const Value.absent(),
    this.selectedOptionId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.answeredAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeAnswersCompanion.insert({
    required String questionId,
    required String selectedOptionId,
    required bool isCorrect,
    this.attemptCount = const Value.absent(),
    required int answeredAtUtc,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       selectedOptionId = Value(selectedOptionId),
       isCorrect = Value(isCorrect),
       answeredAtUtc = Value(answeredAtUtc);
  static Insertable<PracticeAnswer> custom({
    Expression<String>? questionId,
    Expression<String>? selectedOptionId,
    Expression<bool>? isCorrect,
    Expression<int>? attemptCount,
    Expression<int>? answeredAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (selectedOptionId != null) 'selected_option_id': selectedOptionId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (answeredAtUtc != null) 'answered_at_utc': answeredAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeAnswersCompanion copyWith({
    Value<String>? questionId,
    Value<String>? selectedOptionId,
    Value<bool>? isCorrect,
    Value<int>? attemptCount,
    Value<int>? answeredAtUtc,
    Value<int>? rowid,
  }) {
    return PracticeAnswersCompanion(
      questionId: questionId ?? this.questionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      isCorrect: isCorrect ?? this.isCorrect,
      attemptCount: attemptCount ?? this.attemptCount,
      answeredAtUtc: answeredAtUtc ?? this.answeredAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (selectedOptionId.present) {
      map['selected_option_id'] = Variable<String>(selectedOptionId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (answeredAtUtc.present) {
      map['answered_at_utc'] = Variable<int>(answeredAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswersCompanion(')
          ..write('questionId: $questionId, ')
          ..write('selectedOptionId: $selectedOptionId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('answeredAtUtc: $answeredAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteQuestionsTable extends FavoriteQuestions
    with TableInfo<$FavoriteQuestionsTable, FavoriteQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  FavoriteQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteQuestion(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $FavoriteQuestionsTable createAlias(String alias) {
    return $FavoriteQuestionsTable(attachedDatabase, alias);
  }
}

class FavoriteQuestion extends DataClass
    implements Insertable<FavoriteQuestion> {
  final String questionId;
  final int createdAtUtc;
  const FavoriteQuestion({
    required this.questionId,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  FavoriteQuestionsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteQuestionsCompanion(
      questionId: Value(questionId),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory FavoriteQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteQuestion(
      questionId: serializer.fromJson<String>(json['questionId']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  FavoriteQuestion copyWith({String? questionId, int? createdAtUtc}) =>
      FavoriteQuestion(
        questionId: questionId ?? this.questionId,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      );
  FavoriteQuestion copyWithCompanion(FavoriteQuestionsCompanion data) {
    return FavoriteQuestion(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteQuestion(')
          ..write('questionId: $questionId, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteQuestion &&
          other.questionId == this.questionId &&
          other.createdAtUtc == this.createdAtUtc);
}

class FavoriteQuestionsCompanion extends UpdateCompanion<FavoriteQuestion> {
  final Value<String> questionId;
  final Value<int> createdAtUtc;
  final Value<int> rowid;
  const FavoriteQuestionsCompanion({
    this.questionId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteQuestionsCompanion.insert({
    required String questionId,
    required int createdAtUtc,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<FavoriteQuestion> custom({
    Expression<String>? questionId,
    Expression<int>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteQuestionsCompanion copyWith({
    Value<String>? questionId,
    Value<int>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return FavoriteQuestionsCompanion(
      questionId: questionId ?? this.questionId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteQuestionsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteSentencesTable extends FavoriteSentences
    with TableInfo<$FavoriteSentencesTable, FavoriteSentence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteSentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sentenceIdMeta = const VerificationMeta(
    'sentenceId',
  );
  @override
  late final GeneratedColumn<String> sentenceId = GeneratedColumn<String>(
    'sentence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sentenceId, questionId, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteSentence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sentence_id')) {
      context.handle(
        _sentenceIdMeta,
        sentenceId.isAcceptableOrUnknown(data['sentence_id']!, _sentenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sentenceId};
  @override
  FavoriteSentence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteSentence(
      sentenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sentence_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $FavoriteSentencesTable createAlias(String alias) {
    return $FavoriteSentencesTable(attachedDatabase, alias);
  }
}

class FavoriteSentence extends DataClass
    implements Insertable<FavoriteSentence> {
  final String sentenceId;
  final String questionId;
  final int createdAtUtc;
  const FavoriteSentence({
    required this.sentenceId,
    required this.questionId,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sentence_id'] = Variable<String>(sentenceId);
    map['question_id'] = Variable<String>(questionId);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  FavoriteSentencesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteSentencesCompanion(
      sentenceId: Value(sentenceId),
      questionId: Value(questionId),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory FavoriteSentence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteSentence(
      sentenceId: serializer.fromJson<String>(json['sentenceId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sentenceId': serializer.toJson<String>(sentenceId),
      'questionId': serializer.toJson<String>(questionId),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  FavoriteSentence copyWith({
    String? sentenceId,
    String? questionId,
    int? createdAtUtc,
  }) => FavoriteSentence(
    sentenceId: sentenceId ?? this.sentenceId,
    questionId: questionId ?? this.questionId,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  FavoriteSentence copyWithCompanion(FavoriteSentencesCompanion data) {
    return FavoriteSentence(
      sentenceId: data.sentenceId.present
          ? data.sentenceId.value
          : this.sentenceId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteSentence(')
          ..write('sentenceId: $sentenceId, ')
          ..write('questionId: $questionId, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sentenceId, questionId, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteSentence &&
          other.sentenceId == this.sentenceId &&
          other.questionId == this.questionId &&
          other.createdAtUtc == this.createdAtUtc);
}

class FavoriteSentencesCompanion extends UpdateCompanion<FavoriteSentence> {
  final Value<String> sentenceId;
  final Value<String> questionId;
  final Value<int> createdAtUtc;
  final Value<int> rowid;
  const FavoriteSentencesCompanion({
    this.sentenceId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteSentencesCompanion.insert({
    required String sentenceId,
    required String questionId,
    required int createdAtUtc,
    this.rowid = const Value.absent(),
  }) : sentenceId = Value(sentenceId),
       questionId = Value(questionId),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<FavoriteSentence> custom({
    Expression<String>? sentenceId,
    Expression<String>? questionId,
    Expression<int>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sentenceId != null) 'sentence_id': sentenceId,
      if (questionId != null) 'question_id': questionId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteSentencesCompanion copyWith({
    Value<String>? sentenceId,
    Value<String>? questionId,
    Value<int>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return FavoriteSentencesCompanion(
      sentenceId: sentenceId ?? this.sentenceId,
      questionId: questionId ?? this.questionId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sentenceId.present) {
      map['sentence_id'] = Variable<String>(sentenceId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteSentencesCompanion(')
          ..write('sentenceId: $sentenceId, ')
          ..write('questionId: $questionId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestSessionsTable extends TestSessions
    with TableInfo<$TestSessionsTable, TestSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<int> startedAtUtc = GeneratedColumn<int>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submittedAtUtcMeta = const VerificationMeta(
    'submittedAtUtc',
  );
  @override
  late final GeneratedColumn<int> submittedAtUtc = GeneratedColumn<int>(
    'submitted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    status,
    startedAtUtc,
    submittedAtUtc,
    durationMs,
    totalCount,
    correctCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('submitted_at_utc')) {
      context.handle(
        _submittedAtUtcMeta,
        submittedAtUtc.isAcceptableOrUnknown(
          data['submitted_at_utc']!,
          _submittedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_utc'],
      )!,
      submittedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submitted_at_utc'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
    );
  }

  @override
  $TestSessionsTable createAlias(String alias) {
    return $TestSessionsTable(attachedDatabase, alias);
  }
}

class TestSession extends DataClass implements Insertable<TestSession> {
  final int id;
  final String examId;
  final String status;
  final int startedAtUtc;
  final int? submittedAtUtc;
  final int durationMs;
  final int totalCount;
  final int correctCount;
  const TestSession({
    required this.id,
    required this.examId,
    required this.status,
    required this.startedAtUtc,
    this.submittedAtUtc,
    required this.durationMs,
    required this.totalCount,
    required this.correctCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<String>(examId);
    map['status'] = Variable<String>(status);
    map['started_at_utc'] = Variable<int>(startedAtUtc);
    if (!nullToAbsent || submittedAtUtc != null) {
      map['submitted_at_utc'] = Variable<int>(submittedAtUtc);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['total_count'] = Variable<int>(totalCount);
    map['correct_count'] = Variable<int>(correctCount);
    return map;
  }

  TestSessionsCompanion toCompanion(bool nullToAbsent) {
    return TestSessionsCompanion(
      id: Value(id),
      examId: Value(examId),
      status: Value(status),
      startedAtUtc: Value(startedAtUtc),
      submittedAtUtc: submittedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAtUtc),
      durationMs: Value(durationMs),
      totalCount: Value(totalCount),
      correctCount: Value(correctCount),
    );
  }

  factory TestSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestSession(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<String>(json['examId']),
      status: serializer.fromJson<String>(json['status']),
      startedAtUtc: serializer.fromJson<int>(json['startedAtUtc']),
      submittedAtUtc: serializer.fromJson<int?>(json['submittedAtUtc']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<String>(examId),
      'status': serializer.toJson<String>(status),
      'startedAtUtc': serializer.toJson<int>(startedAtUtc),
      'submittedAtUtc': serializer.toJson<int?>(submittedAtUtc),
      'durationMs': serializer.toJson<int>(durationMs),
      'totalCount': serializer.toJson<int>(totalCount),
      'correctCount': serializer.toJson<int>(correctCount),
    };
  }

  TestSession copyWith({
    int? id,
    String? examId,
    String? status,
    int? startedAtUtc,
    Value<int?> submittedAtUtc = const Value.absent(),
    int? durationMs,
    int? totalCount,
    int? correctCount,
  }) => TestSession(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    status: status ?? this.status,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    submittedAtUtc: submittedAtUtc.present
        ? submittedAtUtc.value
        : this.submittedAtUtc,
    durationMs: durationMs ?? this.durationMs,
    totalCount: totalCount ?? this.totalCount,
    correctCount: correctCount ?? this.correctCount,
  );
  TestSession copyWithCompanion(TestSessionsCompanion data) {
    return TestSession(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      status: data.status.present ? data.status.value : this.status,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      submittedAtUtc: data.submittedAtUtc.present
          ? data.submittedAtUtc.value
          : this.submittedAtUtc,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestSession(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('status: $status, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('submittedAtUtc: $submittedAtUtc, ')
          ..write('durationMs: $durationMs, ')
          ..write('totalCount: $totalCount, ')
          ..write('correctCount: $correctCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    status,
    startedAtUtc,
    submittedAtUtc,
    durationMs,
    totalCount,
    correctCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestSession &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.status == this.status &&
          other.startedAtUtc == this.startedAtUtc &&
          other.submittedAtUtc == this.submittedAtUtc &&
          other.durationMs == this.durationMs &&
          other.totalCount == this.totalCount &&
          other.correctCount == this.correctCount);
}

class TestSessionsCompanion extends UpdateCompanion<TestSession> {
  final Value<int> id;
  final Value<String> examId;
  final Value<String> status;
  final Value<int> startedAtUtc;
  final Value<int?> submittedAtUtc;
  final Value<int> durationMs;
  final Value<int> totalCount;
  final Value<int> correctCount;
  const TestSessionsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.submittedAtUtc = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.correctCount = const Value.absent(),
  });
  TestSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String examId,
    required String status,
    required int startedAtUtc,
    this.submittedAtUtc = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.correctCount = const Value.absent(),
  }) : examId = Value(examId),
       status = Value(status),
       startedAtUtc = Value(startedAtUtc);
  static Insertable<TestSession> custom({
    Expression<int>? id,
    Expression<String>? examId,
    Expression<String>? status,
    Expression<int>? startedAtUtc,
    Expression<int>? submittedAtUtc,
    Expression<int>? durationMs,
    Expression<int>? totalCount,
    Expression<int>? correctCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (status != null) 'status': status,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (submittedAtUtc != null) 'submitted_at_utc': submittedAtUtc,
      if (durationMs != null) 'duration_ms': durationMs,
      if (totalCount != null) 'total_count': totalCount,
      if (correctCount != null) 'correct_count': correctCount,
    });
  }

  TestSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? examId,
    Value<String>? status,
    Value<int>? startedAtUtc,
    Value<int?>? submittedAtUtc,
    Value<int>? durationMs,
    Value<int>? totalCount,
    Value<int>? correctCount,
  }) {
    return TestSessionsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      status: status ?? this.status,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      submittedAtUtc: submittedAtUtc ?? this.submittedAtUtc,
      durationMs: durationMs ?? this.durationMs,
      totalCount: totalCount ?? this.totalCount,
      correctCount: correctCount ?? this.correctCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<int>(startedAtUtc.value);
    }
    if (submittedAtUtc.present) {
      map['submitted_at_utc'] = Variable<int>(submittedAtUtc.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestSessionsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('status: $status, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('submittedAtUtc: $submittedAtUtc, ')
          ..write('durationMs: $durationMs, ')
          ..write('totalCount: $totalCount, ')
          ..write('correctCount: $correctCount')
          ..write(')'))
        .toString();
  }
}

class $TestSessionAnswersTable extends TestSessionAnswers
    with TableInfo<$TestSessionAnswersTable, TestSessionAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestSessionAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedOptionIdMeta = const VerificationMeta(
    'selectedOptionId',
  );
  @override
  late final GeneratedColumn<String> selectedOptionId = GeneratedColumn<String>(
    'selected_option_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctOptionIdMeta = const VerificationMeta(
    'correctOptionId',
  );
  @override
  late final GeneratedColumn<String> correctOptionId = GeneratedColumn<String>(
    'correct_option_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    questionId,
    selectedOptionId,
    correctOptionId,
    isCorrect,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_session_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestSessionAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_option_id')) {
      context.handle(
        _selectedOptionIdMeta,
        selectedOptionId.isAcceptableOrUnknown(
          data['selected_option_id']!,
          _selectedOptionIdMeta,
        ),
      );
    }
    if (data.containsKey('correct_option_id')) {
      context.handle(
        _correctOptionIdMeta,
        correctOptionId.isAcceptableOrUnknown(
          data['correct_option_id']!,
          _correctOptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctOptionIdMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, questionId};
  @override
  TestSessionAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestSessionAnswer(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      selectedOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_option_id'],
      ),
      correctOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_option_id'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
    );
  }

  @override
  $TestSessionAnswersTable createAlias(String alias) {
    return $TestSessionAnswersTable(attachedDatabase, alias);
  }
}

class TestSessionAnswer extends DataClass
    implements Insertable<TestSessionAnswer> {
  final int sessionId;
  final String questionId;
  final String? selectedOptionId;
  final String correctOptionId;
  final bool isCorrect;
  const TestSessionAnswer({
    required this.sessionId,
    required this.questionId,
    this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['question_id'] = Variable<String>(questionId);
    if (!nullToAbsent || selectedOptionId != null) {
      map['selected_option_id'] = Variable<String>(selectedOptionId);
    }
    map['correct_option_id'] = Variable<String>(correctOptionId);
    map['is_correct'] = Variable<bool>(isCorrect);
    return map;
  }

  TestSessionAnswersCompanion toCompanion(bool nullToAbsent) {
    return TestSessionAnswersCompanion(
      sessionId: Value(sessionId),
      questionId: Value(questionId),
      selectedOptionId: selectedOptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedOptionId),
      correctOptionId: Value(correctOptionId),
      isCorrect: Value(isCorrect),
    );
  }

  factory TestSessionAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestSessionAnswer(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      selectedOptionId: serializer.fromJson<String?>(json['selectedOptionId']),
      correctOptionId: serializer.fromJson<String>(json['correctOptionId']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'questionId': serializer.toJson<String>(questionId),
      'selectedOptionId': serializer.toJson<String?>(selectedOptionId),
      'correctOptionId': serializer.toJson<String>(correctOptionId),
      'isCorrect': serializer.toJson<bool>(isCorrect),
    };
  }

  TestSessionAnswer copyWith({
    int? sessionId,
    String? questionId,
    Value<String?> selectedOptionId = const Value.absent(),
    String? correctOptionId,
    bool? isCorrect,
  }) => TestSessionAnswer(
    sessionId: sessionId ?? this.sessionId,
    questionId: questionId ?? this.questionId,
    selectedOptionId: selectedOptionId.present
        ? selectedOptionId.value
        : this.selectedOptionId,
    correctOptionId: correctOptionId ?? this.correctOptionId,
    isCorrect: isCorrect ?? this.isCorrect,
  );
  TestSessionAnswer copyWithCompanion(TestSessionAnswersCompanion data) {
    return TestSessionAnswer(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedOptionId: data.selectedOptionId.present
          ? data.selectedOptionId.value
          : this.selectedOptionId,
      correctOptionId: data.correctOptionId.present
          ? data.correctOptionId.value
          : this.correctOptionId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestSessionAnswer(')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOptionId: $selectedOptionId, ')
          ..write('correctOptionId: $correctOptionId, ')
          ..write('isCorrect: $isCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    questionId,
    selectedOptionId,
    correctOptionId,
    isCorrect,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestSessionAnswer &&
          other.sessionId == this.sessionId &&
          other.questionId == this.questionId &&
          other.selectedOptionId == this.selectedOptionId &&
          other.correctOptionId == this.correctOptionId &&
          other.isCorrect == this.isCorrect);
}

class TestSessionAnswersCompanion extends UpdateCompanion<TestSessionAnswer> {
  final Value<int> sessionId;
  final Value<String> questionId;
  final Value<String?> selectedOptionId;
  final Value<String> correctOptionId;
  final Value<bool> isCorrect;
  final Value<int> rowid;
  const TestSessionAnswersCompanion({
    this.sessionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedOptionId = const Value.absent(),
    this.correctOptionId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestSessionAnswersCompanion.insert({
    required int sessionId,
    required String questionId,
    this.selectedOptionId = const Value.absent(),
    required String correctOptionId,
    required bool isCorrect,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       questionId = Value(questionId),
       correctOptionId = Value(correctOptionId),
       isCorrect = Value(isCorrect);
  static Insertable<TestSessionAnswer> custom({
    Expression<int>? sessionId,
    Expression<String>? questionId,
    Expression<String>? selectedOptionId,
    Expression<String>? correctOptionId,
    Expression<bool>? isCorrect,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (questionId != null) 'question_id': questionId,
      if (selectedOptionId != null) 'selected_option_id': selectedOptionId,
      if (correctOptionId != null) 'correct_option_id': correctOptionId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestSessionAnswersCompanion copyWith({
    Value<int>? sessionId,
    Value<String>? questionId,
    Value<String?>? selectedOptionId,
    Value<String>? correctOptionId,
    Value<bool>? isCorrect,
    Value<int>? rowid,
  }) {
    return TestSessionAnswersCompanion(
      sessionId: sessionId ?? this.sessionId,
      questionId: questionId ?? this.questionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      correctOptionId: correctOptionId ?? this.correctOptionId,
      isCorrect: isCorrect ?? this.isCorrect,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (selectedOptionId.present) {
      map['selected_option_id'] = Variable<String>(selectedOptionId.value);
    }
    if (correctOptionId.present) {
      map['correct_option_id'] = Variable<String>(correctOptionId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestSessionAnswersCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOptionId: $selectedOptionId, ')
          ..write('correctOptionId: $correctOptionId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PracticeProgressTable practiceProgress = $PracticeProgressTable(
    this,
  );
  late final $PracticeAnswersTable practiceAnswers = $PracticeAnswersTable(
    this,
  );
  late final $FavoriteQuestionsTable favoriteQuestions =
      $FavoriteQuestionsTable(this);
  late final $FavoriteSentencesTable favoriteSentences =
      $FavoriteSentencesTable(this);
  late final $TestSessionsTable testSessions = $TestSessionsTable(this);
  late final $TestSessionAnswersTable testSessionAnswers =
      $TestSessionAnswersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    practiceProgress,
    practiceAnswers,
    favoriteQuestions,
    favoriteSentences,
    testSessions,
    testSessionAnswers,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'test_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('test_session_answers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PracticeProgressTableCreateCompanionBuilder =
    PracticeProgressCompanion Function({
      required String questionId,
      Value<int> lastPositionMs,
      Value<String> lastContentMode,
      Value<int> practiceCount,
      Value<bool> completed,
      required int lastPracticedAtUtc,
      Value<int> rowid,
    });
typedef $$PracticeProgressTableUpdateCompanionBuilder =
    PracticeProgressCompanion Function({
      Value<String> questionId,
      Value<int> lastPositionMs,
      Value<String> lastContentMode,
      Value<int> practiceCount,
      Value<bool> completed,
      Value<int> lastPracticedAtUtc,
      Value<int> rowid,
    });

class $$PracticeProgressTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeProgressTable> {
  $$PracticeProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastContentMode => $composableBuilder(
    column: $table.lastContentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practiceCount => $composableBuilder(
    column: $table.practiceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPracticedAtUtc => $composableBuilder(
    column: $table.lastPracticedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PracticeProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeProgressTable> {
  $$PracticeProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastContentMode => $composableBuilder(
    column: $table.lastContentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practiceCount => $composableBuilder(
    column: $table.practiceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPracticedAtUtc => $composableBuilder(
    column: $table.lastPracticedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeProgressTable> {
  $$PracticeProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastContentMode => $composableBuilder(
    column: $table.lastContentMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practiceCount => $composableBuilder(
    column: $table.practiceCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get lastPracticedAtUtc => $composableBuilder(
    column: $table.lastPracticedAtUtc,
    builder: (column) => column,
  );
}

class $$PracticeProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeProgressTable,
          PracticeProgressData,
          $$PracticeProgressTableFilterComposer,
          $$PracticeProgressTableOrderingComposer,
          $$PracticeProgressTableAnnotationComposer,
          $$PracticeProgressTableCreateCompanionBuilder,
          $$PracticeProgressTableUpdateCompanionBuilder,
          (
            PracticeProgressData,
            BaseReferences<
              _$AppDatabase,
              $PracticeProgressTable,
              PracticeProgressData
            >,
          ),
          PracticeProgressData,
          PrefetchHooks Function()
        > {
  $$PracticeProgressTableTableManager(
    _$AppDatabase db,
    $PracticeProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<String> lastContentMode = const Value.absent(),
                Value<int> practiceCount = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> lastPracticedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeProgressCompanion(
                questionId: questionId,
                lastPositionMs: lastPositionMs,
                lastContentMode: lastContentMode,
                practiceCount: practiceCount,
                completed: completed,
                lastPracticedAtUtc: lastPracticedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                Value<int> lastPositionMs = const Value.absent(),
                Value<String> lastContentMode = const Value.absent(),
                Value<int> practiceCount = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                required int lastPracticedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => PracticeProgressCompanion.insert(
                questionId: questionId,
                lastPositionMs: lastPositionMs,
                lastContentMode: lastContentMode,
                practiceCount: practiceCount,
                completed: completed,
                lastPracticedAtUtc: lastPracticedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeProgressTable,
      PracticeProgressData,
      $$PracticeProgressTableFilterComposer,
      $$PracticeProgressTableOrderingComposer,
      $$PracticeProgressTableAnnotationComposer,
      $$PracticeProgressTableCreateCompanionBuilder,
      $$PracticeProgressTableUpdateCompanionBuilder,
      (
        PracticeProgressData,
        BaseReferences<
          _$AppDatabase,
          $PracticeProgressTable,
          PracticeProgressData
        >,
      ),
      PracticeProgressData,
      PrefetchHooks Function()
    >;
typedef $$PracticeAnswersTableCreateCompanionBuilder =
    PracticeAnswersCompanion Function({
      required String questionId,
      required String selectedOptionId,
      required bool isCorrect,
      Value<int> attemptCount,
      required int answeredAtUtc,
      Value<int> rowid,
    });
typedef $$PracticeAnswersTableUpdateCompanionBuilder =
    PracticeAnswersCompanion Function({
      Value<String> questionId,
      Value<String> selectedOptionId,
      Value<bool> isCorrect,
      Value<int> attemptCount,
      Value<int> answeredAtUtc,
      Value<int> rowid,
    });

class $$PracticeAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedOptionId => $composableBuilder(
    column: $table.selectedOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAtUtc => $composableBuilder(
    column: $table.answeredAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PracticeAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedOptionId => $composableBuilder(
    column: $table.selectedOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAtUtc => $composableBuilder(
    column: $table.answeredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedOptionId => $composableBuilder(
    column: $table.selectedOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredAtUtc => $composableBuilder(
    column: $table.answeredAtUtc,
    builder: (column) => column,
  );
}

class $$PracticeAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeAnswersTable,
          PracticeAnswer,
          $$PracticeAnswersTableFilterComposer,
          $$PracticeAnswersTableOrderingComposer,
          $$PracticeAnswersTableAnnotationComposer,
          $$PracticeAnswersTableCreateCompanionBuilder,
          $$PracticeAnswersTableUpdateCompanionBuilder,
          (
            PracticeAnswer,
            BaseReferences<
              _$AppDatabase,
              $PracticeAnswersTable,
              PracticeAnswer
            >,
          ),
          PracticeAnswer,
          PrefetchHooks Function()
        > {
  $$PracticeAnswersTableTableManager(
    _$AppDatabase db,
    $PracticeAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<String> selectedOptionId = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> answeredAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeAnswersCompanion(
                questionId: questionId,
                selectedOptionId: selectedOptionId,
                isCorrect: isCorrect,
                attemptCount: attemptCount,
                answeredAtUtc: answeredAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required String selectedOptionId,
                required bool isCorrect,
                Value<int> attemptCount = const Value.absent(),
                required int answeredAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => PracticeAnswersCompanion.insert(
                questionId: questionId,
                selectedOptionId: selectedOptionId,
                isCorrect: isCorrect,
                attemptCount: attemptCount,
                answeredAtUtc: answeredAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeAnswersTable,
      PracticeAnswer,
      $$PracticeAnswersTableFilterComposer,
      $$PracticeAnswersTableOrderingComposer,
      $$PracticeAnswersTableAnnotationComposer,
      $$PracticeAnswersTableCreateCompanionBuilder,
      $$PracticeAnswersTableUpdateCompanionBuilder,
      (
        PracticeAnswer,
        BaseReferences<_$AppDatabase, $PracticeAnswersTable, PracticeAnswer>,
      ),
      PracticeAnswer,
      PrefetchHooks Function()
    >;
typedef $$FavoriteQuestionsTableCreateCompanionBuilder =
    FavoriteQuestionsCompanion Function({
      required String questionId,
      required int createdAtUtc,
      Value<int> rowid,
    });
typedef $$FavoriteQuestionsTableUpdateCompanionBuilder =
    FavoriteQuestionsCompanion Function({
      Value<String> questionId,
      Value<int> createdAtUtc,
      Value<int> rowid,
    });

class $$FavoriteQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteQuestionsTable> {
  $$FavoriteQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteQuestionsTable> {
  $$FavoriteQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteQuestionsTable> {
  $$FavoriteQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$FavoriteQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteQuestionsTable,
          FavoriteQuestion,
          $$FavoriteQuestionsTableFilterComposer,
          $$FavoriteQuestionsTableOrderingComposer,
          $$FavoriteQuestionsTableAnnotationComposer,
          $$FavoriteQuestionsTableCreateCompanionBuilder,
          $$FavoriteQuestionsTableUpdateCompanionBuilder,
          (
            FavoriteQuestion,
            BaseReferences<
              _$AppDatabase,
              $FavoriteQuestionsTable,
              FavoriteQuestion
            >,
          ),
          FavoriteQuestion,
          PrefetchHooks Function()
        > {
  $$FavoriteQuestionsTableTableManager(
    _$AppDatabase db,
    $FavoriteQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteQuestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteQuestionsCompanion(
                questionId: questionId,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required int createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteQuestionsCompanion.insert(
                questionId: questionId,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteQuestionsTable,
      FavoriteQuestion,
      $$FavoriteQuestionsTableFilterComposer,
      $$FavoriteQuestionsTableOrderingComposer,
      $$FavoriteQuestionsTableAnnotationComposer,
      $$FavoriteQuestionsTableCreateCompanionBuilder,
      $$FavoriteQuestionsTableUpdateCompanionBuilder,
      (
        FavoriteQuestion,
        BaseReferences<
          _$AppDatabase,
          $FavoriteQuestionsTable,
          FavoriteQuestion
        >,
      ),
      FavoriteQuestion,
      PrefetchHooks Function()
    >;
typedef $$FavoriteSentencesTableCreateCompanionBuilder =
    FavoriteSentencesCompanion Function({
      required String sentenceId,
      required String questionId,
      required int createdAtUtc,
      Value<int> rowid,
    });
typedef $$FavoriteSentencesTableUpdateCompanionBuilder =
    FavoriteSentencesCompanion Function({
      Value<String> sentenceId,
      Value<String> questionId,
      Value<int> createdAtUtc,
      Value<int> rowid,
    });

class $$FavoriteSentencesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteSentencesTable> {
  $$FavoriteSentencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sentenceId => $composableBuilder(
    column: $table.sentenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteSentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteSentencesTable> {
  $$FavoriteSentencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sentenceId => $composableBuilder(
    column: $table.sentenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteSentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteSentencesTable> {
  $$FavoriteSentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sentenceId => $composableBuilder(
    column: $table.sentenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$FavoriteSentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteSentencesTable,
          FavoriteSentence,
          $$FavoriteSentencesTableFilterComposer,
          $$FavoriteSentencesTableOrderingComposer,
          $$FavoriteSentencesTableAnnotationComposer,
          $$FavoriteSentencesTableCreateCompanionBuilder,
          $$FavoriteSentencesTableUpdateCompanionBuilder,
          (
            FavoriteSentence,
            BaseReferences<
              _$AppDatabase,
              $FavoriteSentencesTable,
              FavoriteSentence
            >,
          ),
          FavoriteSentence,
          PrefetchHooks Function()
        > {
  $$FavoriteSentencesTableTableManager(
    _$AppDatabase db,
    $FavoriteSentencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteSentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteSentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteSentencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sentenceId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteSentencesCompanion(
                sentenceId: sentenceId,
                questionId: questionId,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sentenceId,
                required String questionId,
                required int createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteSentencesCompanion.insert(
                sentenceId: sentenceId,
                questionId: questionId,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteSentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteSentencesTable,
      FavoriteSentence,
      $$FavoriteSentencesTableFilterComposer,
      $$FavoriteSentencesTableOrderingComposer,
      $$FavoriteSentencesTableAnnotationComposer,
      $$FavoriteSentencesTableCreateCompanionBuilder,
      $$FavoriteSentencesTableUpdateCompanionBuilder,
      (
        FavoriteSentence,
        BaseReferences<
          _$AppDatabase,
          $FavoriteSentencesTable,
          FavoriteSentence
        >,
      ),
      FavoriteSentence,
      PrefetchHooks Function()
    >;
typedef $$TestSessionsTableCreateCompanionBuilder =
    TestSessionsCompanion Function({
      Value<int> id,
      required String examId,
      required String status,
      required int startedAtUtc,
      Value<int?> submittedAtUtc,
      Value<int> durationMs,
      Value<int> totalCount,
      Value<int> correctCount,
    });
typedef $$TestSessionsTableUpdateCompanionBuilder =
    TestSessionsCompanion Function({
      Value<int> id,
      Value<String> examId,
      Value<String> status,
      Value<int> startedAtUtc,
      Value<int?> submittedAtUtc,
      Value<int> durationMs,
      Value<int> totalCount,
      Value<int> correctCount,
    });

final class $$TestSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $TestSessionsTable, TestSession> {
  $$TestSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TestSessionAnswersTable, List<TestSessionAnswer>>
  _testSessionAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.testSessionAnswers,
        aliasName: 'test_sessions__id__test_session_answers__session_id',
      );

  $$TestSessionAnswersTableProcessedTableManager get testSessionAnswersRefs {
    final manager = $$TestSessionAnswersTableTableManager(
      $_db,
      $_db.testSessionAnswers,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _testSessionAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TestSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get submittedAtUtc => $composableBuilder(
    column: $table.submittedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> testSessionAnswersRefs(
    Expression<bool> Function($$TestSessionAnswersTableFilterComposer f) f,
  ) {
    final $$TestSessionAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testSessionAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionAnswersTableFilterComposer(
            $db: $db,
            $table: $db.testSessionAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get submittedAtUtc => $composableBuilder(
    column: $table.submittedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get examId =>
      $composableBuilder(column: $table.examId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get submittedAtUtc => $composableBuilder(
    column: $table.submittedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  Expression<T> testSessionAnswersRefs<T extends Object>(
    Expression<T> Function($$TestSessionAnswersTableAnnotationComposer a) f,
  ) {
    final $$TestSessionAnswersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.testSessionAnswers,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestSessionAnswersTableAnnotationComposer(
                $db: $db,
                $table: $db.testSessionAnswers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TestSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestSessionsTable,
          TestSession,
          $$TestSessionsTableFilterComposer,
          $$TestSessionsTableOrderingComposer,
          $$TestSessionsTableAnnotationComposer,
          $$TestSessionsTableCreateCompanionBuilder,
          $$TestSessionsTableUpdateCompanionBuilder,
          (TestSession, $$TestSessionsTableReferences),
          TestSession,
          PrefetchHooks Function({bool testSessionAnswersRefs})
        > {
  $$TestSessionsTableTableManager(_$AppDatabase db, $TestSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAtUtc = const Value.absent(),
                Value<int?> submittedAtUtc = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
              }) => TestSessionsCompanion(
                id: id,
                examId: examId,
                status: status,
                startedAtUtc: startedAtUtc,
                submittedAtUtc: submittedAtUtc,
                durationMs: durationMs,
                totalCount: totalCount,
                correctCount: correctCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String examId,
                required String status,
                required int startedAtUtc,
                Value<int?> submittedAtUtc = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
              }) => TestSessionsCompanion.insert(
                id: id,
                examId: examId,
                status: status,
                startedAtUtc: startedAtUtc,
                submittedAtUtc: submittedAtUtc,
                durationMs: durationMs,
                totalCount: totalCount,
                correctCount: correctCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({testSessionAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (testSessionAnswersRefs) db.testSessionAnswers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testSessionAnswersRefs)
                    await $_getPrefetchedData<
                      TestSession,
                      $TestSessionsTable,
                      TestSessionAnswer
                    >(
                      currentTable: table,
                      referencedTable: $$TestSessionsTableReferences
                          ._testSessionAnswersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TestSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).testSessionAnswersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TestSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestSessionsTable,
      TestSession,
      $$TestSessionsTableFilterComposer,
      $$TestSessionsTableOrderingComposer,
      $$TestSessionsTableAnnotationComposer,
      $$TestSessionsTableCreateCompanionBuilder,
      $$TestSessionsTableUpdateCompanionBuilder,
      (TestSession, $$TestSessionsTableReferences),
      TestSession,
      PrefetchHooks Function({bool testSessionAnswersRefs})
    >;
typedef $$TestSessionAnswersTableCreateCompanionBuilder =
    TestSessionAnswersCompanion Function({
      required int sessionId,
      required String questionId,
      Value<String?> selectedOptionId,
      required String correctOptionId,
      required bool isCorrect,
      Value<int> rowid,
    });
typedef $$TestSessionAnswersTableUpdateCompanionBuilder =
    TestSessionAnswersCompanion Function({
      Value<int> sessionId,
      Value<String> questionId,
      Value<String?> selectedOptionId,
      Value<String> correctOptionId,
      Value<bool> isCorrect,
      Value<int> rowid,
    });

final class $$TestSessionAnswersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TestSessionAnswersTable,
          TestSessionAnswer
        > {
  $$TestSessionAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TestSessionsTable _sessionIdTable(_$AppDatabase db) => db.testSessions
      .createAlias('test_session_answers__session_id__test_sessions__id');

  $$TestSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TestSessionsTableTableManager(
      $_db,
      $_db.testSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TestSessionAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $TestSessionAnswersTable> {
  $$TestSessionAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedOptionId => $composableBuilder(
    column: $table.selectedOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctOptionId => $composableBuilder(
    column: $table.correctOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  $$TestSessionsTableFilterComposer get sessionId {
    final $$TestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestSessionAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $TestSessionAnswersTable> {
  $$TestSessionAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedOptionId => $composableBuilder(
    column: $table.selectedOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctOptionId => $composableBuilder(
    column: $table.correctOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  $$TestSessionsTableOrderingComposer get sessionId {
    final $$TestSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestSessionAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestSessionAnswersTable> {
  $$TestSessionAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedOptionId => $composableBuilder(
    column: $table.selectedOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctOptionId => $composableBuilder(
    column: $table.correctOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  $$TestSessionsTableAnnotationComposer get sessionId {
    final $$TestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestSessionAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestSessionAnswersTable,
          TestSessionAnswer,
          $$TestSessionAnswersTableFilterComposer,
          $$TestSessionAnswersTableOrderingComposer,
          $$TestSessionAnswersTableAnnotationComposer,
          $$TestSessionAnswersTableCreateCompanionBuilder,
          $$TestSessionAnswersTableUpdateCompanionBuilder,
          (TestSessionAnswer, $$TestSessionAnswersTableReferences),
          TestSessionAnswer,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TestSessionAnswersTableTableManager(
    _$AppDatabase db,
    $TestSessionAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestSessionAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestSessionAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestSessionAnswersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String?> selectedOptionId = const Value.absent(),
                Value<String> correctOptionId = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestSessionAnswersCompanion(
                sessionId: sessionId,
                questionId: questionId,
                selectedOptionId: selectedOptionId,
                correctOptionId: correctOptionId,
                isCorrect: isCorrect,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sessionId,
                required String questionId,
                Value<String?> selectedOptionId = const Value.absent(),
                required String correctOptionId,
                required bool isCorrect,
                Value<int> rowid = const Value.absent(),
              }) => TestSessionAnswersCompanion.insert(
                sessionId: sessionId,
                questionId: questionId,
                selectedOptionId: selectedOptionId,
                correctOptionId: correctOptionId,
                isCorrect: isCorrect,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestSessionAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$TestSessionAnswersTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$TestSessionAnswersTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TestSessionAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestSessionAnswersTable,
      TestSessionAnswer,
      $$TestSessionAnswersTableFilterComposer,
      $$TestSessionAnswersTableOrderingComposer,
      $$TestSessionAnswersTableAnnotationComposer,
      $$TestSessionAnswersTableCreateCompanionBuilder,
      $$TestSessionAnswersTableUpdateCompanionBuilder,
      (TestSessionAnswer, $$TestSessionAnswersTableReferences),
      TestSessionAnswer,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PracticeProgressTableTableManager get practiceProgress =>
      $$PracticeProgressTableTableManager(_db, _db.practiceProgress);
  $$PracticeAnswersTableTableManager get practiceAnswers =>
      $$PracticeAnswersTableTableManager(_db, _db.practiceAnswers);
  $$FavoriteQuestionsTableTableManager get favoriteQuestions =>
      $$FavoriteQuestionsTableTableManager(_db, _db.favoriteQuestions);
  $$FavoriteSentencesTableTableManager get favoriteSentences =>
      $$FavoriteSentencesTableTableManager(_db, _db.favoriteSentences);
  $$TestSessionsTableTableManager get testSessions =>
      $$TestSessionsTableTableManager(_db, _db.testSessions);
  $$TestSessionAnswersTableTableManager get testSessionAnswers =>
      $$TestSessionAnswersTableTableManager(_db, _db.testSessionAnswers);
}
