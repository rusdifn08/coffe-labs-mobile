// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_protocol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
InteractiveAttachment _$InteractiveAttachmentFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'v60_recipe_card':
          return V60RecipeCardAttachment.fromJson(
            json
          );
                case 'coffee_bean_card':
          return CoffeeBeanCardAttachment.fromJson(
            json
          );
                case 'brew_image_media':
          return BrewImageMediaAttachment.fromJson(
            json
          );
                case 'brew_session_result':
          return BrewSessionResultAttachment.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'InteractiveAttachment',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$InteractiveAttachment {



  /// Serializes this InteractiveAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InteractiveAttachment);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InteractiveAttachment()';
}


}

/// @nodoc
class $InteractiveAttachmentCopyWith<$Res>  {
$InteractiveAttachmentCopyWith(InteractiveAttachment _, $Res Function(InteractiveAttachment) __);
}


/// Adds pattern-matching-related methods to [InteractiveAttachment].
extension InteractiveAttachmentPatterns on InteractiveAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( V60RecipeCardAttachment value)?  v60RecipeCard,TResult Function( CoffeeBeanCardAttachment value)?  coffeeBeanCard,TResult Function( BrewImageMediaAttachment value)?  brewImageMedia,TResult Function( BrewSessionResultAttachment value)?  brewSessionResult,required TResult orElse(),}){
final _that = this;
switch (_that) {
case V60RecipeCardAttachment() when v60RecipeCard != null:
return v60RecipeCard(_that);case CoffeeBeanCardAttachment() when coffeeBeanCard != null:
return coffeeBeanCard(_that);case BrewImageMediaAttachment() when brewImageMedia != null:
return brewImageMedia(_that);case BrewSessionResultAttachment() when brewSessionResult != null:
return brewSessionResult(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( V60RecipeCardAttachment value)  v60RecipeCard,required TResult Function( CoffeeBeanCardAttachment value)  coffeeBeanCard,required TResult Function( BrewImageMediaAttachment value)  brewImageMedia,required TResult Function( BrewSessionResultAttachment value)  brewSessionResult,}){
final _that = this;
switch (_that) {
case V60RecipeCardAttachment():
return v60RecipeCard(_that);case CoffeeBeanCardAttachment():
return coffeeBeanCard(_that);case BrewImageMediaAttachment():
return brewImageMedia(_that);case BrewSessionResultAttachment():
return brewSessionResult(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( V60RecipeCardAttachment value)?  v60RecipeCard,TResult? Function( CoffeeBeanCardAttachment value)?  coffeeBeanCard,TResult? Function( BrewImageMediaAttachment value)?  brewImageMedia,TResult? Function( BrewSessionResultAttachment value)?  brewSessionResult,}){
final _that = this;
switch (_that) {
case V60RecipeCardAttachment() when v60RecipeCard != null:
return v60RecipeCard(_that);case CoffeeBeanCardAttachment() when coffeeBeanCard != null:
return coffeeBeanCard(_that);case BrewImageMediaAttachment() when brewImageMedia != null:
return brewImageMedia(_that);case BrewSessionResultAttachment() when brewSessionResult != null:
return brewSessionResult(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@JsonKey(name: 'recipe_id')  String recipeId,  String title, @JsonKey(name: 'brewer_name')  String brewerName, @JsonKey(name: 'dose_grams')  double doseGrams, @JsonKey(name: 'water_ml')  double waterMl, @JsonKey(name: 'temp_c')  int tempC, @JsonKey(name: 'target_duration_sec')  int targetDurationSec, @JsonKey(name: 'steps_preview')  List<String> stepsPreview)?  v60RecipeCard,TResult Function(@JsonKey(name: 'bean_id')  String? beanId,  String roastery, @JsonKey(name: 'bean_name')  String beanName,  String origin,  String process, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes, @JsonKey(name: 'image_url')  String? imageUrl)?  coffeeBeanCard,TResult Function(@JsonKey(name: 'image_url')  String imageUrl,  int width,  int height,  String? blurhash,  String? caption)?  brewImageMedia,TResult Function( String title,  String method, @JsonKey(name: 'accuracy_score')  int accuracyScore, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'brew_duration_sec')  int? brewDurationSec,  String? notes)?  brewSessionResult,required TResult orElse(),}) {final _that = this;
switch (_that) {
case V60RecipeCardAttachment() when v60RecipeCard != null:
return v60RecipeCard(_that.recipeId,_that.title,_that.brewerName,_that.doseGrams,_that.waterMl,_that.tempC,_that.targetDurationSec,_that.stepsPreview);case CoffeeBeanCardAttachment() when coffeeBeanCard != null:
return coffeeBeanCard(_that.beanId,_that.roastery,_that.beanName,_that.origin,_that.process,_that.tastingNotes,_that.imageUrl);case BrewImageMediaAttachment() when brewImageMedia != null:
return brewImageMedia(_that.imageUrl,_that.width,_that.height,_that.blurhash,_that.caption);case BrewSessionResultAttachment() when brewSessionResult != null:
return brewSessionResult(_that.title,_that.method,_that.accuracyScore,_that.xpEarned,_that.brewDurationSec,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@JsonKey(name: 'recipe_id')  String recipeId,  String title, @JsonKey(name: 'brewer_name')  String brewerName, @JsonKey(name: 'dose_grams')  double doseGrams, @JsonKey(name: 'water_ml')  double waterMl, @JsonKey(name: 'temp_c')  int tempC, @JsonKey(name: 'target_duration_sec')  int targetDurationSec, @JsonKey(name: 'steps_preview')  List<String> stepsPreview)  v60RecipeCard,required TResult Function(@JsonKey(name: 'bean_id')  String? beanId,  String roastery, @JsonKey(name: 'bean_name')  String beanName,  String origin,  String process, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes, @JsonKey(name: 'image_url')  String? imageUrl)  coffeeBeanCard,required TResult Function(@JsonKey(name: 'image_url')  String imageUrl,  int width,  int height,  String? blurhash,  String? caption)  brewImageMedia,required TResult Function( String title,  String method, @JsonKey(name: 'accuracy_score')  int accuracyScore, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'brew_duration_sec')  int? brewDurationSec,  String? notes)  brewSessionResult,}) {final _that = this;
switch (_that) {
case V60RecipeCardAttachment():
return v60RecipeCard(_that.recipeId,_that.title,_that.brewerName,_that.doseGrams,_that.waterMl,_that.tempC,_that.targetDurationSec,_that.stepsPreview);case CoffeeBeanCardAttachment():
return coffeeBeanCard(_that.beanId,_that.roastery,_that.beanName,_that.origin,_that.process,_that.tastingNotes,_that.imageUrl);case BrewImageMediaAttachment():
return brewImageMedia(_that.imageUrl,_that.width,_that.height,_that.blurhash,_that.caption);case BrewSessionResultAttachment():
return brewSessionResult(_that.title,_that.method,_that.accuracyScore,_that.xpEarned,_that.brewDurationSec,_that.notes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@JsonKey(name: 'recipe_id')  String recipeId,  String title, @JsonKey(name: 'brewer_name')  String brewerName, @JsonKey(name: 'dose_grams')  double doseGrams, @JsonKey(name: 'water_ml')  double waterMl, @JsonKey(name: 'temp_c')  int tempC, @JsonKey(name: 'target_duration_sec')  int targetDurationSec, @JsonKey(name: 'steps_preview')  List<String> stepsPreview)?  v60RecipeCard,TResult? Function(@JsonKey(name: 'bean_id')  String? beanId,  String roastery, @JsonKey(name: 'bean_name')  String beanName,  String origin,  String process, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes, @JsonKey(name: 'image_url')  String? imageUrl)?  coffeeBeanCard,TResult? Function(@JsonKey(name: 'image_url')  String imageUrl,  int width,  int height,  String? blurhash,  String? caption)?  brewImageMedia,TResult? Function( String title,  String method, @JsonKey(name: 'accuracy_score')  int accuracyScore, @JsonKey(name: 'xp_earned')  int xpEarned, @JsonKey(name: 'brew_duration_sec')  int? brewDurationSec,  String? notes)?  brewSessionResult,}) {final _that = this;
switch (_that) {
case V60RecipeCardAttachment() when v60RecipeCard != null:
return v60RecipeCard(_that.recipeId,_that.title,_that.brewerName,_that.doseGrams,_that.waterMl,_that.tempC,_that.targetDurationSec,_that.stepsPreview);case CoffeeBeanCardAttachment() when coffeeBeanCard != null:
return coffeeBeanCard(_that.beanId,_that.roastery,_that.beanName,_that.origin,_that.process,_that.tastingNotes,_that.imageUrl);case BrewImageMediaAttachment() when brewImageMedia != null:
return brewImageMedia(_that.imageUrl,_that.width,_that.height,_that.blurhash,_that.caption);case BrewSessionResultAttachment() when brewSessionResult != null:
return brewSessionResult(_that.title,_that.method,_that.accuracyScore,_that.xpEarned,_that.brewDurationSec,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class V60RecipeCardAttachment implements InteractiveAttachment {
  const V60RecipeCardAttachment({@JsonKey(name: 'recipe_id') required this.recipeId, required this.title, @JsonKey(name: 'brewer_name') required this.brewerName, @JsonKey(name: 'dose_grams') required this.doseGrams, @JsonKey(name: 'water_ml') required this.waterMl, @JsonKey(name: 'temp_c') required this.tempC, @JsonKey(name: 'target_duration_sec') required this.targetDurationSec, @JsonKey(name: 'steps_preview')  List<String> stepsPreview = const <String>[],  String? $type}): _stepsPreview = stepsPreview,$type = $type ?? 'v60_recipe_card';
  factory V60RecipeCardAttachment.fromJson(Map<String, dynamic> json) => _$V60RecipeCardAttachmentFromJson(json);

@JsonKey(name: 'recipe_id') final  String recipeId;
 final  String title;
@JsonKey(name: 'brewer_name') final  String brewerName;
@JsonKey(name: 'dose_grams') final  double doseGrams;
@JsonKey(name: 'water_ml') final  double waterMl;
@JsonKey(name: 'temp_c') final  int tempC;
@JsonKey(name: 'target_duration_sec') final  int targetDurationSec;
 final  List<String> _stepsPreview;
@JsonKey(name: 'steps_preview') List<String> get stepsPreview {
  if (_stepsPreview is EqualUnmodifiableListView) return _stepsPreview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stepsPreview);
}


@JsonKey(name: 'kind')
final String $type;


/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V60RecipeCardAttachmentCopyWith<V60RecipeCardAttachment> get copyWith => _$V60RecipeCardAttachmentCopyWithImpl<V60RecipeCardAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V60RecipeCardAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V60RecipeCardAttachment&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.brewerName, brewerName) || other.brewerName == brewerName)&&(identical(other.doseGrams, doseGrams) || other.doseGrams == doseGrams)&&(identical(other.waterMl, waterMl) || other.waterMl == waterMl)&&(identical(other.tempC, tempC) || other.tempC == tempC)&&(identical(other.targetDurationSec, targetDurationSec) || other.targetDurationSec == targetDurationSec)&&const DeepCollectionEquality().equals(other._stepsPreview, _stepsPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,title,brewerName,doseGrams,waterMl,tempC,targetDurationSec,const DeepCollectionEquality().hash(_stepsPreview));

@override
String toString() {
  return 'InteractiveAttachment.v60RecipeCard(recipeId: $recipeId, title: $title, brewerName: $brewerName, doseGrams: $doseGrams, waterMl: $waterMl, tempC: $tempC, targetDurationSec: $targetDurationSec, stepsPreview: $stepsPreview)';
}


}

/// @nodoc
abstract mixin class $V60RecipeCardAttachmentCopyWith<$Res> implements $InteractiveAttachmentCopyWith<$Res> {
  factory $V60RecipeCardAttachmentCopyWith(V60RecipeCardAttachment value, $Res Function(V60RecipeCardAttachment) _then) = _$V60RecipeCardAttachmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'recipe_id') String recipeId, String title,@JsonKey(name: 'brewer_name') String brewerName,@JsonKey(name: 'dose_grams') double doseGrams,@JsonKey(name: 'water_ml') double waterMl,@JsonKey(name: 'temp_c') int tempC,@JsonKey(name: 'target_duration_sec') int targetDurationSec,@JsonKey(name: 'steps_preview') List<String> stepsPreview
});




}
/// @nodoc
class _$V60RecipeCardAttachmentCopyWithImpl<$Res>
    implements $V60RecipeCardAttachmentCopyWith<$Res> {
  _$V60RecipeCardAttachmentCopyWithImpl(this._self, this._then);

  final V60RecipeCardAttachment _self;
  final $Res Function(V60RecipeCardAttachment) _then;

/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? title = null,Object? brewerName = null,Object? doseGrams = null,Object? waterMl = null,Object? tempC = null,Object? targetDurationSec = null,Object? stepsPreview = null,}) {
  return _then(V60RecipeCardAttachment(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,brewerName: null == brewerName ? _self.brewerName : brewerName // ignore: cast_nullable_to_non_nullable
as String,doseGrams: null == doseGrams ? _self.doseGrams : doseGrams // ignore: cast_nullable_to_non_nullable
as double,waterMl: null == waterMl ? _self.waterMl : waterMl // ignore: cast_nullable_to_non_nullable
as double,tempC: null == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as int,targetDurationSec: null == targetDurationSec ? _self.targetDurationSec : targetDurationSec // ignore: cast_nullable_to_non_nullable
as int,stepsPreview: null == stepsPreview ? _self._stepsPreview : stepsPreview // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CoffeeBeanCardAttachment implements InteractiveAttachment {
  const CoffeeBeanCardAttachment({@JsonKey(name: 'bean_id') this.beanId, required this.roastery, @JsonKey(name: 'bean_name') required this.beanName, required this.origin, required this.process, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes = const <String>[], @JsonKey(name: 'image_url') this.imageUrl,  String? $type}): _tastingNotes = tastingNotes,$type = $type ?? 'coffee_bean_card';
  factory CoffeeBeanCardAttachment.fromJson(Map<String, dynamic> json) => _$CoffeeBeanCardAttachmentFromJson(json);

@JsonKey(name: 'bean_id') final  String? beanId;
 final  String roastery;
@JsonKey(name: 'bean_name') final  String beanName;
 final  String origin;
 final  String process;
 final  List<String> _tastingNotes;
@JsonKey(name: 'tasting_notes') List<String> get tastingNotes {
  if (_tastingNotes is EqualUnmodifiableListView) return _tastingNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tastingNotes);
}

@JsonKey(name: 'image_url') final  String? imageUrl;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoffeeBeanCardAttachmentCopyWith<CoffeeBeanCardAttachment> get copyWith => _$CoffeeBeanCardAttachmentCopyWithImpl<CoffeeBeanCardAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoffeeBeanCardAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoffeeBeanCardAttachment&&(identical(other.beanId, beanId) || other.beanId == beanId)&&(identical(other.roastery, roastery) || other.roastery == roastery)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.process, process) || other.process == process)&&const DeepCollectionEquality().equals(other._tastingNotes, _tastingNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,beanId,roastery,beanName,origin,process,const DeepCollectionEquality().hash(_tastingNotes),imageUrl);

@override
String toString() {
  return 'InteractiveAttachment.coffeeBeanCard(beanId: $beanId, roastery: $roastery, beanName: $beanName, origin: $origin, process: $process, tastingNotes: $tastingNotes, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $CoffeeBeanCardAttachmentCopyWith<$Res> implements $InteractiveAttachmentCopyWith<$Res> {
  factory $CoffeeBeanCardAttachmentCopyWith(CoffeeBeanCardAttachment value, $Res Function(CoffeeBeanCardAttachment) _then) = _$CoffeeBeanCardAttachmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bean_id') String? beanId, String roastery,@JsonKey(name: 'bean_name') String beanName, String origin, String process,@JsonKey(name: 'tasting_notes') List<String> tastingNotes,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class _$CoffeeBeanCardAttachmentCopyWithImpl<$Res>
    implements $CoffeeBeanCardAttachmentCopyWith<$Res> {
  _$CoffeeBeanCardAttachmentCopyWithImpl(this._self, this._then);

  final CoffeeBeanCardAttachment _self;
  final $Res Function(CoffeeBeanCardAttachment) _then;

/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? beanId = freezed,Object? roastery = null,Object? beanName = null,Object? origin = null,Object? process = null,Object? tastingNotes = null,Object? imageUrl = freezed,}) {
  return _then(CoffeeBeanCardAttachment(
beanId: freezed == beanId ? _self.beanId : beanId // ignore: cast_nullable_to_non_nullable
as String?,roastery: null == roastery ? _self.roastery : roastery // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,tastingNotes: null == tastingNotes ? _self._tastingNotes : tastingNotes // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BrewImageMediaAttachment implements InteractiveAttachment {
  const BrewImageMediaAttachment({@JsonKey(name: 'image_url') required this.imageUrl, required this.width, required this.height, this.blurhash, this.caption,  String? $type}): $type = $type ?? 'brew_image_media';
  factory BrewImageMediaAttachment.fromJson(Map<String, dynamic> json) => _$BrewImageMediaAttachmentFromJson(json);

@JsonKey(name: 'image_url') final  String imageUrl;
 final  int width;
 final  int height;
 final  String? blurhash;
 final  String? caption;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrewImageMediaAttachmentCopyWith<BrewImageMediaAttachment> get copyWith => _$BrewImageMediaAttachmentCopyWithImpl<BrewImageMediaAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrewImageMediaAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrewImageMediaAttachment&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.caption, caption) || other.caption == caption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl,width,height,blurhash,caption);

@override
String toString() {
  return 'InteractiveAttachment.brewImageMedia(imageUrl: $imageUrl, width: $width, height: $height, blurhash: $blurhash, caption: $caption)';
}


}

/// @nodoc
abstract mixin class $BrewImageMediaAttachmentCopyWith<$Res> implements $InteractiveAttachmentCopyWith<$Res> {
  factory $BrewImageMediaAttachmentCopyWith(BrewImageMediaAttachment value, $Res Function(BrewImageMediaAttachment) _then) = _$BrewImageMediaAttachmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'image_url') String imageUrl, int width, int height, String? blurhash, String? caption
});




}
/// @nodoc
class _$BrewImageMediaAttachmentCopyWithImpl<$Res>
    implements $BrewImageMediaAttachmentCopyWith<$Res> {
  _$BrewImageMediaAttachmentCopyWithImpl(this._self, this._then);

  final BrewImageMediaAttachment _self;
  final $Res Function(BrewImageMediaAttachment) _then;

/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imageUrl = null,Object? width = null,Object? height = null,Object? blurhash = freezed,Object? caption = freezed,}) {
  return _then(BrewImageMediaAttachment(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BrewSessionResultAttachment implements InteractiveAttachment {
  const BrewSessionResultAttachment({required this.title, required this.method, @JsonKey(name: 'accuracy_score') required this.accuracyScore, @JsonKey(name: 'xp_earned') required this.xpEarned, @JsonKey(name: 'brew_duration_sec') this.brewDurationSec, this.notes,  String? $type}): $type = $type ?? 'brew_session_result';
  factory BrewSessionResultAttachment.fromJson(Map<String, dynamic> json) => _$BrewSessionResultAttachmentFromJson(json);

 final  String title;
 final  String method;
@JsonKey(name: 'accuracy_score') final  int accuracyScore;
@JsonKey(name: 'xp_earned') final  int xpEarned;
@JsonKey(name: 'brew_duration_sec') final  int? brewDurationSec;
 final  String? notes;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrewSessionResultAttachmentCopyWith<BrewSessionResultAttachment> get copyWith => _$BrewSessionResultAttachmentCopyWithImpl<BrewSessionResultAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrewSessionResultAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrewSessionResultAttachment&&(identical(other.title, title) || other.title == title)&&(identical(other.method, method) || other.method == method)&&(identical(other.accuracyScore, accuracyScore) || other.accuracyScore == accuracyScore)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.brewDurationSec, brewDurationSec) || other.brewDurationSec == brewDurationSec)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,method,accuracyScore,xpEarned,brewDurationSec,notes);

@override
String toString() {
  return 'InteractiveAttachment.brewSessionResult(title: $title, method: $method, accuracyScore: $accuracyScore, xpEarned: $xpEarned, brewDurationSec: $brewDurationSec, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BrewSessionResultAttachmentCopyWith<$Res> implements $InteractiveAttachmentCopyWith<$Res> {
  factory $BrewSessionResultAttachmentCopyWith(BrewSessionResultAttachment value, $Res Function(BrewSessionResultAttachment) _then) = _$BrewSessionResultAttachmentCopyWithImpl;
@useResult
$Res call({
 String title, String method,@JsonKey(name: 'accuracy_score') int accuracyScore,@JsonKey(name: 'xp_earned') int xpEarned,@JsonKey(name: 'brew_duration_sec') int? brewDurationSec, String? notes
});




}
/// @nodoc
class _$BrewSessionResultAttachmentCopyWithImpl<$Res>
    implements $BrewSessionResultAttachmentCopyWith<$Res> {
  _$BrewSessionResultAttachmentCopyWithImpl(this._self, this._then);

  final BrewSessionResultAttachment _self;
  final $Res Function(BrewSessionResultAttachment) _then;

/// Create a copy of InteractiveAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? title = null,Object? method = null,Object? accuracyScore = null,Object? xpEarned = null,Object? brewDurationSec = freezed,Object? notes = freezed,}) {
  return _then(BrewSessionResultAttachment(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,accuracyScore: null == accuracyScore ? _self.accuracyScore : accuracyScore // ignore: cast_nullable_to_non_nullable
as int,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,brewDurationSec: freezed == brewDurationSec ? _self.brewDurationSec : brewDurationSec // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConversationCursorDto {

@JsonKey(name: 'conversation_id') String get conversationId;@JsonKey(name: 'local_max_seq_id') int get localMaxSeqId;
/// Create a copy of ConversationCursorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCursorDtoCopyWith<ConversationCursorDto> get copyWith => _$ConversationCursorDtoCopyWithImpl<ConversationCursorDto>(this as ConversationCursorDto, _$identity);

  /// Serializes this ConversationCursorDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationCursorDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.localMaxSeqId, localMaxSeqId) || other.localMaxSeqId == localMaxSeqId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,localMaxSeqId);

@override
String toString() {
  return 'ConversationCursorDto(conversationId: $conversationId, localMaxSeqId: $localMaxSeqId)';
}


}

/// @nodoc
abstract mixin class $ConversationCursorDtoCopyWith<$Res>  {
  factory $ConversationCursorDtoCopyWith(ConversationCursorDto value, $Res Function(ConversationCursorDto) _then) = _$ConversationCursorDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'local_max_seq_id') int localMaxSeqId
});




}
/// @nodoc
class _$ConversationCursorDtoCopyWithImpl<$Res>
    implements $ConversationCursorDtoCopyWith<$Res> {
  _$ConversationCursorDtoCopyWithImpl(this._self, this._then);

  final ConversationCursorDto _self;
  final $Res Function(ConversationCursorDto) _then;

/// Create a copy of ConversationCursorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? localMaxSeqId = null,}) {
  return _then(ConversationCursorDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,localMaxSeqId: null == localMaxSeqId ? _self.localMaxSeqId : localMaxSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationCursorDto].
extension ConversationCursorDtoPatterns on ConversationCursorDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationCursorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationCursorDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationCursorDto value)  $default,){
final _that = this;
switch (_that) {
case _ConversationCursorDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationCursorDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationCursorDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'local_max_seq_id')  int localMaxSeqId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationCursorDto() when $default != null:
return $default(_that.conversationId,_that.localMaxSeqId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'local_max_seq_id')  int localMaxSeqId)  $default,) {final _that = this;
switch (_that) {
case _ConversationCursorDto():
return $default(_that.conversationId,_that.localMaxSeqId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'local_max_seq_id')  int localMaxSeqId)?  $default,) {final _that = this;
switch (_that) {
case _ConversationCursorDto() when $default != null:
return $default(_that.conversationId,_that.localMaxSeqId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationCursorDto implements ConversationCursorDto {
  const _ConversationCursorDto({@JsonKey(name: 'conversation_id') required this.conversationId, @JsonKey(name: 'local_max_seq_id') required this.localMaxSeqId});
  factory _ConversationCursorDto.fromJson(Map<String, dynamic> json) => _$ConversationCursorDtoFromJson(json);

@override@JsonKey(name: 'conversation_id') final  String conversationId;
@override@JsonKey(name: 'local_max_seq_id') final  int localMaxSeqId;

/// Create a copy of ConversationCursorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCursorDtoCopyWith<_ConversationCursorDto> get copyWith => __$ConversationCursorDtoCopyWithImpl<_ConversationCursorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationCursorDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationCursorDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.localMaxSeqId, localMaxSeqId) || other.localMaxSeqId == localMaxSeqId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,localMaxSeqId);

@override
String toString() {
  return 'ConversationCursorDto(conversationId: $conversationId, localMaxSeqId: $localMaxSeqId)';
}


}

/// @nodoc
abstract mixin class _$ConversationCursorDtoCopyWith<$Res> implements $ConversationCursorDtoCopyWith<$Res> {
  factory _$ConversationCursorDtoCopyWith(_ConversationCursorDto value, $Res Function(_ConversationCursorDto) _then) = __$ConversationCursorDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'local_max_seq_id') int localMaxSeqId
});




}
/// @nodoc
class __$ConversationCursorDtoCopyWithImpl<$Res>
    implements _$ConversationCursorDtoCopyWith<$Res> {
  __$ConversationCursorDtoCopyWithImpl(this._self, this._then);

  final _ConversationCursorDto _self;
  final $Res Function(_ConversationCursorDto) _then;

/// Create a copy of ConversationCursorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? localMaxSeqId = null,}) {
  return _then(_ConversationCursorDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,localMaxSeqId: null == localMaxSeqId ? _self.localMaxSeqId : localMaxSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChatMessageDto {

 String get id;@JsonKey(name: 'conversation_id') String get conversationId;@JsonKey(name: 'seq_id') int get seqId;@JsonKey(name: 'sender_id') String get senderId;@JsonKey(name: 'client_msg_id') String get clientMsgId;@JsonKey(name: 'reply_to_msg_id') String? get replyToMsgId;@JsonKey(name: 'message_type') ChatMessageType get messageType;@JsonKey(name: 'body_text') String? get bodyText; InteractiveAttachment? get attachment;@JsonKey(name: 'is_edited') bool get isEdited;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageDtoCopyWith<ChatMessageDto> get copyWith => _$ChatMessageDtoCopyWithImpl<ChatMessageDto>(this as ChatMessageDto, _$identity);

  /// Serializes this ChatMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.seqId, seqId) || other.seqId == seqId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.replyToMsgId, replyToMsgId) || other.replyToMsgId == replyToMsgId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.attachment, attachment) || other.attachment == attachment)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,seqId,senderId,clientMsgId,replyToMsgId,messageType,bodyText,attachment,isEdited,isDeleted,createdAt);

@override
String toString() {
  return 'ChatMessageDto(id: $id, conversationId: $conversationId, seqId: $seqId, senderId: $senderId, clientMsgId: $clientMsgId, replyToMsgId: $replyToMsgId, messageType: $messageType, bodyText: $bodyText, attachment: $attachment, isEdited: $isEdited, isDeleted: $isDeleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageDtoCopyWith<$Res>  {
  factory $ChatMessageDtoCopyWith(ChatMessageDto value, $Res Function(ChatMessageDto) _then) = _$ChatMessageDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'seq_id') int seqId,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'client_msg_id') String clientMsgId,@JsonKey(name: 'reply_to_msg_id') String? replyToMsgId,@JsonKey(name: 'message_type') ChatMessageType messageType,@JsonKey(name: 'body_text') String? bodyText, InteractiveAttachment? attachment,@JsonKey(name: 'is_edited') bool isEdited,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'created_at') DateTime createdAt
});


$InteractiveAttachmentCopyWith<$Res>? get attachment;

}
/// @nodoc
class _$ChatMessageDtoCopyWithImpl<$Res>
    implements $ChatMessageDtoCopyWith<$Res> {
  _$ChatMessageDtoCopyWithImpl(this._self, this._then);

  final ChatMessageDto _self;
  final $Res Function(ChatMessageDto) _then;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? seqId = null,Object? senderId = null,Object? clientMsgId = null,Object? replyToMsgId = freezed,Object? messageType = null,Object? bodyText = freezed,Object? attachment = freezed,Object? isEdited = null,Object? isDeleted = null,Object? createdAt = null,}) {
  return _then(ChatMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,seqId: null == seqId ? _self.seqId : seqId // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,replyToMsgId: freezed == replyToMsgId ? _self.replyToMsgId : replyToMsgId // ignore: cast_nullable_to_non_nullable
as String?,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType,bodyText: freezed == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String?,attachment: freezed == attachment ? _self.attachment : attachment // ignore: cast_nullable_to_non_nullable
as InteractiveAttachment?,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InteractiveAttachmentCopyWith<$Res>? get attachment {
    if (_self.attachment == null) {
    return null;
  }

  return $InteractiveAttachmentCopyWith<$Res>(_self.attachment!, (value) {
    return _then(_self.copyWith(attachment: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatMessageDto].
extension ChatMessageDtoPatterns on ChatMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'seq_id')  int seqId, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'client_msg_id')  String clientMsgId, @JsonKey(name: 'reply_to_msg_id')  String? replyToMsgId, @JsonKey(name: 'message_type')  ChatMessageType messageType, @JsonKey(name: 'body_text')  String? bodyText,  InteractiveAttachment? attachment, @JsonKey(name: 'is_edited')  bool isEdited, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
return $default(_that.id,_that.conversationId,_that.seqId,_that.senderId,_that.clientMsgId,_that.replyToMsgId,_that.messageType,_that.bodyText,_that.attachment,_that.isEdited,_that.isDeleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'seq_id')  int seqId, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'client_msg_id')  String clientMsgId, @JsonKey(name: 'reply_to_msg_id')  String? replyToMsgId, @JsonKey(name: 'message_type')  ChatMessageType messageType, @JsonKey(name: 'body_text')  String? bodyText,  InteractiveAttachment? attachment, @JsonKey(name: 'is_edited')  bool isEdited, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageDto():
return $default(_that.id,_that.conversationId,_that.seqId,_that.senderId,_that.clientMsgId,_that.replyToMsgId,_that.messageType,_that.bodyText,_that.attachment,_that.isEdited,_that.isDeleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'seq_id')  int seqId, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'client_msg_id')  String clientMsgId, @JsonKey(name: 'reply_to_msg_id')  String? replyToMsgId, @JsonKey(name: 'message_type')  ChatMessageType messageType, @JsonKey(name: 'body_text')  String? bodyText,  InteractiveAttachment? attachment, @JsonKey(name: 'is_edited')  bool isEdited, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
return $default(_that.id,_that.conversationId,_that.seqId,_that.senderId,_that.clientMsgId,_that.replyToMsgId,_that.messageType,_that.bodyText,_that.attachment,_that.isEdited,_that.isDeleted,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageDto implements ChatMessageDto {
  const _ChatMessageDto({required this.id, @JsonKey(name: 'conversation_id') required this.conversationId, @JsonKey(name: 'seq_id') required this.seqId, @JsonKey(name: 'sender_id') required this.senderId, @JsonKey(name: 'client_msg_id') required this.clientMsgId, @JsonKey(name: 'reply_to_msg_id') this.replyToMsgId, @JsonKey(name: 'message_type') required this.messageType, @JsonKey(name: 'body_text') this.bodyText, this.attachment, @JsonKey(name: 'is_edited') this.isEdited = false, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'created_at') required this.createdAt});
  factory _ChatMessageDto.fromJson(Map<String, dynamic> json) => _$ChatMessageDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'conversation_id') final  String conversationId;
@override@JsonKey(name: 'seq_id') final  int seqId;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override@JsonKey(name: 'client_msg_id') final  String clientMsgId;
@override@JsonKey(name: 'reply_to_msg_id') final  String? replyToMsgId;
@override@JsonKey(name: 'message_type') final  ChatMessageType messageType;
@override@JsonKey(name: 'body_text') final  String? bodyText;
@override final  InteractiveAttachment? attachment;
@override@JsonKey(name: 'is_edited') final  bool isEdited;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageDtoCopyWith<_ChatMessageDto> get copyWith => __$ChatMessageDtoCopyWithImpl<_ChatMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.seqId, seqId) || other.seqId == seqId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.replyToMsgId, replyToMsgId) || other.replyToMsgId == replyToMsgId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.attachment, attachment) || other.attachment == attachment)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,seqId,senderId,clientMsgId,replyToMsgId,messageType,bodyText,attachment,isEdited,isDeleted,createdAt);

@override
String toString() {
  return 'ChatMessageDto(id: $id, conversationId: $conversationId, seqId: $seqId, senderId: $senderId, clientMsgId: $clientMsgId, replyToMsgId: $replyToMsgId, messageType: $messageType, bodyText: $bodyText, attachment: $attachment, isEdited: $isEdited, isDeleted: $isDeleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageDtoCopyWith<$Res> implements $ChatMessageDtoCopyWith<$Res> {
  factory _$ChatMessageDtoCopyWith(_ChatMessageDto value, $Res Function(_ChatMessageDto) _then) = __$ChatMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'seq_id') int seqId,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'client_msg_id') String clientMsgId,@JsonKey(name: 'reply_to_msg_id') String? replyToMsgId,@JsonKey(name: 'message_type') ChatMessageType messageType,@JsonKey(name: 'body_text') String? bodyText, InteractiveAttachment? attachment,@JsonKey(name: 'is_edited') bool isEdited,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'created_at') DateTime createdAt
});


@override $InteractiveAttachmentCopyWith<$Res>? get attachment;

}
/// @nodoc
class __$ChatMessageDtoCopyWithImpl<$Res>
    implements _$ChatMessageDtoCopyWith<$Res> {
  __$ChatMessageDtoCopyWithImpl(this._self, this._then);

  final _ChatMessageDto _self;
  final $Res Function(_ChatMessageDto) _then;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? seqId = null,Object? senderId = null,Object? clientMsgId = null,Object? replyToMsgId = freezed,Object? messageType = null,Object? bodyText = freezed,Object? attachment = freezed,Object? isEdited = null,Object? isDeleted = null,Object? createdAt = null,}) {
  return _then(_ChatMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,seqId: null == seqId ? _self.seqId : seqId // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,replyToMsgId: freezed == replyToMsgId ? _self.replyToMsgId : replyToMsgId // ignore: cast_nullable_to_non_nullable
as String?,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType,bodyText: freezed == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String?,attachment: freezed == attachment ? _self.attachment : attachment // ignore: cast_nullable_to_non_nullable
as InteractiveAttachment?,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InteractiveAttachmentCopyWith<$Res>? get attachment {
    if (_self.attachment == null) {
    return null;
  }

  return $InteractiveAttachmentCopyWith<$Res>(_self.attachment!, (value) {
    return _then(_self.copyWith(attachment: value));
  });
}
}


/// @nodoc
mixin _$ParticipantWatermarkDto {

@JsonKey(name: 'conversation_id') String get conversationId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'last_delivered_seq_id') int get lastDeliveredSeqId;@JsonKey(name: 'last_read_seq_id') int get lastReadSeqId;
/// Create a copy of ParticipantWatermarkDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantWatermarkDtoCopyWith<ParticipantWatermarkDto> get copyWith => _$ParticipantWatermarkDtoCopyWithImpl<ParticipantWatermarkDto>(this as ParticipantWatermarkDto, _$identity);

  /// Serializes this ParticipantWatermarkDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantWatermarkDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastDeliveredSeqId, lastDeliveredSeqId) || other.lastDeliveredSeqId == lastDeliveredSeqId)&&(identical(other.lastReadSeqId, lastReadSeqId) || other.lastReadSeqId == lastReadSeqId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,userId,lastDeliveredSeqId,lastReadSeqId);

@override
String toString() {
  return 'ParticipantWatermarkDto(conversationId: $conversationId, userId: $userId, lastDeliveredSeqId: $lastDeliveredSeqId, lastReadSeqId: $lastReadSeqId)';
}


}

/// @nodoc
abstract mixin class $ParticipantWatermarkDtoCopyWith<$Res>  {
  factory $ParticipantWatermarkDtoCopyWith(ParticipantWatermarkDto value, $Res Function(ParticipantWatermarkDto) _then) = _$ParticipantWatermarkDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'last_delivered_seq_id') int lastDeliveredSeqId,@JsonKey(name: 'last_read_seq_id') int lastReadSeqId
});




}
/// @nodoc
class _$ParticipantWatermarkDtoCopyWithImpl<$Res>
    implements $ParticipantWatermarkDtoCopyWith<$Res> {
  _$ParticipantWatermarkDtoCopyWithImpl(this._self, this._then);

  final ParticipantWatermarkDto _self;
  final $Res Function(ParticipantWatermarkDto) _then;

/// Create a copy of ParticipantWatermarkDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? userId = null,Object? lastDeliveredSeqId = null,Object? lastReadSeqId = null,}) {
  return _then(ParticipantWatermarkDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastDeliveredSeqId: null == lastDeliveredSeqId ? _self.lastDeliveredSeqId : lastDeliveredSeqId // ignore: cast_nullable_to_non_nullable
as int,lastReadSeqId: null == lastReadSeqId ? _self.lastReadSeqId : lastReadSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipantWatermarkDto].
extension ParticipantWatermarkDtoPatterns on ParticipantWatermarkDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantWatermarkDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantWatermarkDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantWatermarkDto value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantWatermarkDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantWatermarkDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantWatermarkDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'last_delivered_seq_id')  int lastDeliveredSeqId, @JsonKey(name: 'last_read_seq_id')  int lastReadSeqId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantWatermarkDto() when $default != null:
return $default(_that.conversationId,_that.userId,_that.lastDeliveredSeqId,_that.lastReadSeqId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'last_delivered_seq_id')  int lastDeliveredSeqId, @JsonKey(name: 'last_read_seq_id')  int lastReadSeqId)  $default,) {final _that = this;
switch (_that) {
case _ParticipantWatermarkDto():
return $default(_that.conversationId,_that.userId,_that.lastDeliveredSeqId,_that.lastReadSeqId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'last_delivered_seq_id')  int lastDeliveredSeqId, @JsonKey(name: 'last_read_seq_id')  int lastReadSeqId)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantWatermarkDto() when $default != null:
return $default(_that.conversationId,_that.userId,_that.lastDeliveredSeqId,_that.lastReadSeqId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParticipantWatermarkDto implements ParticipantWatermarkDto {
  const _ParticipantWatermarkDto({@JsonKey(name: 'conversation_id') required this.conversationId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'last_delivered_seq_id') required this.lastDeliveredSeqId, @JsonKey(name: 'last_read_seq_id') required this.lastReadSeqId});
  factory _ParticipantWatermarkDto.fromJson(Map<String, dynamic> json) => _$ParticipantWatermarkDtoFromJson(json);

@override@JsonKey(name: 'conversation_id') final  String conversationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'last_delivered_seq_id') final  int lastDeliveredSeqId;
@override@JsonKey(name: 'last_read_seq_id') final  int lastReadSeqId;

/// Create a copy of ParticipantWatermarkDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantWatermarkDtoCopyWith<_ParticipantWatermarkDto> get copyWith => __$ParticipantWatermarkDtoCopyWithImpl<_ParticipantWatermarkDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantWatermarkDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantWatermarkDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastDeliveredSeqId, lastDeliveredSeqId) || other.lastDeliveredSeqId == lastDeliveredSeqId)&&(identical(other.lastReadSeqId, lastReadSeqId) || other.lastReadSeqId == lastReadSeqId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,userId,lastDeliveredSeqId,lastReadSeqId);

@override
String toString() {
  return 'ParticipantWatermarkDto(conversationId: $conversationId, userId: $userId, lastDeliveredSeqId: $lastDeliveredSeqId, lastReadSeqId: $lastReadSeqId)';
}


}

/// @nodoc
abstract mixin class _$ParticipantWatermarkDtoCopyWith<$Res> implements $ParticipantWatermarkDtoCopyWith<$Res> {
  factory _$ParticipantWatermarkDtoCopyWith(_ParticipantWatermarkDto value, $Res Function(_ParticipantWatermarkDto) _then) = __$ParticipantWatermarkDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'last_delivered_seq_id') int lastDeliveredSeqId,@JsonKey(name: 'last_read_seq_id') int lastReadSeqId
});




}
/// @nodoc
class __$ParticipantWatermarkDtoCopyWithImpl<$Res>
    implements _$ParticipantWatermarkDtoCopyWith<$Res> {
  __$ParticipantWatermarkDtoCopyWithImpl(this._self, this._then);

  final _ParticipantWatermarkDto _self;
  final $Res Function(_ParticipantWatermarkDto) _then;

/// Create a copy of ParticipantWatermarkDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? userId = null,Object? lastDeliveredSeqId = null,Object? lastReadSeqId = null,}) {
  return _then(_ParticipantWatermarkDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastDeliveredSeqId: null == lastDeliveredSeqId ? _self.lastDeliveredSeqId : lastDeliveredSeqId // ignore: cast_nullable_to_non_nullable
as int,lastReadSeqId: null == lastReadSeqId ? _self.lastReadSeqId : lastReadSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChatConversationDto {

 String get id; String get kind; String get title;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'last_seq_id') int get lastSeqId;@JsonKey(name: 'unread_count') int get unreadCount;@JsonKey(name: 'my_read_seq_id') int get myReadSeqId;@JsonKey(name: 'my_delivered_seq_id') int get myDeliveredSeqId;@JsonKey(name: 'last_message_preview') String? get lastMessagePreview;@JsonKey(name: 'last_message_at') DateTime? get lastMessageAt;@JsonKey(name: 'peer_user_id') String? get peerUserId;@JsonKey(name: 'peer_username') String? get peerUsername;@JsonKey(name: 'peer_online') bool get peerOnline;@JsonKey(name: 'peer_last_seen_at') DateTime? get peerLastSeenAt;@JsonKey(name: 'peer_delivered_seq_id') int get peerDeliveredSeqId;@JsonKey(name: 'peer_read_seq_id') int get peerReadSeqId;
/// Create a copy of ChatConversationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationDtoCopyWith<ChatConversationDto> get copyWith => _$ChatConversationDtoCopyWithImpl<ChatConversationDto>(this as ChatConversationDto, _$identity);

  /// Serializes this ChatConversationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.lastSeqId, lastSeqId) || other.lastSeqId == lastSeqId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.myReadSeqId, myReadSeqId) || other.myReadSeqId == myReadSeqId)&&(identical(other.myDeliveredSeqId, myDeliveredSeqId) || other.myDeliveredSeqId == myDeliveredSeqId)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.peerUserId, peerUserId) || other.peerUserId == peerUserId)&&(identical(other.peerUsername, peerUsername) || other.peerUsername == peerUsername)&&(identical(other.peerOnline, peerOnline) || other.peerOnline == peerOnline)&&(identical(other.peerLastSeenAt, peerLastSeenAt) || other.peerLastSeenAt == peerLastSeenAt)&&(identical(other.peerDeliveredSeqId, peerDeliveredSeqId) || other.peerDeliveredSeqId == peerDeliveredSeqId)&&(identical(other.peerReadSeqId, peerReadSeqId) || other.peerReadSeqId == peerReadSeqId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,title,avatarUrl,lastSeqId,unreadCount,myReadSeqId,myDeliveredSeqId,lastMessagePreview,lastMessageAt,peerUserId,peerUsername,peerOnline,peerLastSeenAt,peerDeliveredSeqId,peerReadSeqId);

@override
String toString() {
  return 'ChatConversationDto(id: $id, kind: $kind, title: $title, avatarUrl: $avatarUrl, lastSeqId: $lastSeqId, unreadCount: $unreadCount, myReadSeqId: $myReadSeqId, myDeliveredSeqId: $myDeliveredSeqId, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, peerUserId: $peerUserId, peerUsername: $peerUsername, peerOnline: $peerOnline, peerLastSeenAt: $peerLastSeenAt, peerDeliveredSeqId: $peerDeliveredSeqId, peerReadSeqId: $peerReadSeqId)';
}


}

/// @nodoc
abstract mixin class $ChatConversationDtoCopyWith<$Res>  {
  factory $ChatConversationDtoCopyWith(ChatConversationDto value, $Res Function(ChatConversationDto) _then) = _$ChatConversationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String title,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'last_seq_id') int lastSeqId,@JsonKey(name: 'unread_count') int unreadCount,@JsonKey(name: 'my_read_seq_id') int myReadSeqId,@JsonKey(name: 'my_delivered_seq_id') int myDeliveredSeqId,@JsonKey(name: 'last_message_preview') String? lastMessagePreview,@JsonKey(name: 'last_message_at') DateTime? lastMessageAt,@JsonKey(name: 'peer_user_id') String? peerUserId,@JsonKey(name: 'peer_username') String? peerUsername,@JsonKey(name: 'peer_online') bool peerOnline,@JsonKey(name: 'peer_last_seen_at') DateTime? peerLastSeenAt,@JsonKey(name: 'peer_delivered_seq_id') int peerDeliveredSeqId,@JsonKey(name: 'peer_read_seq_id') int peerReadSeqId
});




}
/// @nodoc
class _$ChatConversationDtoCopyWithImpl<$Res>
    implements $ChatConversationDtoCopyWith<$Res> {
  _$ChatConversationDtoCopyWithImpl(this._self, this._then);

  final ChatConversationDto _self;
  final $Res Function(ChatConversationDto) _then;

/// Create a copy of ChatConversationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? avatarUrl = freezed,Object? lastSeqId = null,Object? unreadCount = null,Object? myReadSeqId = null,Object? myDeliveredSeqId = null,Object? lastMessagePreview = freezed,Object? lastMessageAt = freezed,Object? peerUserId = freezed,Object? peerUsername = freezed,Object? peerOnline = null,Object? peerLastSeenAt = freezed,Object? peerDeliveredSeqId = null,Object? peerReadSeqId = null,}) {
  return _then(ChatConversationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,lastSeqId: null == lastSeqId ? _self.lastSeqId : lastSeqId // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,myReadSeqId: null == myReadSeqId ? _self.myReadSeqId : myReadSeqId // ignore: cast_nullable_to_non_nullable
as int,myDeliveredSeqId: null == myDeliveredSeqId ? _self.myDeliveredSeqId : myDeliveredSeqId // ignore: cast_nullable_to_non_nullable
as int,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,peerUserId: freezed == peerUserId ? _self.peerUserId : peerUserId // ignore: cast_nullable_to_non_nullable
as String?,peerUsername: freezed == peerUsername ? _self.peerUsername : peerUsername // ignore: cast_nullable_to_non_nullable
as String?,peerOnline: null == peerOnline ? _self.peerOnline : peerOnline // ignore: cast_nullable_to_non_nullable
as bool,peerLastSeenAt: freezed == peerLastSeenAt ? _self.peerLastSeenAt : peerLastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,peerDeliveredSeqId: null == peerDeliveredSeqId ? _self.peerDeliveredSeqId : peerDeliveredSeqId // ignore: cast_nullable_to_non_nullable
as int,peerReadSeqId: null == peerReadSeqId ? _self.peerReadSeqId : peerReadSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversationDto].
extension ChatConversationDtoPatterns on ChatConversationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversationDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversationDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String title, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'last_seq_id')  int lastSeqId, @JsonKey(name: 'unread_count')  int unreadCount, @JsonKey(name: 'my_read_seq_id')  int myReadSeqId, @JsonKey(name: 'my_delivered_seq_id')  int myDeliveredSeqId, @JsonKey(name: 'last_message_preview')  String? lastMessagePreview, @JsonKey(name: 'last_message_at')  DateTime? lastMessageAt, @JsonKey(name: 'peer_user_id')  String? peerUserId, @JsonKey(name: 'peer_username')  String? peerUsername, @JsonKey(name: 'peer_online')  bool peerOnline, @JsonKey(name: 'peer_last_seen_at')  DateTime? peerLastSeenAt, @JsonKey(name: 'peer_delivered_seq_id')  int peerDeliveredSeqId, @JsonKey(name: 'peer_read_seq_id')  int peerReadSeqId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversationDto() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.avatarUrl,_that.lastSeqId,_that.unreadCount,_that.myReadSeqId,_that.myDeliveredSeqId,_that.lastMessagePreview,_that.lastMessageAt,_that.peerUserId,_that.peerUsername,_that.peerOnline,_that.peerLastSeenAt,_that.peerDeliveredSeqId,_that.peerReadSeqId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String title, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'last_seq_id')  int lastSeqId, @JsonKey(name: 'unread_count')  int unreadCount, @JsonKey(name: 'my_read_seq_id')  int myReadSeqId, @JsonKey(name: 'my_delivered_seq_id')  int myDeliveredSeqId, @JsonKey(name: 'last_message_preview')  String? lastMessagePreview, @JsonKey(name: 'last_message_at')  DateTime? lastMessageAt, @JsonKey(name: 'peer_user_id')  String? peerUserId, @JsonKey(name: 'peer_username')  String? peerUsername, @JsonKey(name: 'peer_online')  bool peerOnline, @JsonKey(name: 'peer_last_seen_at')  DateTime? peerLastSeenAt, @JsonKey(name: 'peer_delivered_seq_id')  int peerDeliveredSeqId, @JsonKey(name: 'peer_read_seq_id')  int peerReadSeqId)  $default,) {final _that = this;
switch (_that) {
case _ChatConversationDto():
return $default(_that.id,_that.kind,_that.title,_that.avatarUrl,_that.lastSeqId,_that.unreadCount,_that.myReadSeqId,_that.myDeliveredSeqId,_that.lastMessagePreview,_that.lastMessageAt,_that.peerUserId,_that.peerUsername,_that.peerOnline,_that.peerLastSeenAt,_that.peerDeliveredSeqId,_that.peerReadSeqId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String title, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'last_seq_id')  int lastSeqId, @JsonKey(name: 'unread_count')  int unreadCount, @JsonKey(name: 'my_read_seq_id')  int myReadSeqId, @JsonKey(name: 'my_delivered_seq_id')  int myDeliveredSeqId, @JsonKey(name: 'last_message_preview')  String? lastMessagePreview, @JsonKey(name: 'last_message_at')  DateTime? lastMessageAt, @JsonKey(name: 'peer_user_id')  String? peerUserId, @JsonKey(name: 'peer_username')  String? peerUsername, @JsonKey(name: 'peer_online')  bool peerOnline, @JsonKey(name: 'peer_last_seen_at')  DateTime? peerLastSeenAt, @JsonKey(name: 'peer_delivered_seq_id')  int peerDeliveredSeqId, @JsonKey(name: 'peer_read_seq_id')  int peerReadSeqId)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversationDto() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.avatarUrl,_that.lastSeqId,_that.unreadCount,_that.myReadSeqId,_that.myDeliveredSeqId,_that.lastMessagePreview,_that.lastMessageAt,_that.peerUserId,_that.peerUsername,_that.peerOnline,_that.peerLastSeenAt,_that.peerDeliveredSeqId,_that.peerReadSeqId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatConversationDto implements ChatConversationDto {
  const _ChatConversationDto({required this.id, required this.kind, required this.title, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'last_seq_id') this.lastSeqId = 0, @JsonKey(name: 'unread_count') this.unreadCount = 0, @JsonKey(name: 'my_read_seq_id') this.myReadSeqId = 0, @JsonKey(name: 'my_delivered_seq_id') this.myDeliveredSeqId = 0, @JsonKey(name: 'last_message_preview') this.lastMessagePreview, @JsonKey(name: 'last_message_at') this.lastMessageAt, @JsonKey(name: 'peer_user_id') this.peerUserId, @JsonKey(name: 'peer_username') this.peerUsername, @JsonKey(name: 'peer_online') this.peerOnline = false, @JsonKey(name: 'peer_last_seen_at') this.peerLastSeenAt, @JsonKey(name: 'peer_delivered_seq_id') this.peerDeliveredSeqId = 0, @JsonKey(name: 'peer_read_seq_id') this.peerReadSeqId = 0});
  factory _ChatConversationDto.fromJson(Map<String, dynamic> json) => _$ChatConversationDtoFromJson(json);

@override final  String id;
@override final  String kind;
@override final  String title;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'last_seq_id') final  int lastSeqId;
@override@JsonKey(name: 'unread_count') final  int unreadCount;
@override@JsonKey(name: 'my_read_seq_id') final  int myReadSeqId;
@override@JsonKey(name: 'my_delivered_seq_id') final  int myDeliveredSeqId;
@override@JsonKey(name: 'last_message_preview') final  String? lastMessagePreview;
@override@JsonKey(name: 'last_message_at') final  DateTime? lastMessageAt;
@override@JsonKey(name: 'peer_user_id') final  String? peerUserId;
@override@JsonKey(name: 'peer_username') final  String? peerUsername;
@override@JsonKey(name: 'peer_online') final  bool peerOnline;
@override@JsonKey(name: 'peer_last_seen_at') final  DateTime? peerLastSeenAt;
@override@JsonKey(name: 'peer_delivered_seq_id') final  int peerDeliveredSeqId;
@override@JsonKey(name: 'peer_read_seq_id') final  int peerReadSeqId;

/// Create a copy of ChatConversationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationDtoCopyWith<_ChatConversationDto> get copyWith => __$ChatConversationDtoCopyWithImpl<_ChatConversationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatConversationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.lastSeqId, lastSeqId) || other.lastSeqId == lastSeqId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.myReadSeqId, myReadSeqId) || other.myReadSeqId == myReadSeqId)&&(identical(other.myDeliveredSeqId, myDeliveredSeqId) || other.myDeliveredSeqId == myDeliveredSeqId)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.peerUserId, peerUserId) || other.peerUserId == peerUserId)&&(identical(other.peerUsername, peerUsername) || other.peerUsername == peerUsername)&&(identical(other.peerOnline, peerOnline) || other.peerOnline == peerOnline)&&(identical(other.peerLastSeenAt, peerLastSeenAt) || other.peerLastSeenAt == peerLastSeenAt)&&(identical(other.peerDeliveredSeqId, peerDeliveredSeqId) || other.peerDeliveredSeqId == peerDeliveredSeqId)&&(identical(other.peerReadSeqId, peerReadSeqId) || other.peerReadSeqId == peerReadSeqId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,title,avatarUrl,lastSeqId,unreadCount,myReadSeqId,myDeliveredSeqId,lastMessagePreview,lastMessageAt,peerUserId,peerUsername,peerOnline,peerLastSeenAt,peerDeliveredSeqId,peerReadSeqId);

@override
String toString() {
  return 'ChatConversationDto(id: $id, kind: $kind, title: $title, avatarUrl: $avatarUrl, lastSeqId: $lastSeqId, unreadCount: $unreadCount, myReadSeqId: $myReadSeqId, myDeliveredSeqId: $myDeliveredSeqId, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, peerUserId: $peerUserId, peerUsername: $peerUsername, peerOnline: $peerOnline, peerLastSeenAt: $peerLastSeenAt, peerDeliveredSeqId: $peerDeliveredSeqId, peerReadSeqId: $peerReadSeqId)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationDtoCopyWith<$Res> implements $ChatConversationDtoCopyWith<$Res> {
  factory _$ChatConversationDtoCopyWith(_ChatConversationDto value, $Res Function(_ChatConversationDto) _then) = __$ChatConversationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String title,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'last_seq_id') int lastSeqId,@JsonKey(name: 'unread_count') int unreadCount,@JsonKey(name: 'my_read_seq_id') int myReadSeqId,@JsonKey(name: 'my_delivered_seq_id') int myDeliveredSeqId,@JsonKey(name: 'last_message_preview') String? lastMessagePreview,@JsonKey(name: 'last_message_at') DateTime? lastMessageAt,@JsonKey(name: 'peer_user_id') String? peerUserId,@JsonKey(name: 'peer_username') String? peerUsername,@JsonKey(name: 'peer_online') bool peerOnline,@JsonKey(name: 'peer_last_seen_at') DateTime? peerLastSeenAt,@JsonKey(name: 'peer_delivered_seq_id') int peerDeliveredSeqId,@JsonKey(name: 'peer_read_seq_id') int peerReadSeqId
});




}
/// @nodoc
class __$ChatConversationDtoCopyWithImpl<$Res>
    implements _$ChatConversationDtoCopyWith<$Res> {
  __$ChatConversationDtoCopyWithImpl(this._self, this._then);

  final _ChatConversationDto _self;
  final $Res Function(_ChatConversationDto) _then;

/// Create a copy of ChatConversationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? avatarUrl = freezed,Object? lastSeqId = null,Object? unreadCount = null,Object? myReadSeqId = null,Object? myDeliveredSeqId = null,Object? lastMessagePreview = freezed,Object? lastMessageAt = freezed,Object? peerUserId = freezed,Object? peerUsername = freezed,Object? peerOnline = null,Object? peerLastSeenAt = freezed,Object? peerDeliveredSeqId = null,Object? peerReadSeqId = null,}) {
  return _then(_ChatConversationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,lastSeqId: null == lastSeqId ? _self.lastSeqId : lastSeqId // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,myReadSeqId: null == myReadSeqId ? _self.myReadSeqId : myReadSeqId // ignore: cast_nullable_to_non_nullable
as int,myDeliveredSeqId: null == myDeliveredSeqId ? _self.myDeliveredSeqId : myDeliveredSeqId // ignore: cast_nullable_to_non_nullable
as int,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,peerUserId: freezed == peerUserId ? _self.peerUserId : peerUserId // ignore: cast_nullable_to_non_nullable
as String?,peerUsername: freezed == peerUsername ? _self.peerUsername : peerUsername // ignore: cast_nullable_to_non_nullable
as String?,peerOnline: null == peerOnline ? _self.peerOnline : peerOnline // ignore: cast_nullable_to_non_nullable
as bool,peerLastSeenAt: freezed == peerLastSeenAt ? _self.peerLastSeenAt : peerLastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,peerDeliveredSeqId: null == peerDeliveredSeqId ? _self.peerDeliveredSeqId : peerDeliveredSeqId // ignore: cast_nullable_to_non_nullable
as int,peerReadSeqId: null == peerReadSeqId ? _self.peerReadSeqId : peerReadSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChatPeerDto {

 String get id; String get username;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'avatar_url') String? get avatarUrl; String get role;@JsonKey(name: 'is_online') bool get isOnline;@JsonKey(name: 'last_seen_at') DateTime? get lastSeenAt;
/// Create a copy of ChatPeerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatPeerDtoCopyWith<ChatPeerDto> get copyWith => _$ChatPeerDtoCopyWithImpl<ChatPeerDto>(this as ChatPeerDto, _$identity);

  /// Serializes this ChatPeerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatPeerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,fullName,avatarUrl,role,isOnline,lastSeenAt);

@override
String toString() {
  return 'ChatPeerDto(id: $id, username: $username, fullName: $fullName, avatarUrl: $avatarUrl, role: $role, isOnline: $isOnline, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $ChatPeerDtoCopyWith<$Res>  {
  factory $ChatPeerDtoCopyWith(ChatPeerDto value, $Res Function(ChatPeerDto) _then) = _$ChatPeerDtoCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'avatar_url') String? avatarUrl, String role,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'last_seen_at') DateTime? lastSeenAt
});




}
/// @nodoc
class _$ChatPeerDtoCopyWithImpl<$Res>
    implements $ChatPeerDtoCopyWith<$Res> {
  _$ChatPeerDtoCopyWithImpl(this._self, this._then);

  final ChatPeerDto _self;
  final $Res Function(ChatPeerDto) _then;

/// Create a copy of ChatPeerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? fullName = null,Object? avatarUrl = freezed,Object? role = null,Object? isOnline = null,Object? lastSeenAt = freezed,}) {
  return _then(ChatPeerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatPeerDto].
extension ChatPeerDtoPatterns on ChatPeerDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatPeerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatPeerDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatPeerDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatPeerDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatPeerDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatPeerDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String role, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatPeerDto() when $default != null:
return $default(_that.id,_that.username,_that.fullName,_that.avatarUrl,_that.role,_that.isOnline,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String role, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt)  $default,) {final _that = this;
switch (_that) {
case _ChatPeerDto():
return $default(_that.id,_that.username,_that.fullName,_that.avatarUrl,_that.role,_that.isOnline,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String role, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatPeerDto() when $default != null:
return $default(_that.id,_that.username,_that.fullName,_that.avatarUrl,_that.role,_that.isOnline,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatPeerDto implements ChatPeerDto {
  const _ChatPeerDto({required this.id, required this.username, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'avatar_url') this.avatarUrl, required this.role, @JsonKey(name: 'is_online') this.isOnline = false, @JsonKey(name: 'last_seen_at') this.lastSeenAt});
  factory _ChatPeerDto.fromJson(Map<String, dynamic> json) => _$ChatPeerDtoFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override final  String role;
@override@JsonKey(name: 'is_online') final  bool isOnline;
@override@JsonKey(name: 'last_seen_at') final  DateTime? lastSeenAt;

/// Create a copy of ChatPeerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatPeerDtoCopyWith<_ChatPeerDto> get copyWith => __$ChatPeerDtoCopyWithImpl<_ChatPeerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatPeerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatPeerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,fullName,avatarUrl,role,isOnline,lastSeenAt);

@override
String toString() {
  return 'ChatPeerDto(id: $id, username: $username, fullName: $fullName, avatarUrl: $avatarUrl, role: $role, isOnline: $isOnline, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class _$ChatPeerDtoCopyWith<$Res> implements $ChatPeerDtoCopyWith<$Res> {
  factory _$ChatPeerDtoCopyWith(_ChatPeerDto value, $Res Function(_ChatPeerDto) _then) = __$ChatPeerDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'avatar_url') String? avatarUrl, String role,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'last_seen_at') DateTime? lastSeenAt
});




}
/// @nodoc
class __$ChatPeerDtoCopyWithImpl<$Res>
    implements _$ChatPeerDtoCopyWith<$Res> {
  __$ChatPeerDtoCopyWithImpl(this._self, this._then);

  final _ChatPeerDto _self;
  final $Res Function(_ChatPeerDto) _then;

/// Create a copy of ChatPeerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? fullName = null,Object? avatarUrl = freezed,Object? role = null,Object? isOnline = null,Object? lastSeenAt = freezed,}) {
  return _then(_ChatPeerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$ClientFrame {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientFrame);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClientFrame()';
}


}

/// @nodoc
class $ClientFrameCopyWith<$Res>  {
$ClientFrameCopyWith(ClientFrame _, $Res Function(ClientFrame) __);
}


/// Adds pattern-matching-related methods to [ClientFrame].
extension ClientFramePatterns on ClientFrame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClientSendMessageFrame value)?  sendMessage,TResult Function( ClientAckDeliveredFrame value)?  ackDelivered,TResult Function( ClientAckReadFrame value)?  ackRead,TResult Function( ClientTypingFrame value)?  typing,TResult Function( ClientSyncDeltaFrame value)?  syncDelta,TResult Function( ClientPingFrame value)?  ping,TResult Function( ClientSetActiveRoomFrame value)?  setActiveRoom,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClientSendMessageFrame() when sendMessage != null:
return sendMessage(_that);case ClientAckDeliveredFrame() when ackDelivered != null:
return ackDelivered(_that);case ClientAckReadFrame() when ackRead != null:
return ackRead(_that);case ClientTypingFrame() when typing != null:
return typing(_that);case ClientSyncDeltaFrame() when syncDelta != null:
return syncDelta(_that);case ClientPingFrame() when ping != null:
return ping(_that);case ClientSetActiveRoomFrame() when setActiveRoom != null:
return setActiveRoom(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClientSendMessageFrame value)  sendMessage,required TResult Function( ClientAckDeliveredFrame value)  ackDelivered,required TResult Function( ClientAckReadFrame value)  ackRead,required TResult Function( ClientTypingFrame value)  typing,required TResult Function( ClientSyncDeltaFrame value)  syncDelta,required TResult Function( ClientPingFrame value)  ping,required TResult Function( ClientSetActiveRoomFrame value)  setActiveRoom,}){
final _that = this;
switch (_that) {
case ClientSendMessageFrame():
return sendMessage(_that);case ClientAckDeliveredFrame():
return ackDelivered(_that);case ClientAckReadFrame():
return ackRead(_that);case ClientTypingFrame():
return typing(_that);case ClientSyncDeltaFrame():
return syncDelta(_that);case ClientPingFrame():
return ping(_that);case ClientSetActiveRoomFrame():
return setActiveRoom(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClientSendMessageFrame value)?  sendMessage,TResult? Function( ClientAckDeliveredFrame value)?  ackDelivered,TResult? Function( ClientAckReadFrame value)?  ackRead,TResult? Function( ClientTypingFrame value)?  typing,TResult? Function( ClientSyncDeltaFrame value)?  syncDelta,TResult? Function( ClientPingFrame value)?  ping,TResult? Function( ClientSetActiveRoomFrame value)?  setActiveRoom,}){
final _that = this;
switch (_that) {
case ClientSendMessageFrame() when sendMessage != null:
return sendMessage(_that);case ClientAckDeliveredFrame() when ackDelivered != null:
return ackDelivered(_that);case ClientAckReadFrame() when ackRead != null:
return ackRead(_that);case ClientTypingFrame() when typing != null:
return typing(_that);case ClientSyncDeltaFrame() when syncDelta != null:
return syncDelta(_that);case ClientPingFrame() when ping != null:
return ping(_that);case ClientSetActiveRoomFrame() when setActiveRoom != null:
return setActiveRoom(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String clientMsgId,  String conversationId,  String? replyToMsgId,  ChatMessageType messageType,  String? bodyText,  InteractiveAttachment? attachment)?  sendMessage,TResult Function( String conversationId,  int upToSeqId)?  ackDelivered,TResult Function( String conversationId,  int upToSeqId)?  ackRead,TResult Function( String conversationId,  bool isTyping)?  typing,TResult Function( List<ConversationCursorDto> cursors)?  syncDelta,TResult Function( int timestampMs)?  ping,TResult Function( String? conversationId)?  setActiveRoom,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClientSendMessageFrame() when sendMessage != null:
return sendMessage(_that.clientMsgId,_that.conversationId,_that.replyToMsgId,_that.messageType,_that.bodyText,_that.attachment);case ClientAckDeliveredFrame() when ackDelivered != null:
return ackDelivered(_that.conversationId,_that.upToSeqId);case ClientAckReadFrame() when ackRead != null:
return ackRead(_that.conversationId,_that.upToSeqId);case ClientTypingFrame() when typing != null:
return typing(_that.conversationId,_that.isTyping);case ClientSyncDeltaFrame() when syncDelta != null:
return syncDelta(_that.cursors);case ClientPingFrame() when ping != null:
return ping(_that.timestampMs);case ClientSetActiveRoomFrame() when setActiveRoom != null:
return setActiveRoom(_that.conversationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String clientMsgId,  String conversationId,  String? replyToMsgId,  ChatMessageType messageType,  String? bodyText,  InteractiveAttachment? attachment)  sendMessage,required TResult Function( String conversationId,  int upToSeqId)  ackDelivered,required TResult Function( String conversationId,  int upToSeqId)  ackRead,required TResult Function( String conversationId,  bool isTyping)  typing,required TResult Function( List<ConversationCursorDto> cursors)  syncDelta,required TResult Function( int timestampMs)  ping,required TResult Function( String? conversationId)  setActiveRoom,}) {final _that = this;
switch (_that) {
case ClientSendMessageFrame():
return sendMessage(_that.clientMsgId,_that.conversationId,_that.replyToMsgId,_that.messageType,_that.bodyText,_that.attachment);case ClientAckDeliveredFrame():
return ackDelivered(_that.conversationId,_that.upToSeqId);case ClientAckReadFrame():
return ackRead(_that.conversationId,_that.upToSeqId);case ClientTypingFrame():
return typing(_that.conversationId,_that.isTyping);case ClientSyncDeltaFrame():
return syncDelta(_that.cursors);case ClientPingFrame():
return ping(_that.timestampMs);case ClientSetActiveRoomFrame():
return setActiveRoom(_that.conversationId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String clientMsgId,  String conversationId,  String? replyToMsgId,  ChatMessageType messageType,  String? bodyText,  InteractiveAttachment? attachment)?  sendMessage,TResult? Function( String conversationId,  int upToSeqId)?  ackDelivered,TResult? Function( String conversationId,  int upToSeqId)?  ackRead,TResult? Function( String conversationId,  bool isTyping)?  typing,TResult? Function( List<ConversationCursorDto> cursors)?  syncDelta,TResult? Function( int timestampMs)?  ping,TResult? Function( String? conversationId)?  setActiveRoom,}) {final _that = this;
switch (_that) {
case ClientSendMessageFrame() when sendMessage != null:
return sendMessage(_that.clientMsgId,_that.conversationId,_that.replyToMsgId,_that.messageType,_that.bodyText,_that.attachment);case ClientAckDeliveredFrame() when ackDelivered != null:
return ackDelivered(_that.conversationId,_that.upToSeqId);case ClientAckReadFrame() when ackRead != null:
return ackRead(_that.conversationId,_that.upToSeqId);case ClientTypingFrame() when typing != null:
return typing(_that.conversationId,_that.isTyping);case ClientSyncDeltaFrame() when syncDelta != null:
return syncDelta(_that.cursors);case ClientPingFrame() when ping != null:
return ping(_that.timestampMs);case ClientSetActiveRoomFrame() when setActiveRoom != null:
return setActiveRoom(_that.conversationId);case _:
  return null;

}
}

}

/// @nodoc


class ClientSendMessageFrame extends ClientFrame {
  const ClientSendMessageFrame({required this.clientMsgId, required this.conversationId, this.replyToMsgId, required this.messageType, this.bodyText, this.attachment}): super._();
  

 final  String clientMsgId;
 final  String conversationId;
 final  String? replyToMsgId;
 final  ChatMessageType messageType;
 final  String? bodyText;
 final  InteractiveAttachment? attachment;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientSendMessageFrameCopyWith<ClientSendMessageFrame> get copyWith => _$ClientSendMessageFrameCopyWithImpl<ClientSendMessageFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientSendMessageFrame&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.replyToMsgId, replyToMsgId) || other.replyToMsgId == replyToMsgId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.attachment, attachment) || other.attachment == attachment));
}


@override
int get hashCode => Object.hash(runtimeType,clientMsgId,conversationId,replyToMsgId,messageType,bodyText,attachment);

@override
String toString() {
  return 'ClientFrame.sendMessage(clientMsgId: $clientMsgId, conversationId: $conversationId, replyToMsgId: $replyToMsgId, messageType: $messageType, bodyText: $bodyText, attachment: $attachment)';
}


}

/// @nodoc
abstract mixin class $ClientSendMessageFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientSendMessageFrameCopyWith(ClientSendMessageFrame value, $Res Function(ClientSendMessageFrame) _then) = _$ClientSendMessageFrameCopyWithImpl;
@useResult
$Res call({
 String clientMsgId, String conversationId, String? replyToMsgId, ChatMessageType messageType, String? bodyText, InteractiveAttachment? attachment
});


$InteractiveAttachmentCopyWith<$Res>? get attachment;

}
/// @nodoc
class _$ClientSendMessageFrameCopyWithImpl<$Res>
    implements $ClientSendMessageFrameCopyWith<$Res> {
  _$ClientSendMessageFrameCopyWithImpl(this._self, this._then);

  final ClientSendMessageFrame _self;
  final $Res Function(ClientSendMessageFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientMsgId = null,Object? conversationId = null,Object? replyToMsgId = freezed,Object? messageType = null,Object? bodyText = freezed,Object? attachment = freezed,}) {
  return _then(ClientSendMessageFrame(
clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,replyToMsgId: freezed == replyToMsgId ? _self.replyToMsgId : replyToMsgId // ignore: cast_nullable_to_non_nullable
as String?,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType,bodyText: freezed == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String?,attachment: freezed == attachment ? _self.attachment : attachment // ignore: cast_nullable_to_non_nullable
as InteractiveAttachment?,
  ));
}

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InteractiveAttachmentCopyWith<$Res>? get attachment {
    if (_self.attachment == null) {
    return null;
  }

  return $InteractiveAttachmentCopyWith<$Res>(_self.attachment!, (value) {
    return _then(_self.copyWith(attachment: value));
  });
}
}

/// @nodoc


class ClientAckDeliveredFrame extends ClientFrame {
  const ClientAckDeliveredFrame({required this.conversationId, required this.upToSeqId}): super._();
  

 final  String conversationId;
 final  int upToSeqId;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientAckDeliveredFrameCopyWith<ClientAckDeliveredFrame> get copyWith => _$ClientAckDeliveredFrameCopyWithImpl<ClientAckDeliveredFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientAckDeliveredFrame&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.upToSeqId, upToSeqId) || other.upToSeqId == upToSeqId));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,upToSeqId);

@override
String toString() {
  return 'ClientFrame.ackDelivered(conversationId: $conversationId, upToSeqId: $upToSeqId)';
}


}

/// @nodoc
abstract mixin class $ClientAckDeliveredFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientAckDeliveredFrameCopyWith(ClientAckDeliveredFrame value, $Res Function(ClientAckDeliveredFrame) _then) = _$ClientAckDeliveredFrameCopyWithImpl;
@useResult
$Res call({
 String conversationId, int upToSeqId
});




}
/// @nodoc
class _$ClientAckDeliveredFrameCopyWithImpl<$Res>
    implements $ClientAckDeliveredFrameCopyWith<$Res> {
  _$ClientAckDeliveredFrameCopyWithImpl(this._self, this._then);

  final ClientAckDeliveredFrame _self;
  final $Res Function(ClientAckDeliveredFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? upToSeqId = null,}) {
  return _then(ClientAckDeliveredFrame(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,upToSeqId: null == upToSeqId ? _self.upToSeqId : upToSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ClientAckReadFrame extends ClientFrame {
  const ClientAckReadFrame({required this.conversationId, required this.upToSeqId}): super._();
  

 final  String conversationId;
 final  int upToSeqId;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientAckReadFrameCopyWith<ClientAckReadFrame> get copyWith => _$ClientAckReadFrameCopyWithImpl<ClientAckReadFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientAckReadFrame&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.upToSeqId, upToSeqId) || other.upToSeqId == upToSeqId));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,upToSeqId);

@override
String toString() {
  return 'ClientFrame.ackRead(conversationId: $conversationId, upToSeqId: $upToSeqId)';
}


}

/// @nodoc
abstract mixin class $ClientAckReadFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientAckReadFrameCopyWith(ClientAckReadFrame value, $Res Function(ClientAckReadFrame) _then) = _$ClientAckReadFrameCopyWithImpl;
@useResult
$Res call({
 String conversationId, int upToSeqId
});




}
/// @nodoc
class _$ClientAckReadFrameCopyWithImpl<$Res>
    implements $ClientAckReadFrameCopyWith<$Res> {
  _$ClientAckReadFrameCopyWithImpl(this._self, this._then);

  final ClientAckReadFrame _self;
  final $Res Function(ClientAckReadFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? upToSeqId = null,}) {
  return _then(ClientAckReadFrame(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,upToSeqId: null == upToSeqId ? _self.upToSeqId : upToSeqId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ClientTypingFrame extends ClientFrame {
  const ClientTypingFrame({required this.conversationId, required this.isTyping}): super._();
  

 final  String conversationId;
 final  bool isTyping;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientTypingFrameCopyWith<ClientTypingFrame> get copyWith => _$ClientTypingFrameCopyWithImpl<ClientTypingFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientTypingFrame&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,isTyping);

@override
String toString() {
  return 'ClientFrame.typing(conversationId: $conversationId, isTyping: $isTyping)';
}


}

/// @nodoc
abstract mixin class $ClientTypingFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientTypingFrameCopyWith(ClientTypingFrame value, $Res Function(ClientTypingFrame) _then) = _$ClientTypingFrameCopyWithImpl;
@useResult
$Res call({
 String conversationId, bool isTyping
});




}
/// @nodoc
class _$ClientTypingFrameCopyWithImpl<$Res>
    implements $ClientTypingFrameCopyWith<$Res> {
  _$ClientTypingFrameCopyWithImpl(this._self, this._then);

  final ClientTypingFrame _self;
  final $Res Function(ClientTypingFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? isTyping = null,}) {
  return _then(ClientTypingFrame(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClientSyncDeltaFrame extends ClientFrame {
  const ClientSyncDeltaFrame({required  List<ConversationCursorDto> cursors}): _cursors = cursors,super._();
  

 final  List<ConversationCursorDto> _cursors;
 List<ConversationCursorDto> get cursors {
  if (_cursors is EqualUnmodifiableListView) return _cursors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cursors);
}


/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientSyncDeltaFrameCopyWith<ClientSyncDeltaFrame> get copyWith => _$ClientSyncDeltaFrameCopyWithImpl<ClientSyncDeltaFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientSyncDeltaFrame&&const DeepCollectionEquality().equals(other._cursors, _cursors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cursors));

@override
String toString() {
  return 'ClientFrame.syncDelta(cursors: $cursors)';
}


}

/// @nodoc
abstract mixin class $ClientSyncDeltaFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientSyncDeltaFrameCopyWith(ClientSyncDeltaFrame value, $Res Function(ClientSyncDeltaFrame) _then) = _$ClientSyncDeltaFrameCopyWithImpl;
@useResult
$Res call({
 List<ConversationCursorDto> cursors
});




}
/// @nodoc
class _$ClientSyncDeltaFrameCopyWithImpl<$Res>
    implements $ClientSyncDeltaFrameCopyWith<$Res> {
  _$ClientSyncDeltaFrameCopyWithImpl(this._self, this._then);

  final ClientSyncDeltaFrame _self;
  final $Res Function(ClientSyncDeltaFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cursors = null,}) {
  return _then(ClientSyncDeltaFrame(
cursors: null == cursors ? _self._cursors : cursors // ignore: cast_nullable_to_non_nullable
as List<ConversationCursorDto>,
  ));
}


}

/// @nodoc


class ClientPingFrame extends ClientFrame {
  const ClientPingFrame({required this.timestampMs}): super._();
  

 final  int timestampMs;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientPingFrameCopyWith<ClientPingFrame> get copyWith => _$ClientPingFrameCopyWithImpl<ClientPingFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientPingFrame&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs));
}


@override
int get hashCode => Object.hash(runtimeType,timestampMs);

@override
String toString() {
  return 'ClientFrame.ping(timestampMs: $timestampMs)';
}


}

/// @nodoc
abstract mixin class $ClientPingFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientPingFrameCopyWith(ClientPingFrame value, $Res Function(ClientPingFrame) _then) = _$ClientPingFrameCopyWithImpl;
@useResult
$Res call({
 int timestampMs
});




}
/// @nodoc
class _$ClientPingFrameCopyWithImpl<$Res>
    implements $ClientPingFrameCopyWith<$Res> {
  _$ClientPingFrameCopyWithImpl(this._self, this._then);

  final ClientPingFrame _self;
  final $Res Function(ClientPingFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? timestampMs = null,}) {
  return _then(ClientPingFrame(
timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ClientSetActiveRoomFrame extends ClientFrame {
  const ClientSetActiveRoomFrame({this.conversationId}): super._();
  

 final  String? conversationId;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientSetActiveRoomFrameCopyWith<ClientSetActiveRoomFrame> get copyWith => _$ClientSetActiveRoomFrameCopyWithImpl<ClientSetActiveRoomFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientSetActiveRoomFrame&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId);

@override
String toString() {
  return 'ClientFrame.setActiveRoom(conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class $ClientSetActiveRoomFrameCopyWith<$Res> implements $ClientFrameCopyWith<$Res> {
  factory $ClientSetActiveRoomFrameCopyWith(ClientSetActiveRoomFrame value, $Res Function(ClientSetActiveRoomFrame) _then) = _$ClientSetActiveRoomFrameCopyWithImpl;
@useResult
$Res call({
 String? conversationId
});




}
/// @nodoc
class _$ClientSetActiveRoomFrameCopyWithImpl<$Res>
    implements $ClientSetActiveRoomFrameCopyWith<$Res> {
  _$ClientSetActiveRoomFrameCopyWithImpl(this._self, this._then);

  final ClientSetActiveRoomFrame _self;
  final $Res Function(ClientSetActiveRoomFrame) _then;

/// Create a copy of ClientFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = freezed,}) {
  return _then(ClientSetActiveRoomFrame(
conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ServerFrame {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFrame);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ServerFrame()';
}


}

/// @nodoc
class $ServerFrameCopyWith<$Res>  {
$ServerFrameCopyWith(ServerFrame _, $Res Function(ServerFrame) __);
}


/// Adds pattern-matching-related methods to [ServerFrame].
extension ServerFramePatterns on ServerFrame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ServerMessageSentAckFrame value)?  messageSentAck,TResult Function( ServerNewMessageFrame value)?  newMessage,TResult Function( ServerReceiptWatermarkUpdateFrame value)?  receiptWatermarkUpdate,TResult Function( ServerTypingIndicatorFrame value)?  typingIndicator,TResult Function( ServerPresenceUpdateFrame value)?  presenceUpdate,TResult Function( ServerDeltaSyncBatchFrame value)?  deltaSyncBatch,TResult Function( ServerFrameErrorFrame value)?  frameError,TResult Function( ServerPongFrame value)?  pong,TResult Function( ServerSocialGraphEventFrame value)?  socialGraphEvent,TResult Function( ServerPushNotificationEventFrame value)?  pushNotificationEvent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ServerMessageSentAckFrame() when messageSentAck != null:
return messageSentAck(_that);case ServerNewMessageFrame() when newMessage != null:
return newMessage(_that);case ServerReceiptWatermarkUpdateFrame() when receiptWatermarkUpdate != null:
return receiptWatermarkUpdate(_that);case ServerTypingIndicatorFrame() when typingIndicator != null:
return typingIndicator(_that);case ServerPresenceUpdateFrame() when presenceUpdate != null:
return presenceUpdate(_that);case ServerDeltaSyncBatchFrame() when deltaSyncBatch != null:
return deltaSyncBatch(_that);case ServerFrameErrorFrame() when frameError != null:
return frameError(_that);case ServerPongFrame() when pong != null:
return pong(_that);case ServerSocialGraphEventFrame() when socialGraphEvent != null:
return socialGraphEvent(_that);case ServerPushNotificationEventFrame() when pushNotificationEvent != null:
return pushNotificationEvent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ServerMessageSentAckFrame value)  messageSentAck,required TResult Function( ServerNewMessageFrame value)  newMessage,required TResult Function( ServerReceiptWatermarkUpdateFrame value)  receiptWatermarkUpdate,required TResult Function( ServerTypingIndicatorFrame value)  typingIndicator,required TResult Function( ServerPresenceUpdateFrame value)  presenceUpdate,required TResult Function( ServerDeltaSyncBatchFrame value)  deltaSyncBatch,required TResult Function( ServerFrameErrorFrame value)  frameError,required TResult Function( ServerPongFrame value)  pong,required TResult Function( ServerSocialGraphEventFrame value)  socialGraphEvent,required TResult Function( ServerPushNotificationEventFrame value)  pushNotificationEvent,}){
final _that = this;
switch (_that) {
case ServerMessageSentAckFrame():
return messageSentAck(_that);case ServerNewMessageFrame():
return newMessage(_that);case ServerReceiptWatermarkUpdateFrame():
return receiptWatermarkUpdate(_that);case ServerTypingIndicatorFrame():
return typingIndicator(_that);case ServerPresenceUpdateFrame():
return presenceUpdate(_that);case ServerDeltaSyncBatchFrame():
return deltaSyncBatch(_that);case ServerFrameErrorFrame():
return frameError(_that);case ServerPongFrame():
return pong(_that);case ServerSocialGraphEventFrame():
return socialGraphEvent(_that);case ServerPushNotificationEventFrame():
return pushNotificationEvent(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ServerMessageSentAckFrame value)?  messageSentAck,TResult? Function( ServerNewMessageFrame value)?  newMessage,TResult? Function( ServerReceiptWatermarkUpdateFrame value)?  receiptWatermarkUpdate,TResult? Function( ServerTypingIndicatorFrame value)?  typingIndicator,TResult? Function( ServerPresenceUpdateFrame value)?  presenceUpdate,TResult? Function( ServerDeltaSyncBatchFrame value)?  deltaSyncBatch,TResult? Function( ServerFrameErrorFrame value)?  frameError,TResult? Function( ServerPongFrame value)?  pong,TResult? Function( ServerSocialGraphEventFrame value)?  socialGraphEvent,TResult? Function( ServerPushNotificationEventFrame value)?  pushNotificationEvent,}){
final _that = this;
switch (_that) {
case ServerMessageSentAckFrame() when messageSentAck != null:
return messageSentAck(_that);case ServerNewMessageFrame() when newMessage != null:
return newMessage(_that);case ServerReceiptWatermarkUpdateFrame() when receiptWatermarkUpdate != null:
return receiptWatermarkUpdate(_that);case ServerTypingIndicatorFrame() when typingIndicator != null:
return typingIndicator(_that);case ServerPresenceUpdateFrame() when presenceUpdate != null:
return presenceUpdate(_that);case ServerDeltaSyncBatchFrame() when deltaSyncBatch != null:
return deltaSyncBatch(_that);case ServerFrameErrorFrame() when frameError != null:
return frameError(_that);case ServerPongFrame() when pong != null:
return pong(_that);case ServerSocialGraphEventFrame() when socialGraphEvent != null:
return socialGraphEvent(_that);case ServerPushNotificationEventFrame() when pushNotificationEvent != null:
return pushNotificationEvent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String clientMsgId,  String serverMsgId,  String conversationId,  int seqId,  DateTime createdAt)?  messageSentAck,TResult Function( ChatMessageDto message)?  newMessage,TResult Function( String conversationId,  String userId,  ReceiptStatus status,  int upToSeqId,  DateTime updatedAt)?  receiptWatermarkUpdate,TResult Function( String conversationId,  String userId,  String displayName,  bool isTyping)?  typingIndicator,TResult Function( String userId,  bool isOnline,  DateTime? lastSeenAt)?  presenceUpdate,TResult Function( List<ChatMessageDto> messages,  List<ParticipantWatermarkDto> watermarks)?  deltaSyncBatch,TResult Function( String? clientMsgId,  String code,  String message)?  frameError,TResult Function( int timestampMs)?  pong,TResult Function( String actorId,  String actorUsername,  String actorDisplayName,  String? actorAvatarUrl,  String state,  String action,  String message,  DateTime createdAt)?  socialGraphEvent,TResult Function( String notificationId,  String category,  String eventType,  String title,  String body,  String deepLinkPath,  String? collapseKey,  String? entityId,  String? actorId,  String? conversationId,  List<String> actionButtons,  int unreadCount,  DateTime createdAt)?  pushNotificationEvent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ServerMessageSentAckFrame() when messageSentAck != null:
return messageSentAck(_that.clientMsgId,_that.serverMsgId,_that.conversationId,_that.seqId,_that.createdAt);case ServerNewMessageFrame() when newMessage != null:
return newMessage(_that.message);case ServerReceiptWatermarkUpdateFrame() when receiptWatermarkUpdate != null:
return receiptWatermarkUpdate(_that.conversationId,_that.userId,_that.status,_that.upToSeqId,_that.updatedAt);case ServerTypingIndicatorFrame() when typingIndicator != null:
return typingIndicator(_that.conversationId,_that.userId,_that.displayName,_that.isTyping);case ServerPresenceUpdateFrame() when presenceUpdate != null:
return presenceUpdate(_that.userId,_that.isOnline,_that.lastSeenAt);case ServerDeltaSyncBatchFrame() when deltaSyncBatch != null:
return deltaSyncBatch(_that.messages,_that.watermarks);case ServerFrameErrorFrame() when frameError != null:
return frameError(_that.clientMsgId,_that.code,_that.message);case ServerPongFrame() when pong != null:
return pong(_that.timestampMs);case ServerSocialGraphEventFrame() when socialGraphEvent != null:
return socialGraphEvent(_that.actorId,_that.actorUsername,_that.actorDisplayName,_that.actorAvatarUrl,_that.state,_that.action,_that.message,_that.createdAt);case ServerPushNotificationEventFrame() when pushNotificationEvent != null:
return pushNotificationEvent(_that.notificationId,_that.category,_that.eventType,_that.title,_that.body,_that.deepLinkPath,_that.collapseKey,_that.entityId,_that.actorId,_that.conversationId,_that.actionButtons,_that.unreadCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String clientMsgId,  String serverMsgId,  String conversationId,  int seqId,  DateTime createdAt)  messageSentAck,required TResult Function( ChatMessageDto message)  newMessage,required TResult Function( String conversationId,  String userId,  ReceiptStatus status,  int upToSeqId,  DateTime updatedAt)  receiptWatermarkUpdate,required TResult Function( String conversationId,  String userId,  String displayName,  bool isTyping)  typingIndicator,required TResult Function( String userId,  bool isOnline,  DateTime? lastSeenAt)  presenceUpdate,required TResult Function( List<ChatMessageDto> messages,  List<ParticipantWatermarkDto> watermarks)  deltaSyncBatch,required TResult Function( String? clientMsgId,  String code,  String message)  frameError,required TResult Function( int timestampMs)  pong,required TResult Function( String actorId,  String actorUsername,  String actorDisplayName,  String? actorAvatarUrl,  String state,  String action,  String message,  DateTime createdAt)  socialGraphEvent,required TResult Function( String notificationId,  String category,  String eventType,  String title,  String body,  String deepLinkPath,  String? collapseKey,  String? entityId,  String? actorId,  String? conversationId,  List<String> actionButtons,  int unreadCount,  DateTime createdAt)  pushNotificationEvent,}) {final _that = this;
switch (_that) {
case ServerMessageSentAckFrame():
return messageSentAck(_that.clientMsgId,_that.serverMsgId,_that.conversationId,_that.seqId,_that.createdAt);case ServerNewMessageFrame():
return newMessage(_that.message);case ServerReceiptWatermarkUpdateFrame():
return receiptWatermarkUpdate(_that.conversationId,_that.userId,_that.status,_that.upToSeqId,_that.updatedAt);case ServerTypingIndicatorFrame():
return typingIndicator(_that.conversationId,_that.userId,_that.displayName,_that.isTyping);case ServerPresenceUpdateFrame():
return presenceUpdate(_that.userId,_that.isOnline,_that.lastSeenAt);case ServerDeltaSyncBatchFrame():
return deltaSyncBatch(_that.messages,_that.watermarks);case ServerFrameErrorFrame():
return frameError(_that.clientMsgId,_that.code,_that.message);case ServerPongFrame():
return pong(_that.timestampMs);case ServerSocialGraphEventFrame():
return socialGraphEvent(_that.actorId,_that.actorUsername,_that.actorDisplayName,_that.actorAvatarUrl,_that.state,_that.action,_that.message,_that.createdAt);case ServerPushNotificationEventFrame():
return pushNotificationEvent(_that.notificationId,_that.category,_that.eventType,_that.title,_that.body,_that.deepLinkPath,_that.collapseKey,_that.entityId,_that.actorId,_that.conversationId,_that.actionButtons,_that.unreadCount,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String clientMsgId,  String serverMsgId,  String conversationId,  int seqId,  DateTime createdAt)?  messageSentAck,TResult? Function( ChatMessageDto message)?  newMessage,TResult? Function( String conversationId,  String userId,  ReceiptStatus status,  int upToSeqId,  DateTime updatedAt)?  receiptWatermarkUpdate,TResult? Function( String conversationId,  String userId,  String displayName,  bool isTyping)?  typingIndicator,TResult? Function( String userId,  bool isOnline,  DateTime? lastSeenAt)?  presenceUpdate,TResult? Function( List<ChatMessageDto> messages,  List<ParticipantWatermarkDto> watermarks)?  deltaSyncBatch,TResult? Function( String? clientMsgId,  String code,  String message)?  frameError,TResult? Function( int timestampMs)?  pong,TResult? Function( String actorId,  String actorUsername,  String actorDisplayName,  String? actorAvatarUrl,  String state,  String action,  String message,  DateTime createdAt)?  socialGraphEvent,TResult? Function( String notificationId,  String category,  String eventType,  String title,  String body,  String deepLinkPath,  String? collapseKey,  String? entityId,  String? actorId,  String? conversationId,  List<String> actionButtons,  int unreadCount,  DateTime createdAt)?  pushNotificationEvent,}) {final _that = this;
switch (_that) {
case ServerMessageSentAckFrame() when messageSentAck != null:
return messageSentAck(_that.clientMsgId,_that.serverMsgId,_that.conversationId,_that.seqId,_that.createdAt);case ServerNewMessageFrame() when newMessage != null:
return newMessage(_that.message);case ServerReceiptWatermarkUpdateFrame() when receiptWatermarkUpdate != null:
return receiptWatermarkUpdate(_that.conversationId,_that.userId,_that.status,_that.upToSeqId,_that.updatedAt);case ServerTypingIndicatorFrame() when typingIndicator != null:
return typingIndicator(_that.conversationId,_that.userId,_that.displayName,_that.isTyping);case ServerPresenceUpdateFrame() when presenceUpdate != null:
return presenceUpdate(_that.userId,_that.isOnline,_that.lastSeenAt);case ServerDeltaSyncBatchFrame() when deltaSyncBatch != null:
return deltaSyncBatch(_that.messages,_that.watermarks);case ServerFrameErrorFrame() when frameError != null:
return frameError(_that.clientMsgId,_that.code,_that.message);case ServerPongFrame() when pong != null:
return pong(_that.timestampMs);case ServerSocialGraphEventFrame() when socialGraphEvent != null:
return socialGraphEvent(_that.actorId,_that.actorUsername,_that.actorDisplayName,_that.actorAvatarUrl,_that.state,_that.action,_that.message,_that.createdAt);case ServerPushNotificationEventFrame() when pushNotificationEvent != null:
return pushNotificationEvent(_that.notificationId,_that.category,_that.eventType,_that.title,_that.body,_that.deepLinkPath,_that.collapseKey,_that.entityId,_that.actorId,_that.conversationId,_that.actionButtons,_that.unreadCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class ServerMessageSentAckFrame extends ServerFrame {
  const ServerMessageSentAckFrame({required this.clientMsgId, required this.serverMsgId, required this.conversationId, required this.seqId, required this.createdAt}): super._();
  

 final  String clientMsgId;
 final  String serverMsgId;
 final  String conversationId;
 final  int seqId;
 final  DateTime createdAt;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerMessageSentAckFrameCopyWith<ServerMessageSentAckFrame> get copyWith => _$ServerMessageSentAckFrameCopyWithImpl<ServerMessageSentAckFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerMessageSentAckFrame&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.serverMsgId, serverMsgId) || other.serverMsgId == serverMsgId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.seqId, seqId) || other.seqId == seqId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,clientMsgId,serverMsgId,conversationId,seqId,createdAt);

@override
String toString() {
  return 'ServerFrame.messageSentAck(clientMsgId: $clientMsgId, serverMsgId: $serverMsgId, conversationId: $conversationId, seqId: $seqId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ServerMessageSentAckFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerMessageSentAckFrameCopyWith(ServerMessageSentAckFrame value, $Res Function(ServerMessageSentAckFrame) _then) = _$ServerMessageSentAckFrameCopyWithImpl;
@useResult
$Res call({
 String clientMsgId, String serverMsgId, String conversationId, int seqId, DateTime createdAt
});




}
/// @nodoc
class _$ServerMessageSentAckFrameCopyWithImpl<$Res>
    implements $ServerMessageSentAckFrameCopyWith<$Res> {
  _$ServerMessageSentAckFrameCopyWithImpl(this._self, this._then);

  final ServerMessageSentAckFrame _self;
  final $Res Function(ServerMessageSentAckFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientMsgId = null,Object? serverMsgId = null,Object? conversationId = null,Object? seqId = null,Object? createdAt = null,}) {
  return _then(ServerMessageSentAckFrame(
clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,serverMsgId: null == serverMsgId ? _self.serverMsgId : serverMsgId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,seqId: null == seqId ? _self.seqId : seqId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ServerNewMessageFrame extends ServerFrame {
  const ServerNewMessageFrame(this.message): super._();
  

 final  ChatMessageDto message;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerNewMessageFrameCopyWith<ServerNewMessageFrame> get copyWith => _$ServerNewMessageFrameCopyWithImpl<ServerNewMessageFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerNewMessageFrame&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ServerFrame.newMessage(message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerNewMessageFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerNewMessageFrameCopyWith(ServerNewMessageFrame value, $Res Function(ServerNewMessageFrame) _then) = _$ServerNewMessageFrameCopyWithImpl;
@useResult
$Res call({
 ChatMessageDto message
});


$ChatMessageDtoCopyWith<$Res> get message;

}
/// @nodoc
class _$ServerNewMessageFrameCopyWithImpl<$Res>
    implements $ServerNewMessageFrameCopyWith<$Res> {
  _$ServerNewMessageFrameCopyWithImpl(this._self, this._then);

  final ServerNewMessageFrame _self;
  final $Res Function(ServerNewMessageFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ServerNewMessageFrame(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ChatMessageDto,
  ));
}

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageDtoCopyWith<$Res> get message {
  
  return $ChatMessageDtoCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

/// @nodoc


class ServerReceiptWatermarkUpdateFrame extends ServerFrame {
  const ServerReceiptWatermarkUpdateFrame({required this.conversationId, required this.userId, required this.status, required this.upToSeqId, required this.updatedAt}): super._();
  

 final  String conversationId;
 final  String userId;
 final  ReceiptStatus status;
 final  int upToSeqId;
 final  DateTime updatedAt;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerReceiptWatermarkUpdateFrameCopyWith<ServerReceiptWatermarkUpdateFrame> get copyWith => _$ServerReceiptWatermarkUpdateFrameCopyWithImpl<ServerReceiptWatermarkUpdateFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerReceiptWatermarkUpdateFrame&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.upToSeqId, upToSeqId) || other.upToSeqId == upToSeqId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,userId,status,upToSeqId,updatedAt);

@override
String toString() {
  return 'ServerFrame.receiptWatermarkUpdate(conversationId: $conversationId, userId: $userId, status: $status, upToSeqId: $upToSeqId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ServerReceiptWatermarkUpdateFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerReceiptWatermarkUpdateFrameCopyWith(ServerReceiptWatermarkUpdateFrame value, $Res Function(ServerReceiptWatermarkUpdateFrame) _then) = _$ServerReceiptWatermarkUpdateFrameCopyWithImpl;
@useResult
$Res call({
 String conversationId, String userId, ReceiptStatus status, int upToSeqId, DateTime updatedAt
});




}
/// @nodoc
class _$ServerReceiptWatermarkUpdateFrameCopyWithImpl<$Res>
    implements $ServerReceiptWatermarkUpdateFrameCopyWith<$Res> {
  _$ServerReceiptWatermarkUpdateFrameCopyWithImpl(this._self, this._then);

  final ServerReceiptWatermarkUpdateFrame _self;
  final $Res Function(ServerReceiptWatermarkUpdateFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? userId = null,Object? status = null,Object? upToSeqId = null,Object? updatedAt = null,}) {
  return _then(ServerReceiptWatermarkUpdateFrame(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReceiptStatus,upToSeqId: null == upToSeqId ? _self.upToSeqId : upToSeqId // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ServerTypingIndicatorFrame extends ServerFrame {
  const ServerTypingIndicatorFrame({required this.conversationId, required this.userId, required this.displayName, required this.isTyping}): super._();
  

 final  String conversationId;
 final  String userId;
 final  String displayName;
 final  bool isTyping;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerTypingIndicatorFrameCopyWith<ServerTypingIndicatorFrame> get copyWith => _$ServerTypingIndicatorFrameCopyWithImpl<ServerTypingIndicatorFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerTypingIndicatorFrame&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,userId,displayName,isTyping);

@override
String toString() {
  return 'ServerFrame.typingIndicator(conversationId: $conversationId, userId: $userId, displayName: $displayName, isTyping: $isTyping)';
}


}

/// @nodoc
abstract mixin class $ServerTypingIndicatorFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerTypingIndicatorFrameCopyWith(ServerTypingIndicatorFrame value, $Res Function(ServerTypingIndicatorFrame) _then) = _$ServerTypingIndicatorFrameCopyWithImpl;
@useResult
$Res call({
 String conversationId, String userId, String displayName, bool isTyping
});




}
/// @nodoc
class _$ServerTypingIndicatorFrameCopyWithImpl<$Res>
    implements $ServerTypingIndicatorFrameCopyWith<$Res> {
  _$ServerTypingIndicatorFrameCopyWithImpl(this._self, this._then);

  final ServerTypingIndicatorFrame _self;
  final $Res Function(ServerTypingIndicatorFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? userId = null,Object? displayName = null,Object? isTyping = null,}) {
  return _then(ServerTypingIndicatorFrame(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ServerPresenceUpdateFrame extends ServerFrame {
  const ServerPresenceUpdateFrame({required this.userId, required this.isOnline, this.lastSeenAt}): super._();
  

 final  String userId;
 final  bool isOnline;
 final  DateTime? lastSeenAt;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerPresenceUpdateFrameCopyWith<ServerPresenceUpdateFrame> get copyWith => _$ServerPresenceUpdateFrameCopyWithImpl<ServerPresenceUpdateFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerPresenceUpdateFrame&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}


@override
int get hashCode => Object.hash(runtimeType,userId,isOnline,lastSeenAt);

@override
String toString() {
  return 'ServerFrame.presenceUpdate(userId: $userId, isOnline: $isOnline, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $ServerPresenceUpdateFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerPresenceUpdateFrameCopyWith(ServerPresenceUpdateFrame value, $Res Function(ServerPresenceUpdateFrame) _then) = _$ServerPresenceUpdateFrameCopyWithImpl;
@useResult
$Res call({
 String userId, bool isOnline, DateTime? lastSeenAt
});




}
/// @nodoc
class _$ServerPresenceUpdateFrameCopyWithImpl<$Res>
    implements $ServerPresenceUpdateFrameCopyWith<$Res> {
  _$ServerPresenceUpdateFrameCopyWithImpl(this._self, this._then);

  final ServerPresenceUpdateFrame _self;
  final $Res Function(ServerPresenceUpdateFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? isOnline = null,Object? lastSeenAt = freezed,}) {
  return _then(ServerPresenceUpdateFrame(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class ServerDeltaSyncBatchFrame extends ServerFrame {
  const ServerDeltaSyncBatchFrame({required  List<ChatMessageDto> messages, required  List<ParticipantWatermarkDto> watermarks}): _messages = messages,_watermarks = watermarks,super._();
  

 final  List<ChatMessageDto> _messages;
 List<ChatMessageDto> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<ParticipantWatermarkDto> _watermarks;
 List<ParticipantWatermarkDto> get watermarks {
  if (_watermarks is EqualUnmodifiableListView) return _watermarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_watermarks);
}


/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerDeltaSyncBatchFrameCopyWith<ServerDeltaSyncBatchFrame> get copyWith => _$ServerDeltaSyncBatchFrameCopyWithImpl<ServerDeltaSyncBatchFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerDeltaSyncBatchFrame&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._watermarks, _watermarks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_watermarks));

@override
String toString() {
  return 'ServerFrame.deltaSyncBatch(messages: $messages, watermarks: $watermarks)';
}


}

/// @nodoc
abstract mixin class $ServerDeltaSyncBatchFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerDeltaSyncBatchFrameCopyWith(ServerDeltaSyncBatchFrame value, $Res Function(ServerDeltaSyncBatchFrame) _then) = _$ServerDeltaSyncBatchFrameCopyWithImpl;
@useResult
$Res call({
 List<ChatMessageDto> messages, List<ParticipantWatermarkDto> watermarks
});




}
/// @nodoc
class _$ServerDeltaSyncBatchFrameCopyWithImpl<$Res>
    implements $ServerDeltaSyncBatchFrameCopyWith<$Res> {
  _$ServerDeltaSyncBatchFrameCopyWithImpl(this._self, this._then);

  final ServerDeltaSyncBatchFrame _self;
  final $Res Function(ServerDeltaSyncBatchFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? watermarks = null,}) {
  return _then(ServerDeltaSyncBatchFrame(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessageDto>,watermarks: null == watermarks ? _self._watermarks : watermarks // ignore: cast_nullable_to_non_nullable
as List<ParticipantWatermarkDto>,
  ));
}


}

/// @nodoc


class ServerFrameErrorFrame extends ServerFrame {
  const ServerFrameErrorFrame({this.clientMsgId, required this.code, required this.message}): super._();
  

 final  String? clientMsgId;
 final  String code;
 final  String message;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFrameErrorFrameCopyWith<ServerFrameErrorFrame> get copyWith => _$ServerFrameErrorFrameCopyWithImpl<ServerFrameErrorFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFrameErrorFrame&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,clientMsgId,code,message);

@override
String toString() {
  return 'ServerFrame.frameError(clientMsgId: $clientMsgId, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerFrameErrorFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerFrameErrorFrameCopyWith(ServerFrameErrorFrame value, $Res Function(ServerFrameErrorFrame) _then) = _$ServerFrameErrorFrameCopyWithImpl;
@useResult
$Res call({
 String? clientMsgId, String code, String message
});




}
/// @nodoc
class _$ServerFrameErrorFrameCopyWithImpl<$Res>
    implements $ServerFrameErrorFrameCopyWith<$Res> {
  _$ServerFrameErrorFrameCopyWithImpl(this._self, this._then);

  final ServerFrameErrorFrame _self;
  final $Res Function(ServerFrameErrorFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientMsgId = freezed,Object? code = null,Object? message = null,}) {
  return _then(ServerFrameErrorFrame(
clientMsgId: freezed == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ServerPongFrame extends ServerFrame {
  const ServerPongFrame({required this.timestampMs}): super._();
  

 final  int timestampMs;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerPongFrameCopyWith<ServerPongFrame> get copyWith => _$ServerPongFrameCopyWithImpl<ServerPongFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerPongFrame&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs));
}


@override
int get hashCode => Object.hash(runtimeType,timestampMs);

@override
String toString() {
  return 'ServerFrame.pong(timestampMs: $timestampMs)';
}


}

/// @nodoc
abstract mixin class $ServerPongFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerPongFrameCopyWith(ServerPongFrame value, $Res Function(ServerPongFrame) _then) = _$ServerPongFrameCopyWithImpl;
@useResult
$Res call({
 int timestampMs
});




}
/// @nodoc
class _$ServerPongFrameCopyWithImpl<$Res>
    implements $ServerPongFrameCopyWith<$Res> {
  _$ServerPongFrameCopyWithImpl(this._self, this._then);

  final ServerPongFrame _self;
  final $Res Function(ServerPongFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? timestampMs = null,}) {
  return _then(ServerPongFrame(
timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ServerSocialGraphEventFrame extends ServerFrame {
  const ServerSocialGraphEventFrame({required this.actorId, required this.actorUsername, required this.actorDisplayName, this.actorAvatarUrl, required this.state, required this.action, required this.message, required this.createdAt}): super._();
  

 final  String actorId;
 final  String actorUsername;
 final  String actorDisplayName;
 final  String? actorAvatarUrl;
 final  String state;
 final  String action;
 final  String message;
 final  DateTime createdAt;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerSocialGraphEventFrameCopyWith<ServerSocialGraphEventFrame> get copyWith => _$ServerSocialGraphEventFrameCopyWithImpl<ServerSocialGraphEventFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSocialGraphEventFrame&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorUsername, actorUsername) || other.actorUsername == actorUsername)&&(identical(other.actorDisplayName, actorDisplayName) || other.actorDisplayName == actorDisplayName)&&(identical(other.actorAvatarUrl, actorAvatarUrl) || other.actorAvatarUrl == actorAvatarUrl)&&(identical(other.state, state) || other.state == state)&&(identical(other.action, action) || other.action == action)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,actorId,actorUsername,actorDisplayName,actorAvatarUrl,state,action,message,createdAt);

@override
String toString() {
  return 'ServerFrame.socialGraphEvent(actorId: $actorId, actorUsername: $actorUsername, actorDisplayName: $actorDisplayName, actorAvatarUrl: $actorAvatarUrl, state: $state, action: $action, message: $message, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ServerSocialGraphEventFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerSocialGraphEventFrameCopyWith(ServerSocialGraphEventFrame value, $Res Function(ServerSocialGraphEventFrame) _then) = _$ServerSocialGraphEventFrameCopyWithImpl;
@useResult
$Res call({
 String actorId, String actorUsername, String actorDisplayName, String? actorAvatarUrl, String state, String action, String message, DateTime createdAt
});




}
/// @nodoc
class _$ServerSocialGraphEventFrameCopyWithImpl<$Res>
    implements $ServerSocialGraphEventFrameCopyWith<$Res> {
  _$ServerSocialGraphEventFrameCopyWithImpl(this._self, this._then);

  final ServerSocialGraphEventFrame _self;
  final $Res Function(ServerSocialGraphEventFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? actorId = null,Object? actorUsername = null,Object? actorDisplayName = null,Object? actorAvatarUrl = freezed,Object? state = null,Object? action = null,Object? message = null,Object? createdAt = null,}) {
  return _then(ServerSocialGraphEventFrame(
actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorUsername: null == actorUsername ? _self.actorUsername : actorUsername // ignore: cast_nullable_to_non_nullable
as String,actorDisplayName: null == actorDisplayName ? _self.actorDisplayName : actorDisplayName // ignore: cast_nullable_to_non_nullable
as String,actorAvatarUrl: freezed == actorAvatarUrl ? _self.actorAvatarUrl : actorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ServerPushNotificationEventFrame extends ServerFrame {
  const ServerPushNotificationEventFrame({required this.notificationId, required this.category, required this.eventType, required this.title, required this.body, required this.deepLinkPath, this.collapseKey, this.entityId, this.actorId, this.conversationId,  List<String> actionButtons = const <String>[], required this.unreadCount, required this.createdAt}): _actionButtons = actionButtons,super._();
  

 final  String notificationId;
 final  String category;
 final  String eventType;
 final  String title;
 final  String body;
 final  String deepLinkPath;
 final  String? collapseKey;
 final  String? entityId;
 final  String? actorId;
 final  String? conversationId;
 final  List<String> _actionButtons;
@JsonKey() List<String> get actionButtons {
  if (_actionButtons is EqualUnmodifiableListView) return _actionButtons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actionButtons);
}

 final  int unreadCount;
 final  DateTime createdAt;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerPushNotificationEventFrameCopyWith<ServerPushNotificationEventFrame> get copyWith => _$ServerPushNotificationEventFrameCopyWithImpl<ServerPushNotificationEventFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerPushNotificationEventFrame&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId)&&(identical(other.category, category) || other.category == category)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.deepLinkPath, deepLinkPath) || other.deepLinkPath == deepLinkPath)&&(identical(other.collapseKey, collapseKey) || other.collapseKey == collapseKey)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other._actionButtons, _actionButtons)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,notificationId,category,eventType,title,body,deepLinkPath,collapseKey,entityId,actorId,conversationId,const DeepCollectionEquality().hash(_actionButtons),unreadCount,createdAt);

@override
String toString() {
  return 'ServerFrame.pushNotificationEvent(notificationId: $notificationId, category: $category, eventType: $eventType, title: $title, body: $body, deepLinkPath: $deepLinkPath, collapseKey: $collapseKey, entityId: $entityId, actorId: $actorId, conversationId: $conversationId, actionButtons: $actionButtons, unreadCount: $unreadCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ServerPushNotificationEventFrameCopyWith<$Res> implements $ServerFrameCopyWith<$Res> {
  factory $ServerPushNotificationEventFrameCopyWith(ServerPushNotificationEventFrame value, $Res Function(ServerPushNotificationEventFrame) _then) = _$ServerPushNotificationEventFrameCopyWithImpl;
@useResult
$Res call({
 String notificationId, String category, String eventType, String title, String body, String deepLinkPath, String? collapseKey, String? entityId, String? actorId, String? conversationId, List<String> actionButtons, int unreadCount, DateTime createdAt
});




}
/// @nodoc
class _$ServerPushNotificationEventFrameCopyWithImpl<$Res>
    implements $ServerPushNotificationEventFrameCopyWith<$Res> {
  _$ServerPushNotificationEventFrameCopyWithImpl(this._self, this._then);

  final ServerPushNotificationEventFrame _self;
  final $Res Function(ServerPushNotificationEventFrame) _then;

/// Create a copy of ServerFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notificationId = null,Object? category = null,Object? eventType = null,Object? title = null,Object? body = null,Object? deepLinkPath = null,Object? collapseKey = freezed,Object? entityId = freezed,Object? actorId = freezed,Object? conversationId = freezed,Object? actionButtons = null,Object? unreadCount = null,Object? createdAt = null,}) {
  return _then(ServerPushNotificationEventFrame(
notificationId: null == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,deepLinkPath: null == deepLinkPath ? _self.deepLinkPath : deepLinkPath // ignore: cast_nullable_to_non_nullable
as String,collapseKey: freezed == collapseKey ? _self.collapseKey : collapseKey // ignore: cast_nullable_to_non_nullable
as String?,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,actionButtons: null == actionButtons ? _self._actionButtons : actionButtons // ignore: cast_nullable_to_non_nullable
as List<String>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
