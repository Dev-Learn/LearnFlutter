import 'package:base/contract/base_contract.dart';
import 'package:base/presenter/presenter.dart';
import 'package:data/repository/comic/comic_repo.dart';

abstract class HomeContract extends BaseContract{
  onLoadComicsCompleted();
}

class HomePresenter extends Presenter<HomeContract>{

  ComicRepo _comicRepo;

  HomePresenter(HomeContract v) : _comicRepo = ComicRepo(), super(v);

  void getComics(int after, int limit){
    addSubscription(_comicRepo.getComics(after, limit).asStream(),

    );
  }

}