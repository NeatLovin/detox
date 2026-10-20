// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedEvent {

 String get id; String? get userId;@JsonKey(unknownEnumValue: FeedEventType.unknown) FeedEventType get type; Map<String, dynamic> get payload; DateTime get createdAt;
/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedEventCopyWith<FeedEvent> get copyWith => _$FeedEventCopyWithImpl<FeedEvent>(this as FeedEvent, _$identity);

  /// Serializes this FeedEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FeedEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.payload, _this.payload)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FeedEvent;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.type,const DeepCollectionEquality().hash(_this.payload),_this.createdAt);
}

@override
String toString() {
  final _this = this as FeedEvent;
  return 'FeedEvent(id: ${_this.id}, userId: ${_this.userId}, type: ${_this.type}, payload: ${_this.payload}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $FeedEventCopyWith<$Res>  {
  factory $FeedEventCopyWith(FeedEvent value, $Res Function(FeedEvent) _then) = _$FeedEventCopyWithImpl;
@useResult
$Res call({
 String id, String? userId,@JsonKey(unknownEnumValue: FeedEventType.unknown) FeedEventType type, Map<String, dynamic> payload, DateTime createdAt
});




}
/// @nodoc
class _$FeedEventCopyWithImpl<$Res>
    implements $FeedEventCopyWith<$Res> {
  _$FeedEventCopyWithImpl(this._self, this._then);

  final FeedEvent _self;
  final $Res Function(FeedEvent) _then;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? type = null,Object? payload = null,Object? createdAt = null,}) {
  return _then(FeedEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedEventType,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedEvent].
extension FeedEventPatterns on FeedEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedEvent value)  $default,){
final _that = this;
switch (_that) {
case _FeedEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedEvent value)?  $default,){
final _that = this;
switch (_that) {
case _FeedEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId, @JsonKey(unknownEnumValue: FeedEventType.unknown)  FeedEventType type,  Map<String, dynamic> payload,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedEvent() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId, @JsonKey(unknownEnumValue: FeedEventType.unknown)  FeedEventType type,  Map<String, dynamic> payload,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FeedEvent():
return $default(_that.id,_that.userId,_that.type,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId, @JsonKey(unknownEnumValue: FeedEventType.unknown)  FeedEventType type,  Map<String, dynamic> payload,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FeedEvent() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.payload,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedEvent extends FeedEvent {
  const _FeedEvent({required this.id, this.userId, @JsonKey(unknownEnumValue: FeedEventType.unknown) required this.type,  Map<String, dynamic> payload = const <String, dynamic>{}, required this.createdAt}): _payload = payload,super._();
  factory _FeedEvent.fromJson(Map<String, dynamic> json) => _$FeedEventFromJson(json);

@override final  String id;
@override final  String? userId;
@override@JsonKey(unknownEnumValue: FeedEventType.unknown) final  FeedEventType type;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  DateTime createdAt;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedEventCopyWith<_FeedEvent> get copyWith => __$FeedEventCopyWithImpl<_FeedEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.payload, _payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,type,const DeepCollectionEquality().hash(_payload),createdAt);
}

@override
String toString() {
    return 'FeedEvent(id: $id, userId: $userId, type: $type, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FeedEventCopyWith<$Res> implements $FeedEventCopyWith<$Res> {
  factory _$FeedEventCopyWith(_FeedEvent value, $Res Function(_FeedEvent) _then) = __$FeedEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId,@JsonKey(unknownEnumValue: FeedEventType.unknown) FeedEventType type, Map<String, dynamic> payload, DateTime createdAt
});




}
/// @nodoc
class __$FeedEventCopyWithImpl<$Res>
    implements _$FeedEventCopyWith<$Res> {
  __$FeedEventCopyWithImpl(this._self, this._then);

  final _FeedEvent _self;
  final $Res Function(_FeedEvent) _then;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? type = null,Object? payload = null,Object? createdAt = null,}) {
  return _then(_FeedEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedEventType,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
