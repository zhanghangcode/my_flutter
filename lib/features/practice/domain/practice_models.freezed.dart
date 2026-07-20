// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practice_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExamCatalog {

 int get schemaVersion; List<ExamSummary> get exams;
/// Create a copy of ExamCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamCatalogCopyWith<ExamCatalog> get copyWith => _$ExamCatalogCopyWithImpl<ExamCatalog>(this as ExamCatalog, _$identity);

  /// Serializes this ExamCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamCatalog&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other.exams, exams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(exams));

@override
String toString() {
  return 'ExamCatalog(schemaVersion: $schemaVersion, exams: $exams)';
}


}

/// @nodoc
abstract mixin class $ExamCatalogCopyWith<$Res>  {
  factory $ExamCatalogCopyWith(ExamCatalog value, $Res Function(ExamCatalog) _then) = _$ExamCatalogCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, List<ExamSummary> exams
});




}
/// @nodoc
class _$ExamCatalogCopyWithImpl<$Res>
    implements $ExamCatalogCopyWith<$Res> {
  _$ExamCatalogCopyWithImpl(this._self, this._then);

  final ExamCatalog _self;
  final $Res Function(ExamCatalog) _then;

/// Create a copy of ExamCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? exams = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,exams: null == exams ? _self.exams : exams // ignore: cast_nullable_to_non_nullable
as List<ExamSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamCatalog].
extension ExamCatalogPatterns on ExamCatalog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamCatalog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamCatalog value)  $default,){
final _that = this;
switch (_that) {
case _ExamCatalog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _ExamCatalog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  List<ExamSummary> exams)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamCatalog() when $default != null:
return $default(_that.schemaVersion,_that.exams);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  List<ExamSummary> exams)  $default,) {final _that = this;
switch (_that) {
case _ExamCatalog():
return $default(_that.schemaVersion,_that.exams);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  List<ExamSummary> exams)?  $default,) {final _that = this;
switch (_that) {
case _ExamCatalog() when $default != null:
return $default(_that.schemaVersion,_that.exams);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExamCatalog implements ExamCatalog {
  const _ExamCatalog({required this.schemaVersion, required final  List<ExamSummary> exams}): _exams = exams;
  factory _ExamCatalog.fromJson(Map<String, dynamic> json) => _$ExamCatalogFromJson(json);

@override final  int schemaVersion;
 final  List<ExamSummary> _exams;
@override List<ExamSummary> get exams {
  if (_exams is EqualUnmodifiableListView) return _exams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exams);
}


/// Create a copy of ExamCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamCatalogCopyWith<_ExamCatalog> get copyWith => __$ExamCatalogCopyWithImpl<_ExamCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExamCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamCatalog&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other._exams, _exams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(_exams));

@override
String toString() {
  return 'ExamCatalog(schemaVersion: $schemaVersion, exams: $exams)';
}


}

/// @nodoc
abstract mixin class _$ExamCatalogCopyWith<$Res> implements $ExamCatalogCopyWith<$Res> {
  factory _$ExamCatalogCopyWith(_ExamCatalog value, $Res Function(_ExamCatalog) _then) = __$ExamCatalogCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, List<ExamSummary> exams
});




}
/// @nodoc
class __$ExamCatalogCopyWithImpl<$Res>
    implements _$ExamCatalogCopyWith<$Res> {
  __$ExamCatalogCopyWithImpl(this._self, this._then);

  final _ExamCatalog _self;
  final $Res Function(_ExamCatalog) _then;

/// Create a copy of ExamCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? exams = null,}) {
  return _then(_ExamCatalog(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,exams: null == exams ? _self._exams : exams // ignore: cast_nullable_to_non_nullable
as List<ExamSummary>,
  ));
}


}


/// @nodoc
mixin _$ExamSummary {

 String get id; int? get year; int? get month; String get titleJa; String get audioQuality; int get questionCount; String get resourcePath; bool get supportsTest; AudioDeliveryMode get audioDeliveryMode; int get audioResourceVersion;
/// Create a copy of ExamSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamSummaryCopyWith<ExamSummary> get copyWith => _$ExamSummaryCopyWithImpl<ExamSummary>(this as ExamSummary, _$identity);

  /// Serializes this ExamSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.titleJa, titleJa) || other.titleJa == titleJa)&&(identical(other.audioQuality, audioQuality) || other.audioQuality == audioQuality)&&(identical(other.questionCount, questionCount) || other.questionCount == questionCount)&&(identical(other.resourcePath, resourcePath) || other.resourcePath == resourcePath)&&(identical(other.supportsTest, supportsTest) || other.supportsTest == supportsTest)&&(identical(other.audioDeliveryMode, audioDeliveryMode) || other.audioDeliveryMode == audioDeliveryMode)&&(identical(other.audioResourceVersion, audioResourceVersion) || other.audioResourceVersion == audioResourceVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,month,titleJa,audioQuality,questionCount,resourcePath,supportsTest,audioDeliveryMode,audioResourceVersion);

@override
String toString() {
  return 'ExamSummary(id: $id, year: $year, month: $month, titleJa: $titleJa, audioQuality: $audioQuality, questionCount: $questionCount, resourcePath: $resourcePath, supportsTest: $supportsTest, audioDeliveryMode: $audioDeliveryMode, audioResourceVersion: $audioResourceVersion)';
}


}

/// @nodoc
abstract mixin class $ExamSummaryCopyWith<$Res>  {
  factory $ExamSummaryCopyWith(ExamSummary value, $Res Function(ExamSummary) _then) = _$ExamSummaryCopyWithImpl;
@useResult
$Res call({
 String id, int? year, int? month, String titleJa, String audioQuality, int questionCount, String resourcePath, bool supportsTest, AudioDeliveryMode audioDeliveryMode, int audioResourceVersion
});




}
/// @nodoc
class _$ExamSummaryCopyWithImpl<$Res>
    implements $ExamSummaryCopyWith<$Res> {
  _$ExamSummaryCopyWithImpl(this._self, this._then);

  final ExamSummary _self;
  final $Res Function(ExamSummary) _then;

/// Create a copy of ExamSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? year = freezed,Object? month = freezed,Object? titleJa = null,Object? audioQuality = null,Object? questionCount = null,Object? resourcePath = null,Object? supportsTest = null,Object? audioDeliveryMode = null,Object? audioResourceVersion = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,titleJa: null == titleJa ? _self.titleJa : titleJa // ignore: cast_nullable_to_non_nullable
as String,audioQuality: null == audioQuality ? _self.audioQuality : audioQuality // ignore: cast_nullable_to_non_nullable
as String,questionCount: null == questionCount ? _self.questionCount : questionCount // ignore: cast_nullable_to_non_nullable
as int,resourcePath: null == resourcePath ? _self.resourcePath : resourcePath // ignore: cast_nullable_to_non_nullable
as String,supportsTest: null == supportsTest ? _self.supportsTest : supportsTest // ignore: cast_nullable_to_non_nullable
as bool,audioDeliveryMode: null == audioDeliveryMode ? _self.audioDeliveryMode : audioDeliveryMode // ignore: cast_nullable_to_non_nullable
as AudioDeliveryMode,audioResourceVersion: null == audioResourceVersion ? _self.audioResourceVersion : audioResourceVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamSummary].
extension ExamSummaryPatterns on ExamSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamSummary value)  $default,){
final _that = this;
switch (_that) {
case _ExamSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ExamSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int? year,  int? month,  String titleJa,  String audioQuality,  int questionCount,  String resourcePath,  bool supportsTest,  AudioDeliveryMode audioDeliveryMode,  int audioResourceVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamSummary() when $default != null:
return $default(_that.id,_that.year,_that.month,_that.titleJa,_that.audioQuality,_that.questionCount,_that.resourcePath,_that.supportsTest,_that.audioDeliveryMode,_that.audioResourceVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int? year,  int? month,  String titleJa,  String audioQuality,  int questionCount,  String resourcePath,  bool supportsTest,  AudioDeliveryMode audioDeliveryMode,  int audioResourceVersion)  $default,) {final _that = this;
switch (_that) {
case _ExamSummary():
return $default(_that.id,_that.year,_that.month,_that.titleJa,_that.audioQuality,_that.questionCount,_that.resourcePath,_that.supportsTest,_that.audioDeliveryMode,_that.audioResourceVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int? year,  int? month,  String titleJa,  String audioQuality,  int questionCount,  String resourcePath,  bool supportsTest,  AudioDeliveryMode audioDeliveryMode,  int audioResourceVersion)?  $default,) {final _that = this;
switch (_that) {
case _ExamSummary() when $default != null:
return $default(_that.id,_that.year,_that.month,_that.titleJa,_that.audioQuality,_that.questionCount,_that.resourcePath,_that.supportsTest,_that.audioDeliveryMode,_that.audioResourceVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExamSummary implements ExamSummary {
  const _ExamSummary({required this.id, this.year, this.month, required this.titleJa, required this.audioQuality, required this.questionCount, required this.resourcePath, required this.supportsTest, this.audioDeliveryMode = AudioDeliveryMode.bundled, this.audioResourceVersion = 1});
  factory _ExamSummary.fromJson(Map<String, dynamic> json) => _$ExamSummaryFromJson(json);

@override final  String id;
@override final  int? year;
@override final  int? month;
@override final  String titleJa;
@override final  String audioQuality;
@override final  int questionCount;
@override final  String resourcePath;
@override final  bool supportsTest;
@override@JsonKey() final  AudioDeliveryMode audioDeliveryMode;
@override@JsonKey() final  int audioResourceVersion;

/// Create a copy of ExamSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamSummaryCopyWith<_ExamSummary> get copyWith => __$ExamSummaryCopyWithImpl<_ExamSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExamSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.titleJa, titleJa) || other.titleJa == titleJa)&&(identical(other.audioQuality, audioQuality) || other.audioQuality == audioQuality)&&(identical(other.questionCount, questionCount) || other.questionCount == questionCount)&&(identical(other.resourcePath, resourcePath) || other.resourcePath == resourcePath)&&(identical(other.supportsTest, supportsTest) || other.supportsTest == supportsTest)&&(identical(other.audioDeliveryMode, audioDeliveryMode) || other.audioDeliveryMode == audioDeliveryMode)&&(identical(other.audioResourceVersion, audioResourceVersion) || other.audioResourceVersion == audioResourceVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,month,titleJa,audioQuality,questionCount,resourcePath,supportsTest,audioDeliveryMode,audioResourceVersion);

@override
String toString() {
  return 'ExamSummary(id: $id, year: $year, month: $month, titleJa: $titleJa, audioQuality: $audioQuality, questionCount: $questionCount, resourcePath: $resourcePath, supportsTest: $supportsTest, audioDeliveryMode: $audioDeliveryMode, audioResourceVersion: $audioResourceVersion)';
}


}

/// @nodoc
abstract mixin class _$ExamSummaryCopyWith<$Res> implements $ExamSummaryCopyWith<$Res> {
  factory _$ExamSummaryCopyWith(_ExamSummary value, $Res Function(_ExamSummary) _then) = __$ExamSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, int? year, int? month, String titleJa, String audioQuality, int questionCount, String resourcePath, bool supportsTest, AudioDeliveryMode audioDeliveryMode, int audioResourceVersion
});




}
/// @nodoc
class __$ExamSummaryCopyWithImpl<$Res>
    implements _$ExamSummaryCopyWith<$Res> {
  __$ExamSummaryCopyWithImpl(this._self, this._then);

  final _ExamSummary _self;
  final $Res Function(_ExamSummary) _then;

/// Create a copy of ExamSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? year = freezed,Object? month = freezed,Object? titleJa = null,Object? audioQuality = null,Object? questionCount = null,Object? resourcePath = null,Object? supportsTest = null,Object? audioDeliveryMode = null,Object? audioResourceVersion = null,}) {
  return _then(_ExamSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,titleJa: null == titleJa ? _self.titleJa : titleJa // ignore: cast_nullable_to_non_nullable
as String,audioQuality: null == audioQuality ? _self.audioQuality : audioQuality // ignore: cast_nullable_to_non_nullable
as String,questionCount: null == questionCount ? _self.questionCount : questionCount // ignore: cast_nullable_to_non_nullable
as int,resourcePath: null == resourcePath ? _self.resourcePath : resourcePath // ignore: cast_nullable_to_non_nullable
as String,supportsTest: null == supportsTest ? _self.supportsTest : supportsTest // ignore: cast_nullable_to_non_nullable
as bool,audioDeliveryMode: null == audioDeliveryMode ? _self.audioDeliveryMode : audioDeliveryMode // ignore: cast_nullable_to_non_nullable
as AudioDeliveryMode,audioResourceVersion: null == audioResourceVersion ? _self.audioResourceVersion : audioResourceVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExamResource {

 int get schemaVersion; String get id; String get titleJa; List<Question> get questions;
/// Create a copy of ExamResource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamResourceCopyWith<ExamResource> get copyWith => _$ExamResourceCopyWithImpl<ExamResource>(this as ExamResource, _$identity);

  /// Serializes this ExamResource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamResource&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.titleJa, titleJa) || other.titleJa == titleJa)&&const DeepCollectionEquality().equals(other.questions, questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,id,titleJa,const DeepCollectionEquality().hash(questions));

@override
String toString() {
  return 'ExamResource(schemaVersion: $schemaVersion, id: $id, titleJa: $titleJa, questions: $questions)';
}


}

/// @nodoc
abstract mixin class $ExamResourceCopyWith<$Res>  {
  factory $ExamResourceCopyWith(ExamResource value, $Res Function(ExamResource) _then) = _$ExamResourceCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String id, String titleJa, List<Question> questions
});




}
/// @nodoc
class _$ExamResourceCopyWithImpl<$Res>
    implements $ExamResourceCopyWith<$Res> {
  _$ExamResourceCopyWithImpl(this._self, this._then);

  final ExamResource _self;
  final $Res Function(ExamResource) _then;

/// Create a copy of ExamResource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? id = null,Object? titleJa = null,Object? questions = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleJa: null == titleJa ? _self.titleJa : titleJa // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamResource].
extension ExamResourcePatterns on ExamResource {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamResource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamResource() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamResource value)  $default,){
final _that = this;
switch (_that) {
case _ExamResource():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamResource value)?  $default,){
final _that = this;
switch (_that) {
case _ExamResource() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String titleJa,  List<Question> questions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamResource() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.titleJa,_that.questions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String titleJa,  List<Question> questions)  $default,) {final _that = this;
switch (_that) {
case _ExamResource():
return $default(_that.schemaVersion,_that.id,_that.titleJa,_that.questions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String id,  String titleJa,  List<Question> questions)?  $default,) {final _that = this;
switch (_that) {
case _ExamResource() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.titleJa,_that.questions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExamResource implements ExamResource {
  const _ExamResource({required this.schemaVersion, required this.id, required this.titleJa, required final  List<Question> questions}): _questions = questions;
  factory _ExamResource.fromJson(Map<String, dynamic> json) => _$ExamResourceFromJson(json);

@override final  int schemaVersion;
@override final  String id;
@override final  String titleJa;
 final  List<Question> _questions;
@override List<Question> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}


/// Create a copy of ExamResource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamResourceCopyWith<_ExamResource> get copyWith => __$ExamResourceCopyWithImpl<_ExamResource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExamResourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamResource&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.titleJa, titleJa) || other.titleJa == titleJa)&&const DeepCollectionEquality().equals(other._questions, _questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,id,titleJa,const DeepCollectionEquality().hash(_questions));

@override
String toString() {
  return 'ExamResource(schemaVersion: $schemaVersion, id: $id, titleJa: $titleJa, questions: $questions)';
}


}

/// @nodoc
abstract mixin class _$ExamResourceCopyWith<$Res> implements $ExamResourceCopyWith<$Res> {
  factory _$ExamResourceCopyWith(_ExamResource value, $Res Function(_ExamResource) _then) = __$ExamResourceCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String id, String titleJa, List<Question> questions
});




}
/// @nodoc
class __$ExamResourceCopyWithImpl<$Res>
    implements _$ExamResourceCopyWith<$Res> {
  __$ExamResourceCopyWithImpl(this._self, this._then);

  final _ExamResource _self;
  final $Res Function(_ExamResource) _then;

/// Create a copy of ExamResource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? id = null,Object? titleJa = null,Object? questions = null,}) {
  return _then(_ExamResource(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleJa: null == titleJa ? _self.titleJa : titleJa // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,
  ));
}


}


/// @nodoc
mixin _$Question {

 String get id; String get examId; int get section; int get number; String get type; String get promptJa; List<AnswerOption> get options; String? get correctOptionId; String get audioAssetPath; List<TranscriptSentence> get sentences; QuestionExplanation? get explanation;
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionCopyWith<Question> get copyWith => _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Question&&(identical(other.id, id) || other.id == id)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.section, section) || other.section == section)&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type)&&(identical(other.promptJa, promptJa) || other.promptJa == promptJa)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.correctOptionId, correctOptionId) || other.correctOptionId == correctOptionId)&&(identical(other.audioAssetPath, audioAssetPath) || other.audioAssetPath == audioAssetPath)&&const DeepCollectionEquality().equals(other.sentences, sentences)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,examId,section,number,type,promptJa,const DeepCollectionEquality().hash(options),correctOptionId,audioAssetPath,const DeepCollectionEquality().hash(sentences),explanation);

@override
String toString() {
  return 'Question(id: $id, examId: $examId, section: $section, number: $number, type: $type, promptJa: $promptJa, options: $options, correctOptionId: $correctOptionId, audioAssetPath: $audioAssetPath, sentences: $sentences, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res>  {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) = _$QuestionCopyWithImpl;
@useResult
$Res call({
 String id, String examId, int section, int number, String type, String promptJa, List<AnswerOption> options, String? correctOptionId, String audioAssetPath, List<TranscriptSentence> sentences, QuestionExplanation? explanation
});


$QuestionExplanationCopyWith<$Res>? get explanation;

}
/// @nodoc
class _$QuestionCopyWithImpl<$Res>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? examId = null,Object? section = null,Object? number = null,Object? type = null,Object? promptJa = null,Object? options = null,Object? correctOptionId = freezed,Object? audioAssetPath = null,Object? sentences = null,Object? explanation = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,promptJa: null == promptJa ? _self.promptJa : promptJa // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<AnswerOption>,correctOptionId: freezed == correctOptionId ? _self.correctOptionId : correctOptionId // ignore: cast_nullable_to_non_nullable
as String?,audioAssetPath: null == audioAssetPath ? _self.audioAssetPath : audioAssetPath // ignore: cast_nullable_to_non_nullable
as String,sentences: null == sentences ? _self.sentences : sentences // ignore: cast_nullable_to_non_nullable
as List<TranscriptSentence>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as QuestionExplanation?,
  ));
}
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionExplanationCopyWith<$Res>? get explanation {
    if (_self.explanation == null) {
    return null;
  }

  return $QuestionExplanationCopyWith<$Res>(_self.explanation!, (value) {
    return _then(_self.copyWith(explanation: value));
  });
}
}


/// Adds pattern-matching-related methods to [Question].
extension QuestionPatterns on Question {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Question value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Question value)  $default,){
final _that = this;
switch (_that) {
case _Question():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Question value)?  $default,){
final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String examId,  int section,  int number,  String type,  String promptJa,  List<AnswerOption> options,  String? correctOptionId,  String audioAssetPath,  List<TranscriptSentence> sentences,  QuestionExplanation? explanation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.id,_that.examId,_that.section,_that.number,_that.type,_that.promptJa,_that.options,_that.correctOptionId,_that.audioAssetPath,_that.sentences,_that.explanation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String examId,  int section,  int number,  String type,  String promptJa,  List<AnswerOption> options,  String? correctOptionId,  String audioAssetPath,  List<TranscriptSentence> sentences,  QuestionExplanation? explanation)  $default,) {final _that = this;
switch (_that) {
case _Question():
return $default(_that.id,_that.examId,_that.section,_that.number,_that.type,_that.promptJa,_that.options,_that.correctOptionId,_that.audioAssetPath,_that.sentences,_that.explanation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String examId,  int section,  int number,  String type,  String promptJa,  List<AnswerOption> options,  String? correctOptionId,  String audioAssetPath,  List<TranscriptSentence> sentences,  QuestionExplanation? explanation)?  $default,) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.id,_that.examId,_that.section,_that.number,_that.type,_that.promptJa,_that.options,_that.correctOptionId,_that.audioAssetPath,_that.sentences,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Question implements Question {
  const _Question({required this.id, required this.examId, required this.section, required this.number, required this.type, required this.promptJa, required final  List<AnswerOption> options, this.correctOptionId, required this.audioAssetPath, required final  List<TranscriptSentence> sentences, this.explanation}): _options = options,_sentences = sentences;
  factory _Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

@override final  String id;
@override final  String examId;
@override final  int section;
@override final  int number;
@override final  String type;
@override final  String promptJa;
 final  List<AnswerOption> _options;
@override List<AnswerOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  String? correctOptionId;
@override final  String audioAssetPath;
 final  List<TranscriptSentence> _sentences;
@override List<TranscriptSentence> get sentences {
  if (_sentences is EqualUnmodifiableListView) return _sentences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sentences);
}

@override final  QuestionExplanation? explanation;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionCopyWith<_Question> get copyWith => __$QuestionCopyWithImpl<_Question>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Question&&(identical(other.id, id) || other.id == id)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.section, section) || other.section == section)&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type)&&(identical(other.promptJa, promptJa) || other.promptJa == promptJa)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.correctOptionId, correctOptionId) || other.correctOptionId == correctOptionId)&&(identical(other.audioAssetPath, audioAssetPath) || other.audioAssetPath == audioAssetPath)&&const DeepCollectionEquality().equals(other._sentences, _sentences)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,examId,section,number,type,promptJa,const DeepCollectionEquality().hash(_options),correctOptionId,audioAssetPath,const DeepCollectionEquality().hash(_sentences),explanation);

@override
String toString() {
  return 'Question(id: $id, examId: $examId, section: $section, number: $number, type: $type, promptJa: $promptJa, options: $options, correctOptionId: $correctOptionId, audioAssetPath: $audioAssetPath, sentences: $sentences, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class _$QuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory _$QuestionCopyWith(_Question value, $Res Function(_Question) _then) = __$QuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, String examId, int section, int number, String type, String promptJa, List<AnswerOption> options, String? correctOptionId, String audioAssetPath, List<TranscriptSentence> sentences, QuestionExplanation? explanation
});


@override $QuestionExplanationCopyWith<$Res>? get explanation;

}
/// @nodoc
class __$QuestionCopyWithImpl<$Res>
    implements _$QuestionCopyWith<$Res> {
  __$QuestionCopyWithImpl(this._self, this._then);

  final _Question _self;
  final $Res Function(_Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? examId = null,Object? section = null,Object? number = null,Object? type = null,Object? promptJa = null,Object? options = null,Object? correctOptionId = freezed,Object? audioAssetPath = null,Object? sentences = null,Object? explanation = freezed,}) {
  return _then(_Question(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,promptJa: null == promptJa ? _self.promptJa : promptJa // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<AnswerOption>,correctOptionId: freezed == correctOptionId ? _self.correctOptionId : correctOptionId // ignore: cast_nullable_to_non_nullable
as String?,audioAssetPath: null == audioAssetPath ? _self.audioAssetPath : audioAssetPath // ignore: cast_nullable_to_non_nullable
as String,sentences: null == sentences ? _self._sentences : sentences // ignore: cast_nullable_to_non_nullable
as List<TranscriptSentence>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as QuestionExplanation?,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionExplanationCopyWith<$Res>? get explanation {
    if (_self.explanation == null) {
    return null;
  }

  return $QuestionExplanationCopyWith<$Res>(_self.explanation!, (value) {
    return _then(_self.copyWith(explanation: value));
  });
}
}


/// @nodoc
mixin _$AnswerOption {

 String get id; int get label; String get textJa;
/// Create a copy of AnswerOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerOptionCopyWith<AnswerOption> get copyWith => _$AnswerOptionCopyWithImpl<AnswerOption>(this as AnswerOption, _$identity);

  /// Serializes this AnswerOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.textJa, textJa) || other.textJa == textJa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,textJa);

@override
String toString() {
  return 'AnswerOption(id: $id, label: $label, textJa: $textJa)';
}


}

/// @nodoc
abstract mixin class $AnswerOptionCopyWith<$Res>  {
  factory $AnswerOptionCopyWith(AnswerOption value, $Res Function(AnswerOption) _then) = _$AnswerOptionCopyWithImpl;
@useResult
$Res call({
 String id, int label, String textJa
});




}
/// @nodoc
class _$AnswerOptionCopyWithImpl<$Res>
    implements $AnswerOptionCopyWith<$Res> {
  _$AnswerOptionCopyWithImpl(this._self, this._then);

  final AnswerOption _self;
  final $Res Function(AnswerOption) _then;

/// Create a copy of AnswerOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? textJa = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as int,textJa: null == textJa ? _self.textJa : textJa // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnswerOption].
extension AnswerOptionPatterns on AnswerOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerOption value)  $default,){
final _that = this;
switch (_that) {
case _AnswerOption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerOption value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int label,  String textJa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerOption() when $default != null:
return $default(_that.id,_that.label,_that.textJa);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int label,  String textJa)  $default,) {final _that = this;
switch (_that) {
case _AnswerOption():
return $default(_that.id,_that.label,_that.textJa);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int label,  String textJa)?  $default,) {final _that = this;
switch (_that) {
case _AnswerOption() when $default != null:
return $default(_that.id,_that.label,_that.textJa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerOption implements AnswerOption {
  const _AnswerOption({required this.id, required this.label, required this.textJa});
  factory _AnswerOption.fromJson(Map<String, dynamic> json) => _$AnswerOptionFromJson(json);

@override final  String id;
@override final  int label;
@override final  String textJa;

/// Create a copy of AnswerOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerOptionCopyWith<_AnswerOption> get copyWith => __$AnswerOptionCopyWithImpl<_AnswerOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.textJa, textJa) || other.textJa == textJa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,textJa);

@override
String toString() {
  return 'AnswerOption(id: $id, label: $label, textJa: $textJa)';
}


}

/// @nodoc
abstract mixin class _$AnswerOptionCopyWith<$Res> implements $AnswerOptionCopyWith<$Res> {
  factory _$AnswerOptionCopyWith(_AnswerOption value, $Res Function(_AnswerOption) _then) = __$AnswerOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, int label, String textJa
});




}
/// @nodoc
class __$AnswerOptionCopyWithImpl<$Res>
    implements _$AnswerOptionCopyWith<$Res> {
  __$AnswerOptionCopyWithImpl(this._self, this._then);

  final _AnswerOption _self;
  final $Res Function(_AnswerOption) _then;

/// Create a copy of AnswerOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? textJa = null,}) {
  return _then(_AnswerOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as int,textJa: null == textJa ? _self.textJa : textJa // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TranscriptSentence {

 String get id; int get order; String? get speaker; String get textJa; String? get translationZh;@JsonKey(fromJson: _nullableMillisecondsFromJson) int? get startMs;@JsonKey(fromJson: _nullableMillisecondsFromJson) int? get endMs;
/// Create a copy of TranscriptSentence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptSentenceCopyWith<TranscriptSentence> get copyWith => _$TranscriptSentenceCopyWithImpl<TranscriptSentence>(this as TranscriptSentence, _$identity);

  /// Serializes this TranscriptSentence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptSentence&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.textJa, textJa) || other.textJa == textJa)&&(identical(other.translationZh, translationZh) || other.translationZh == translationZh)&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,speaker,textJa,translationZh,startMs,endMs);

@override
String toString() {
  return 'TranscriptSentence(id: $id, order: $order, speaker: $speaker, textJa: $textJa, translationZh: $translationZh, startMs: $startMs, endMs: $endMs)';
}


}

/// @nodoc
abstract mixin class $TranscriptSentenceCopyWith<$Res>  {
  factory $TranscriptSentenceCopyWith(TranscriptSentence value, $Res Function(TranscriptSentence) _then) = _$TranscriptSentenceCopyWithImpl;
@useResult
$Res call({
 String id, int order, String? speaker, String textJa, String? translationZh,@JsonKey(fromJson: _nullableMillisecondsFromJson) int? startMs,@JsonKey(fromJson: _nullableMillisecondsFromJson) int? endMs
});




}
/// @nodoc
class _$TranscriptSentenceCopyWithImpl<$Res>
    implements $TranscriptSentenceCopyWith<$Res> {
  _$TranscriptSentenceCopyWithImpl(this._self, this._then);

  final TranscriptSentence _self;
  final $Res Function(TranscriptSentence) _then;

/// Create a copy of TranscriptSentence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? order = null,Object? speaker = freezed,Object? textJa = null,Object? translationZh = freezed,Object? startMs = freezed,Object? endMs = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,speaker: freezed == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as String?,textJa: null == textJa ? _self.textJa : textJa // ignore: cast_nullable_to_non_nullable
as String,translationZh: freezed == translationZh ? _self.translationZh : translationZh // ignore: cast_nullable_to_non_nullable
as String?,startMs: freezed == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int?,endMs: freezed == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptSentence].
extension TranscriptSentencePatterns on TranscriptSentence {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptSentence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptSentence() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptSentence value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptSentence():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptSentence value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptSentence() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int order,  String? speaker,  String textJa,  String? translationZh, @JsonKey(fromJson: _nullableMillisecondsFromJson)  int? startMs, @JsonKey(fromJson: _nullableMillisecondsFromJson)  int? endMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptSentence() when $default != null:
return $default(_that.id,_that.order,_that.speaker,_that.textJa,_that.translationZh,_that.startMs,_that.endMs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int order,  String? speaker,  String textJa,  String? translationZh, @JsonKey(fromJson: _nullableMillisecondsFromJson)  int? startMs, @JsonKey(fromJson: _nullableMillisecondsFromJson)  int? endMs)  $default,) {final _that = this;
switch (_that) {
case _TranscriptSentence():
return $default(_that.id,_that.order,_that.speaker,_that.textJa,_that.translationZh,_that.startMs,_that.endMs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int order,  String? speaker,  String textJa,  String? translationZh, @JsonKey(fromJson: _nullableMillisecondsFromJson)  int? startMs, @JsonKey(fromJson: _nullableMillisecondsFromJson)  int? endMs)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptSentence() when $default != null:
return $default(_that.id,_that.order,_that.speaker,_that.textJa,_that.translationZh,_that.startMs,_that.endMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscriptSentence implements TranscriptSentence {
  const _TranscriptSentence({required this.id, required this.order, this.speaker, required this.textJa, this.translationZh, @JsonKey(fromJson: _nullableMillisecondsFromJson) this.startMs, @JsonKey(fromJson: _nullableMillisecondsFromJson) this.endMs});
  factory _TranscriptSentence.fromJson(Map<String, dynamic> json) => _$TranscriptSentenceFromJson(json);

@override final  String id;
@override final  int order;
@override final  String? speaker;
@override final  String textJa;
@override final  String? translationZh;
@override@JsonKey(fromJson: _nullableMillisecondsFromJson) final  int? startMs;
@override@JsonKey(fromJson: _nullableMillisecondsFromJson) final  int? endMs;

/// Create a copy of TranscriptSentence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptSentenceCopyWith<_TranscriptSentence> get copyWith => __$TranscriptSentenceCopyWithImpl<_TranscriptSentence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptSentenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptSentence&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.textJa, textJa) || other.textJa == textJa)&&(identical(other.translationZh, translationZh) || other.translationZh == translationZh)&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,speaker,textJa,translationZh,startMs,endMs);

@override
String toString() {
  return 'TranscriptSentence(id: $id, order: $order, speaker: $speaker, textJa: $textJa, translationZh: $translationZh, startMs: $startMs, endMs: $endMs)';
}


}

/// @nodoc
abstract mixin class _$TranscriptSentenceCopyWith<$Res> implements $TranscriptSentenceCopyWith<$Res> {
  factory _$TranscriptSentenceCopyWith(_TranscriptSentence value, $Res Function(_TranscriptSentence) _then) = __$TranscriptSentenceCopyWithImpl;
@override @useResult
$Res call({
 String id, int order, String? speaker, String textJa, String? translationZh,@JsonKey(fromJson: _nullableMillisecondsFromJson) int? startMs,@JsonKey(fromJson: _nullableMillisecondsFromJson) int? endMs
});




}
/// @nodoc
class __$TranscriptSentenceCopyWithImpl<$Res>
    implements _$TranscriptSentenceCopyWith<$Res> {
  __$TranscriptSentenceCopyWithImpl(this._self, this._then);

  final _TranscriptSentence _self;
  final $Res Function(_TranscriptSentence) _then;

/// Create a copy of TranscriptSentence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? order = null,Object? speaker = freezed,Object? textJa = null,Object? translationZh = freezed,Object? startMs = freezed,Object? endMs = freezed,}) {
  return _then(_TranscriptSentence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,speaker: freezed == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as String?,textJa: null == textJa ? _self.textJa : textJa // ignore: cast_nullable_to_non_nullable
as String,translationZh: freezed == translationZh ? _self.translationZh : translationZh // ignore: cast_nullable_to_non_nullable
as String?,startMs: freezed == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int?,endMs: freezed == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$QuestionExplanation {

 String get ja; String get zh; Map<String, String> get optionReasonsZh;
/// Create a copy of QuestionExplanation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionExplanationCopyWith<QuestionExplanation> get copyWith => _$QuestionExplanationCopyWithImpl<QuestionExplanation>(this as QuestionExplanation, _$identity);

  /// Serializes this QuestionExplanation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionExplanation&&(identical(other.ja, ja) || other.ja == ja)&&(identical(other.zh, zh) || other.zh == zh)&&const DeepCollectionEquality().equals(other.optionReasonsZh, optionReasonsZh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ja,zh,const DeepCollectionEquality().hash(optionReasonsZh));

@override
String toString() {
  return 'QuestionExplanation(ja: $ja, zh: $zh, optionReasonsZh: $optionReasonsZh)';
}


}

/// @nodoc
abstract mixin class $QuestionExplanationCopyWith<$Res>  {
  factory $QuestionExplanationCopyWith(QuestionExplanation value, $Res Function(QuestionExplanation) _then) = _$QuestionExplanationCopyWithImpl;
@useResult
$Res call({
 String ja, String zh, Map<String, String> optionReasonsZh
});




}
/// @nodoc
class _$QuestionExplanationCopyWithImpl<$Res>
    implements $QuestionExplanationCopyWith<$Res> {
  _$QuestionExplanationCopyWithImpl(this._self, this._then);

  final QuestionExplanation _self;
  final $Res Function(QuestionExplanation) _then;

/// Create a copy of QuestionExplanation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ja = null,Object? zh = null,Object? optionReasonsZh = null,}) {
  return _then(_self.copyWith(
ja: null == ja ? _self.ja : ja // ignore: cast_nullable_to_non_nullable
as String,zh: null == zh ? _self.zh : zh // ignore: cast_nullable_to_non_nullable
as String,optionReasonsZh: null == optionReasonsZh ? _self.optionReasonsZh : optionReasonsZh // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionExplanation].
extension QuestionExplanationPatterns on QuestionExplanation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionExplanation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionExplanation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionExplanation value)  $default,){
final _that = this;
switch (_that) {
case _QuestionExplanation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionExplanation value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionExplanation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ja,  String zh,  Map<String, String> optionReasonsZh)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionExplanation() when $default != null:
return $default(_that.ja,_that.zh,_that.optionReasonsZh);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ja,  String zh,  Map<String, String> optionReasonsZh)  $default,) {final _that = this;
switch (_that) {
case _QuestionExplanation():
return $default(_that.ja,_that.zh,_that.optionReasonsZh);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ja,  String zh,  Map<String, String> optionReasonsZh)?  $default,) {final _that = this;
switch (_that) {
case _QuestionExplanation() when $default != null:
return $default(_that.ja,_that.zh,_that.optionReasonsZh);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionExplanation implements QuestionExplanation {
  const _QuestionExplanation({required this.ja, required this.zh, final  Map<String, String> optionReasonsZh = const <String, String>{}}): _optionReasonsZh = optionReasonsZh;
  factory _QuestionExplanation.fromJson(Map<String, dynamic> json) => _$QuestionExplanationFromJson(json);

@override final  String ja;
@override final  String zh;
 final  Map<String, String> _optionReasonsZh;
@override@JsonKey() Map<String, String> get optionReasonsZh {
  if (_optionReasonsZh is EqualUnmodifiableMapView) return _optionReasonsZh;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_optionReasonsZh);
}


/// Create a copy of QuestionExplanation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionExplanationCopyWith<_QuestionExplanation> get copyWith => __$QuestionExplanationCopyWithImpl<_QuestionExplanation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionExplanationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionExplanation&&(identical(other.ja, ja) || other.ja == ja)&&(identical(other.zh, zh) || other.zh == zh)&&const DeepCollectionEquality().equals(other._optionReasonsZh, _optionReasonsZh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ja,zh,const DeepCollectionEquality().hash(_optionReasonsZh));

@override
String toString() {
  return 'QuestionExplanation(ja: $ja, zh: $zh, optionReasonsZh: $optionReasonsZh)';
}


}

/// @nodoc
abstract mixin class _$QuestionExplanationCopyWith<$Res> implements $QuestionExplanationCopyWith<$Res> {
  factory _$QuestionExplanationCopyWith(_QuestionExplanation value, $Res Function(_QuestionExplanation) _then) = __$QuestionExplanationCopyWithImpl;
@override @useResult
$Res call({
 String ja, String zh, Map<String, String> optionReasonsZh
});




}
/// @nodoc
class __$QuestionExplanationCopyWithImpl<$Res>
    implements _$QuestionExplanationCopyWith<$Res> {
  __$QuestionExplanationCopyWithImpl(this._self, this._then);

  final _QuestionExplanation _self;
  final $Res Function(_QuestionExplanation) _then;

/// Create a copy of QuestionExplanation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ja = null,Object? zh = null,Object? optionReasonsZh = null,}) {
  return _then(_QuestionExplanation(
ja: null == ja ? _self.ja : ja // ignore: cast_nullable_to_non_nullable
as String,zh: null == zh ? _self.zh : zh // ignore: cast_nullable_to_non_nullable
as String,optionReasonsZh: null == optionReasonsZh ? _self._optionReasonsZh : optionReasonsZh // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
