// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'addiction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Addiction {

 String get id; String get userId;@JsonKey(unknownEnumValue: AddictionType.custom) AddictionType get type; String get label; String get unitLabel; double get unitCost; double get baselinePerDay; bool get isPrivate; DateTime get quitStartedAt; DateTime get streakStartedAt; int get bestStreakSeconds; int get awardedCleanDays; DateTime? get archivedAt; DateTime get createdAt;
/// Create a copy of Addiction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddictionCopyWith<Addiction> get copyWith => _$AddictionCopyWithImpl<Addiction>(this as Addiction, _$identity);

  /// Serializes this Addiction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Addiction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Addiction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.unitLabel, _this.unitLabel) || other.unitLabel == _this.unitLabel)&&(identical(other.unitCost, _this.unitCost) || other.unitCost == _this.unitCost)&&(identical(other.baselinePerDay, _this.baselinePerDay) || other.baselinePerDay == _this.baselinePerDay)&&(identical(other.isPrivate, _this.isPrivate) || other.isPrivate == _this.isPrivate)&&(identical(other.quitStartedAt, _this.quitStartedAt) || other.quitStartedAt == _this.quitStartedAt)&&(identical(other.streakStartedAt, _this.streakStartedAt) || other.streakStartedAt == _this.streakStartedAt)&&(identical(other.bestStreakSeconds, _this.bestStreakSeconds) || other.bestStreakSeconds == _this.bestStreakSeconds)&&(identical(other.awardedCleanDays, _this.awardedCleanDays) || other.awardedCleanDays == _this.awardedCleanDays)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Addiction;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.type,_this.label,_this.unitLabel,_this.unitCost,_this.baselinePerDay,_this.isPrivate,_this.quitStartedAt,_this.streakStartedAt,_this.bestStreakSeconds,_this.awardedCleanDays,_this.archivedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as Addiction;
  return 'Addiction(id: ${_this.id}, userId: ${_this.userId}, type: ${_this.type}, label: ${_this.label}, unitLabel: ${_this.unitLabel}, unitCost: ${_this.unitCost}, baselinePerDay: ${_this.baselinePerDay}, isPrivate: ${_this.isPrivate}, quitStartedAt: ${_this.quitStartedAt}, streakStartedAt: ${_this.streakStartedAt}, bestStreakSeconds: ${_this.bestStreakSeconds}, awardedCleanDays: ${_this.awardedCleanDays}, archivedAt: ${_this.archivedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AddictionCopyWith<$Res>  {
  factory $AddictionCopyWith(Addiction value, $Res Function(Addiction) _then) = _$AddictionCopyWithImpl;
@useResult
$Res call({
 String id, String userId,@JsonKey(unknownEnumValue: AddictionType.custom) AddictionType type, String label, String unitLabel, double unitCost, double baselinePerDay, bool isPrivate, DateTime quitStartedAt, DateTime streakStartedAt, int bestStreakSeconds, int awardedCleanDays, DateTime? archivedAt, DateTime createdAt
});




}
/// @nodoc
class _$AddictionCopyWithImpl<$Res>
    implements $AddictionCopyWith<$Res> {
  _$AddictionCopyWithImpl(this._self, this._then);

  final Addiction _self;
  final $Res Function(Addiction) _then;

/// Create a copy of Addiction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? label = null,Object? unitLabel = null,Object? unitCost = null,Object? baselinePerDay = null,Object? isPrivate = null,Object? quitStartedAt = null,Object? streakStartedAt = null,Object? bestStreakSeconds = null,Object? awardedCleanDays = null,Object? archivedAt = freezed,Object? createdAt = null,}) {
  return _then(Addiction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddictionType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unitLabel: null == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double,baselinePerDay: null == baselinePerDay ? _self.baselinePerDay : baselinePerDay // ignore: cast_nullable_to_non_nullable
as double,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,quitStartedAt: null == quitStartedAt ? _self.quitStartedAt : quitStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,streakStartedAt: null == streakStartedAt ? _self.streakStartedAt : streakStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,bestStreakSeconds: null == bestStreakSeconds ? _self.bestStreakSeconds : bestStreakSeconds // ignore: cast_nullable_to_non_nullable
as int,awardedCleanDays: null == awardedCleanDays ? _self.awardedCleanDays : awardedCleanDays // ignore: cast_nullable_to_non_nullable
as int,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Addiction].
extension AddictionPatterns on Addiction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Addiction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Addiction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Addiction value)  $default,){
final _that = this;
switch (_that) {
case _Addiction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Addiction value)?  $default,){
final _that = this;
switch (_that) {
case _Addiction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId, @JsonKey(unknownEnumValue: AddictionType.custom)  AddictionType type,  String label,  String unitLabel,  double unitCost,  double baselinePerDay,  bool isPrivate,  DateTime quitStartedAt,  DateTime streakStartedAt,  int bestStreakSeconds,  int awardedCleanDays,  DateTime? archivedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Addiction() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.label,_that.unitLabel,_that.unitCost,_that.baselinePerDay,_that.isPrivate,_that.quitStartedAt,_that.streakStartedAt,_that.bestStreakSeconds,_that.awardedCleanDays,_that.archivedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId, @JsonKey(unknownEnumValue: AddictionType.custom)  AddictionType type,  String label,  String unitLabel,  double unitCost,  double baselinePerDay,  bool isPrivate,  DateTime quitStartedAt,  DateTime streakStartedAt,  int bestStreakSeconds,  int awardedCleanDays,  DateTime? archivedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Addiction():
return $default(_that.id,_that.userId,_that.type,_that.label,_that.unitLabel,_that.unitCost,_that.baselinePerDay,_that.isPrivate,_that.quitStartedAt,_that.streakStartedAt,_that.bestStreakSeconds,_that.awardedCleanDays,_that.archivedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId, @JsonKey(unknownEnumValue: AddictionType.custom)  AddictionType type,  String label,  String unitLabel,  double unitCost,  double baselinePerDay,  bool isPrivate,  DateTime quitStartedAt,  DateTime streakStartedAt,  int bestStreakSeconds,  int awardedCleanDays,  DateTime? archivedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Addiction() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.label,_that.unitLabel,_that.unitCost,_that.baselinePerDay,_that.isPrivate,_that.quitStartedAt,_that.streakStartedAt,_that.bestStreakSeconds,_that.awardedCleanDays,_that.archivedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Addiction extends Addiction {
  const _Addiction({required this.id, required this.userId, @JsonKey(unknownEnumValue: AddictionType.custom) required this.type, required this.label, required this.unitLabel, required this.unitCost, required this.baselinePerDay, this.isPrivate = false, required this.quitStartedAt, required this.streakStartedAt, this.bestStreakSeconds = 0, this.awardedCleanDays = 0, this.archivedAt, required this.createdAt}): super._();
  factory _Addiction.fromJson(Map<String, dynamic> json) => _$AddictionFromJson(json);

@override final  String id;
@override final  String userId;
@override@JsonKey(unknownEnumValue: AddictionType.custom) final  AddictionType type;
@override final  String label;
@override final  String unitLabel;
@override final  double unitCost;
@override final  double baselinePerDay;
@override@JsonKey() final  bool isPrivate;
@override final  DateTime quitStartedAt;
@override final  DateTime streakStartedAt;
@override@JsonKey() final  int bestStreakSeconds;
@override@JsonKey() final  int awardedCleanDays;
@override final  DateTime? archivedAt;
@override final  DateTime createdAt;

/// Create a copy of Addiction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddictionCopyWith<_Addiction> get copyWith => __$AddictionCopyWithImpl<_Addiction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddictionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Addiction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.unitLabel, unitLabel) || other.unitLabel == unitLabel)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.baselinePerDay, baselinePerDay) || other.baselinePerDay == baselinePerDay)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.quitStartedAt, quitStartedAt) || other.quitStartedAt == quitStartedAt)&&(identical(other.streakStartedAt, streakStartedAt) || other.streakStartedAt == streakStartedAt)&&(identical(other.bestStreakSeconds, bestStreakSeconds) || other.bestStreakSeconds == bestStreakSeconds)&&(identical(other.awardedCleanDays, awardedCleanDays) || other.awardedCleanDays == awardedCleanDays)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,type,label,unitLabel,unitCost,baselinePerDay,isPrivate,quitStartedAt,streakStartedAt,bestStreakSeconds,awardedCleanDays,archivedAt,createdAt);
}

@override
String toString() {
    return 'Addiction(id: $id, userId: $userId, type: $type, label: $label, unitLabel: $unitLabel, unitCost: $unitCost, baselinePerDay: $baselinePerDay, isPrivate: $isPrivate, quitStartedAt: $quitStartedAt, streakStartedAt: $streakStartedAt, bestStreakSeconds: $bestStreakSeconds, awardedCleanDays: $awardedCleanDays, archivedAt: $archivedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AddictionCopyWith<$Res> implements $AddictionCopyWith<$Res> {
  factory _$AddictionCopyWith(_Addiction value, $Res Function(_Addiction) _then) = __$AddictionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId,@JsonKey(unknownEnumValue: AddictionType.custom) AddictionType type, String label, String unitLabel, double unitCost, double baselinePerDay, bool isPrivate, DateTime quitStartedAt, DateTime streakStartedAt, int bestStreakSeconds, int awardedCleanDays, DateTime? archivedAt, DateTime createdAt
});




}
/// @nodoc
class __$AddictionCopyWithImpl<$Res>
    implements _$AddictionCopyWith<$Res> {
  __$AddictionCopyWithImpl(this._self, this._then);

  final _Addiction _self;
  final $Res Function(_Addiction) _then;

/// Create a copy of Addiction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? label = null,Object? unitLabel = null,Object? unitCost = null,Object? baselinePerDay = null,Object? isPrivate = null,Object? quitStartedAt = null,Object? streakStartedAt = null,Object? bestStreakSeconds = null,Object? awardedCleanDays = null,Object? archivedAt = freezed,Object? createdAt = null,}) {
  return _then(_Addiction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddictionType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unitLabel: null == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double,baselinePerDay: null == baselinePerDay ? _self.baselinePerDay : baselinePerDay // ignore: cast_nullable_to_non_nullable
as double,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,quitStartedAt: null == quitStartedAt ? _self.quitStartedAt : quitStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,streakStartedAt: null == streakStartedAt ? _self.streakStartedAt : streakStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,bestStreakSeconds: null == bestStreakSeconds ? _self.bestStreakSeconds : bestStreakSeconds // ignore: cast_nullable_to_non_nullable
as int,awardedCleanDays: null == awardedCleanDays ? _self.awardedCleanDays : awardedCleanDays // ignore: cast_nullable_to_non_nullable
as int,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$AddictionDraft {

 AddictionType get type; String get label; String get unitLabel; double get unitCost; double get baselinePerDay; bool get isPrivate; DateTime get quitStartedAt;
/// Create a copy of AddictionDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddictionDraftCopyWith<AddictionDraft> get copyWith => _$AddictionDraftCopyWithImpl<AddictionDraft>(this as AddictionDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddictionDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddictionDraft&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.unitLabel, _this.unitLabel) || other.unitLabel == _this.unitLabel)&&(identical(other.unitCost, _this.unitCost) || other.unitCost == _this.unitCost)&&(identical(other.baselinePerDay, _this.baselinePerDay) || other.baselinePerDay == _this.baselinePerDay)&&(identical(other.isPrivate, _this.isPrivate) || other.isPrivate == _this.isPrivate)&&(identical(other.quitStartedAt, _this.quitStartedAt) || other.quitStartedAt == _this.quitStartedAt));
}


@override
int get hashCode {
  final _this = this as AddictionDraft;
  return Object.hash(runtimeType,_this.type,_this.label,_this.unitLabel,_this.unitCost,_this.baselinePerDay,_this.isPrivate,_this.quitStartedAt);
}

@override
String toString() {
  final _this = this as AddictionDraft;
  return 'AddictionDraft(type: ${_this.type}, label: ${_this.label}, unitLabel: ${_this.unitLabel}, unitCost: ${_this.unitCost}, baselinePerDay: ${_this.baselinePerDay}, isPrivate: ${_this.isPrivate}, quitStartedAt: ${_this.quitStartedAt})';
}


}

/// @nodoc
abstract mixin class $AddictionDraftCopyWith<$Res>  {
  factory $AddictionDraftCopyWith(AddictionDraft value, $Res Function(AddictionDraft) _then) = _$AddictionDraftCopyWithImpl;
@useResult
$Res call({
 AddictionType type, String label, String unitLabel, double unitCost, double baselinePerDay, bool isPrivate, DateTime quitStartedAt
});




}
/// @nodoc
class _$AddictionDraftCopyWithImpl<$Res>
    implements $AddictionDraftCopyWith<$Res> {
  _$AddictionDraftCopyWithImpl(this._self, this._then);

  final AddictionDraft _self;
  final $Res Function(AddictionDraft) _then;

/// Create a copy of AddictionDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? label = null,Object? unitLabel = null,Object? unitCost = null,Object? baselinePerDay = null,Object? isPrivate = null,Object? quitStartedAt = null,}) {
  return _then(AddictionDraft(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddictionType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unitLabel: null == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double,baselinePerDay: null == baselinePerDay ? _self.baselinePerDay : baselinePerDay // ignore: cast_nullable_to_non_nullable
as double,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,quitStartedAt: null == quitStartedAt ? _self.quitStartedAt : quitStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AddictionDraft].
extension AddictionDraftPatterns on AddictionDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddictionDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddictionDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddictionDraft value)  $default,){
final _that = this;
switch (_that) {
case _AddictionDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddictionDraft value)?  $default,){
final _that = this;
switch (_that) {
case _AddictionDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AddictionType type,  String label,  String unitLabel,  double unitCost,  double baselinePerDay,  bool isPrivate,  DateTime quitStartedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddictionDraft() when $default != null:
return $default(_that.type,_that.label,_that.unitLabel,_that.unitCost,_that.baselinePerDay,_that.isPrivate,_that.quitStartedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AddictionType type,  String label,  String unitLabel,  double unitCost,  double baselinePerDay,  bool isPrivate,  DateTime quitStartedAt)  $default,) {final _that = this;
switch (_that) {
case _AddictionDraft():
return $default(_that.type,_that.label,_that.unitLabel,_that.unitCost,_that.baselinePerDay,_that.isPrivate,_that.quitStartedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AddictionType type,  String label,  String unitLabel,  double unitCost,  double baselinePerDay,  bool isPrivate,  DateTime quitStartedAt)?  $default,) {final _that = this;
switch (_that) {
case _AddictionDraft() when $default != null:
return $default(_that.type,_that.label,_that.unitLabel,_that.unitCost,_that.baselinePerDay,_that.isPrivate,_that.quitStartedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AddictionDraft implements AddictionDraft {
  const _AddictionDraft({required this.type, required this.label, required this.unitLabel, required this.unitCost, required this.baselinePerDay, this.isPrivate = false, required this.quitStartedAt});
  

@override final  AddictionType type;
@override final  String label;
@override final  String unitLabel;
@override final  double unitCost;
@override final  double baselinePerDay;
@override@JsonKey() final  bool isPrivate;
@override final  DateTime quitStartedAt;

/// Create a copy of AddictionDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddictionDraftCopyWith<_AddictionDraft> get copyWith => __$AddictionDraftCopyWithImpl<_AddictionDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddictionDraft&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.unitLabel, unitLabel) || other.unitLabel == unitLabel)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.baselinePerDay, baselinePerDay) || other.baselinePerDay == baselinePerDay)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.quitStartedAt, quitStartedAt) || other.quitStartedAt == quitStartedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,label,unitLabel,unitCost,baselinePerDay,isPrivate,quitStartedAt);
}

@override
String toString() {
    return 'AddictionDraft(type: $type, label: $label, unitLabel: $unitLabel, unitCost: $unitCost, baselinePerDay: $baselinePerDay, isPrivate: $isPrivate, quitStartedAt: $quitStartedAt)';
}


}

/// @nodoc
abstract mixin class _$AddictionDraftCopyWith<$Res> implements $AddictionDraftCopyWith<$Res> {
  factory _$AddictionDraftCopyWith(_AddictionDraft value, $Res Function(_AddictionDraft) _then) = __$AddictionDraftCopyWithImpl;
@override @useResult
$Res call({
 AddictionType type, String label, String unitLabel, double unitCost, double baselinePerDay, bool isPrivate, DateTime quitStartedAt
});




}
/// @nodoc
class __$AddictionDraftCopyWithImpl<$Res>
    implements _$AddictionDraftCopyWith<$Res> {
  __$AddictionDraftCopyWithImpl(this._self, this._then);

  final _AddictionDraft _self;
  final $Res Function(_AddictionDraft) _then;

/// Create a copy of AddictionDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? label = null,Object? unitLabel = null,Object? unitCost = null,Object? baselinePerDay = null,Object? isPrivate = null,Object? quitStartedAt = null,}) {
  return _then(_AddictionDraft(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddictionType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unitLabel: null == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double,baselinePerDay: null == baselinePerDay ? _self.baselinePerDay : baselinePerDay // ignore: cast_nullable_to_non_nullable
as double,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,quitStartedAt: null == quitStartedAt ? _self.quitStartedAt : quitStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$RelapseInput {

 String get addictionId; DateTime get occurredAt; String? get note; bool get shared;
/// Create a copy of RelapseInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelapseInputCopyWith<RelapseInput> get copyWith => _$RelapseInputCopyWithImpl<RelapseInput>(this as RelapseInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RelapseInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelapseInput&&(identical(other.addictionId, _this.addictionId) || other.addictionId == _this.addictionId)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.shared, _this.shared) || other.shared == _this.shared));
}


@override
int get hashCode {
  final _this = this as RelapseInput;
  return Object.hash(runtimeType,_this.addictionId,_this.occurredAt,_this.note,_this.shared);
}

@override
String toString() {
  final _this = this as RelapseInput;
  return 'RelapseInput(addictionId: ${_this.addictionId}, occurredAt: ${_this.occurredAt}, note: ${_this.note}, shared: ${_this.shared})';
}


}

/// @nodoc
abstract mixin class $RelapseInputCopyWith<$Res>  {
  factory $RelapseInputCopyWith(RelapseInput value, $Res Function(RelapseInput) _then) = _$RelapseInputCopyWithImpl;
@useResult
$Res call({
 String addictionId, DateTime occurredAt, String? note, bool shared
});




}
/// @nodoc
class _$RelapseInputCopyWithImpl<$Res>
    implements $RelapseInputCopyWith<$Res> {
  _$RelapseInputCopyWithImpl(this._self, this._then);

  final RelapseInput _self;
  final $Res Function(RelapseInput) _then;

/// Create a copy of RelapseInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addictionId = null,Object? occurredAt = null,Object? note = freezed,Object? shared = null,}) {
  return _then(RelapseInput(
addictionId: null == addictionId ? _self.addictionId : addictionId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,shared: null == shared ? _self.shared : shared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RelapseInput].
extension RelapseInputPatterns on RelapseInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelapseInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelapseInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelapseInput value)  $default,){
final _that = this;
switch (_that) {
case _RelapseInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelapseInput value)?  $default,){
final _that = this;
switch (_that) {
case _RelapseInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String addictionId,  DateTime occurredAt,  String? note,  bool shared)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelapseInput() when $default != null:
return $default(_that.addictionId,_that.occurredAt,_that.note,_that.shared);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String addictionId,  DateTime occurredAt,  String? note,  bool shared)  $default,) {final _that = this;
switch (_that) {
case _RelapseInput():
return $default(_that.addictionId,_that.occurredAt,_that.note,_that.shared);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String addictionId,  DateTime occurredAt,  String? note,  bool shared)?  $default,) {final _that = this;
switch (_that) {
case _RelapseInput() when $default != null:
return $default(_that.addictionId,_that.occurredAt,_that.note,_that.shared);case _:
  return null;

}
}

}

/// @nodoc


class _RelapseInput implements RelapseInput {
  const _RelapseInput({required this.addictionId, required this.occurredAt, this.note, this.shared = false});
  

@override final  String addictionId;
@override final  DateTime occurredAt;
@override final  String? note;
@override@JsonKey() final  bool shared;

/// Create a copy of RelapseInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelapseInputCopyWith<_RelapseInput> get copyWith => __$RelapseInputCopyWithImpl<_RelapseInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelapseInput&&(identical(other.addictionId, addictionId) || other.addictionId == addictionId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.shared, shared) || other.shared == shared));
}


@override
int get hashCode {
    return Object.hash(runtimeType,addictionId,occurredAt,note,shared);
}

@override
String toString() {
    return 'RelapseInput(addictionId: $addictionId, occurredAt: $occurredAt, note: $note, shared: $shared)';
}


}

/// @nodoc
abstract mixin class _$RelapseInputCopyWith<$Res> implements $RelapseInputCopyWith<$Res> {
  factory _$RelapseInputCopyWith(_RelapseInput value, $Res Function(_RelapseInput) _then) = __$RelapseInputCopyWithImpl;
@override @useResult
$Res call({
 String addictionId, DateTime occurredAt, String? note, bool shared
});




}
/// @nodoc
class __$RelapseInputCopyWithImpl<$Res>
    implements _$RelapseInputCopyWith<$Res> {
  __$RelapseInputCopyWithImpl(this._self, this._then);

  final _RelapseInput _self;
  final $Res Function(_RelapseInput) _then;

/// Create a copy of RelapseInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addictionId = null,Object? occurredAt = null,Object? note = freezed,Object? shared = null,}) {
  return _then(_RelapseInput(
addictionId: null == addictionId ? _self.addictionId : addictionId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,shared: null == shared ? _self.shared : shared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
