// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'squad.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Squad {

 String get id; String get name; String get inviteCode; String? get createdBy; DateTime get createdAt;
/// Create a copy of Squad
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SquadCopyWith<Squad> get copyWith => _$SquadCopyWithImpl<Squad>(this as Squad, _$identity);

  /// Serializes this Squad to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Squad;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Squad&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.inviteCode, _this.inviteCode) || other.inviteCode == _this.inviteCode)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Squad;
  return Object.hash(runtimeType,_this.id,_this.name,_this.inviteCode,_this.createdBy,_this.createdAt);
}

@override
String toString() {
  final _this = this as Squad;
  return 'Squad(id: ${_this.id}, name: ${_this.name}, inviteCode: ${_this.inviteCode}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SquadCopyWith<$Res>  {
  factory $SquadCopyWith(Squad value, $Res Function(Squad) _then) = _$SquadCopyWithImpl;
@useResult
$Res call({
 String id, String name, String inviteCode, String? createdBy, DateTime createdAt
});




}
/// @nodoc
class _$SquadCopyWithImpl<$Res>
    implements $SquadCopyWith<$Res> {
  _$SquadCopyWithImpl(this._self, this._then);

  final Squad _self;
  final $Res Function(Squad) _then;

/// Create a copy of Squad
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? inviteCode = null,Object? createdBy = freezed,Object? createdAt = null,}) {
  return _then(Squad(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Squad].
extension SquadPatterns on Squad {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Squad value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Squad() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Squad value)  $default,){
final _that = this;
switch (_that) {
case _Squad():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Squad value)?  $default,){
final _that = this;
switch (_that) {
case _Squad() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String inviteCode,  String? createdBy,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Squad() when $default != null:
return $default(_that.id,_that.name,_that.inviteCode,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String inviteCode,  String? createdBy,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Squad():
return $default(_that.id,_that.name,_that.inviteCode,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String inviteCode,  String? createdBy,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Squad() when $default != null:
return $default(_that.id,_that.name,_that.inviteCode,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Squad implements Squad {
  const _Squad({required this.id, required this.name, required this.inviteCode, this.createdBy, required this.createdAt});
  factory _Squad.fromJson(Map<String, dynamic> json) => _$SquadFromJson(json);

@override final  String id;
@override final  String name;
@override final  String inviteCode;
@override final  String? createdBy;
@override final  DateTime createdAt;

/// Create a copy of Squad
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SquadCopyWith<_Squad> get copyWith => __$SquadCopyWithImpl<_Squad>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SquadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Squad&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,inviteCode,createdBy,createdAt);
}

@override
String toString() {
    return 'Squad(id: $id, name: $name, inviteCode: $inviteCode, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SquadCopyWith<$Res> implements $SquadCopyWith<$Res> {
  factory _$SquadCopyWith(_Squad value, $Res Function(_Squad) _then) = __$SquadCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String inviteCode, String? createdBy, DateTime createdAt
});




}
/// @nodoc
class __$SquadCopyWithImpl<$Res>
    implements _$SquadCopyWith<$Res> {
  __$SquadCopyWithImpl(this._self, this._then);

  final _Squad _self;
  final $Res Function(_Squad) _then;

/// Create a copy of Squad
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? inviteCode = null,Object? createdBy = freezed,Object? createdAt = null,}) {
  return _then(_Squad(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SquadMember {

 String get userId; String get username; String get avatarEmoji; SquadRole get role; DateTime get joinedAt;
/// Create a copy of SquadMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SquadMemberCopyWith<SquadMember> get copyWith => _$SquadMemberCopyWithImpl<SquadMember>(this as SquadMember, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SquadMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SquadMember&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarEmoji, _this.avatarEmoji) || other.avatarEmoji == _this.avatarEmoji)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt));
}


@override
int get hashCode {
  final _this = this as SquadMember;
  return Object.hash(runtimeType,_this.userId,_this.username,_this.avatarEmoji,_this.role,_this.joinedAt);
}

@override
String toString() {
  final _this = this as SquadMember;
  return 'SquadMember(userId: ${_this.userId}, username: ${_this.username}, avatarEmoji: ${_this.avatarEmoji}, role: ${_this.role}, joinedAt: ${_this.joinedAt})';
}


}

/// @nodoc
abstract mixin class $SquadMemberCopyWith<$Res>  {
  factory $SquadMemberCopyWith(SquadMember value, $Res Function(SquadMember) _then) = _$SquadMemberCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String avatarEmoji, SquadRole role, DateTime joinedAt
});




}
/// @nodoc
class _$SquadMemberCopyWithImpl<$Res>
    implements $SquadMemberCopyWith<$Res> {
  _$SquadMemberCopyWithImpl(this._self, this._then);

  final SquadMember _self;
  final $Res Function(SquadMember) _then;

/// Create a copy of SquadMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? avatarEmoji = null,Object? role = null,Object? joinedAt = null,}) {
  return _then(SquadMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarEmoji: null == avatarEmoji ? _self.avatarEmoji : avatarEmoji // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as SquadRole,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SquadMember].
extension SquadMemberPatterns on SquadMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SquadMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SquadMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SquadMember value)  $default,){
final _that = this;
switch (_that) {
case _SquadMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SquadMember value)?  $default,){
final _that = this;
switch (_that) {
case _SquadMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String avatarEmoji,  SquadRole role,  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SquadMember() when $default != null:
return $default(_that.userId,_that.username,_that.avatarEmoji,_that.role,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String avatarEmoji,  SquadRole role,  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _SquadMember():
return $default(_that.userId,_that.username,_that.avatarEmoji,_that.role,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String avatarEmoji,  SquadRole role,  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _SquadMember() when $default != null:
return $default(_that.userId,_that.username,_that.avatarEmoji,_that.role,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SquadMember implements SquadMember {
  const _SquadMember({required this.userId, required this.username, required this.avatarEmoji, required this.role, required this.joinedAt});
  

@override final  String userId;
@override final  String username;
@override final  String avatarEmoji;
@override final  SquadRole role;
@override final  DateTime joinedAt;

/// Create a copy of SquadMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SquadMemberCopyWith<_SquadMember> get copyWith => __$SquadMemberCopyWithImpl<_SquadMember>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SquadMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarEmoji, avatarEmoji) || other.avatarEmoji == avatarEmoji)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,username,avatarEmoji,role,joinedAt);
}

@override
String toString() {
    return 'SquadMember(userId: $userId, username: $username, avatarEmoji: $avatarEmoji, role: $role, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$SquadMemberCopyWith<$Res> implements $SquadMemberCopyWith<$Res> {
  factory _$SquadMemberCopyWith(_SquadMember value, $Res Function(_SquadMember) _then) = __$SquadMemberCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String avatarEmoji, SquadRole role, DateTime joinedAt
});




}
/// @nodoc
class __$SquadMemberCopyWithImpl<$Res>
    implements _$SquadMemberCopyWith<$Res> {
  __$SquadMemberCopyWithImpl(this._self, this._then);

  final _SquadMember _self;
  final $Res Function(_SquadMember) _then;

/// Create a copy of SquadMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? avatarEmoji = null,Object? role = null,Object? joinedAt = null,}) {
  return _then(_SquadMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarEmoji: null == avatarEmoji ? _self.avatarEmoji : avatarEmoji // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as SquadRole,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$LeaderboardEntry {

 String get userId; String get username; String get avatarEmoji; int get level; int get hp; int get xp; int get weeklyXp;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LeaderboardEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarEmoji, _this.avatarEmoji) || other.avatarEmoji == _this.avatarEmoji)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.hp, _this.hp) || other.hp == _this.hp)&&(identical(other.xp, _this.xp) || other.xp == _this.xp)&&(identical(other.weeklyXp, _this.weeklyXp) || other.weeklyXp == _this.weeklyXp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LeaderboardEntry;
  return Object.hash(runtimeType,_this.userId,_this.username,_this.avatarEmoji,_this.level,_this.hp,_this.xp,_this.weeklyXp);
}

@override
String toString() {
  final _this = this as LeaderboardEntry;
  return 'LeaderboardEntry(userId: ${_this.userId}, username: ${_this.username}, avatarEmoji: ${_this.avatarEmoji}, level: ${_this.level}, hp: ${_this.hp}, xp: ${_this.xp}, weeklyXp: ${_this.weeklyXp})';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String avatarEmoji, int level, int hp, int xp, int weeklyXp
});




}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? avatarEmoji = null,Object? level = null,Object? hp = null,Object? xp = null,Object? weeklyXp = null,}) {
  return _then(LeaderboardEntry(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarEmoji: null == avatarEmoji ? _self.avatarEmoji : avatarEmoji // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,hp: null == hp ? _self.hp : hp // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,weeklyXp: null == weeklyXp ? _self.weeklyXp : weeklyXp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String avatarEmoji,  int level,  int hp,  int xp,  int weeklyXp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.userId,_that.username,_that.avatarEmoji,_that.level,_that.hp,_that.xp,_that.weeklyXp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String avatarEmoji,  int level,  int hp,  int xp,  int weeklyXp)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.userId,_that.username,_that.avatarEmoji,_that.level,_that.hp,_that.xp,_that.weeklyXp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String avatarEmoji,  int level,  int hp,  int xp,  int weeklyXp)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.userId,_that.username,_that.avatarEmoji,_that.level,_that.hp,_that.xp,_that.weeklyXp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry implements LeaderboardEntry {
  const _LeaderboardEntry({required this.userId, required this.username, required this.avatarEmoji, required this.level, required this.hp, required this.xp, required this.weeklyXp});
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String avatarEmoji;
@override final  int level;
@override final  int hp;
@override final  int xp;
@override final  int weeklyXp;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarEmoji, avatarEmoji) || other.avatarEmoji == avatarEmoji)&&(identical(other.level, level) || other.level == level)&&(identical(other.hp, hp) || other.hp == hp)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.weeklyXp, weeklyXp) || other.weeklyXp == weeklyXp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,username,avatarEmoji,level,hp,xp,weeklyXp);
}

@override
String toString() {
    return 'LeaderboardEntry(userId: $userId, username: $username, avatarEmoji: $avatarEmoji, level: $level, hp: $hp, xp: $xp, weeklyXp: $weeklyXp)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String avatarEmoji, int level, int hp, int xp, int weeklyXp
});




}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? avatarEmoji = null,Object? level = null,Object? hp = null,Object? xp = null,Object? weeklyXp = null,}) {
  return _then(_LeaderboardEntry(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarEmoji: null == avatarEmoji ? _self.avatarEmoji : avatarEmoji // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,hp: null == hp ? _self.hp : hp // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,weeklyXp: null == weeklyXp ? _self.weeklyXp : weeklyXp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
