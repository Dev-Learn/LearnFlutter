import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'package:data/model/user/user.jser.dart';

class User{

  String login;

  int id;

//  @JsonKey(name: 'avatar_url')
  String avatar;

  String name;

//  @JsonKey(name: 'public_repos')
  int publicRepos;

  int followers;

  int following;

  User();

  User.from(this.id,
      this.name,
      this.login,
      this.avatar,
      this.publicRepos,
      this.followers,
      this.following);
}
@GenSerializer(fields: {
  'avatar': Alias('avatar_url'),
  'publicRepos': Alias('public_repos'),
})
class UserSerializer extends Serializer<User> with _$UserSerializer {}
