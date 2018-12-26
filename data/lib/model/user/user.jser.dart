// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$UserSerializer implements Serializer<User> {
  @override
  Map<String, dynamic> toMap(User model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'login', model.login);
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'avatar_url', model.avatar);
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'public_repos', model.publicRepos);
    setMapValue(ret, 'followers', model.followers);
    setMapValue(ret, 'following', model.following);
    return ret;
  }

  @override
  User fromMap(Map map) {
    if (map == null) return null;
    final obj = new User();
    obj.login = map['login'] as String;
    obj.id = map['id'] as int;
    obj.avatar = map['avatar_url'] as String;
    obj.name = map['name'] as String;
    obj.publicRepos = map['public_repos'] as int;
    obj.followers = map['followers'] as int;
    obj.following = map['following'] as int;
    return obj;
  }
}
