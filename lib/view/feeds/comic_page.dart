import 'dart:async';

import 'package:data/model/comic_image/comic_image.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/view/tile/comic_image_tile_image_loader.dart';
import 'package:manga4dog/widget/loading_listview_by_key.dart';
import 'package:data/model/comic_image/comic_api.dart';


class ComicPage extends StatefulWidget {
  final int comicId;

  ComicPage({this.comicId, Key key}) : super(key: key);

  @override
  _ComicPageState createState() => _ComicPageState();
}

class _ComicPageState extends State<ComicPage> with AutomaticKeepAliveClientMixin<ComicPage>{

  Widget w;

  @override
  void initState() {
    super.initState();
//    ImagePool().createIsolate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (w == null) {
      w = LoadingListViewByKey<ComicImage>(
        request,
        widgetAdapter: adaptTile,
        pageSize: 50,
        pageThreshold: 3,
        startFrom: 0,
        getPageOffset: getPageOffset,
        cacheExtent: MediaQuery.of(context).size.height * 5,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    }
    return w;
  }

  Future<List<ComicImage>> request(int page, int pageSize) async {
    ComicApi api = new ComicApi();
    return api.getComicImages(page, pageSize, widget.comicId);
  }

  @override
  void dispose(){
//    ImagePool().dispose();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}

Widget adaptTile(ComicImage comicImage, int index, {TickerProvider ticker, bool isAnimate = false}) {
  return DemoImageLoaderTile(comicImage);
}

int getPageOffset(ComicImage comicImage) {
  return comicImage.id;
}

//class PurchasePage extends StatefulWidget {
//  @override
//  _PurchasePageState createState() => _PurchasePageState();
//}
//
//class _PurchasePageState extends State<PurchasePage> {
//  List<IAPItem> _items = [];
//
//  @override
//  void initState() {
//    super.initState();
//    init();
//  }
//
//  @override
//  void dispose() async{
//    super.dispose();
//    await FlutterInappPurchase.endConnection;
//  }
//
//  init() async {
//
//    var result = await FlutterInappPurchase.prepare;
//    FlutterInappPurchase.consumeAllItems;
//    List<String> productIds = ["test_inapp_purchase", "test_inapp_purchase2"];
//
//    List<IAPItem> items = await FlutterInappPurchase.getProducts(productIds);
//    for (var item in items) {
//      print('${item.toString()}');
//      this._items.add(item);
//    }
//
//    setState(() {
//      this._items = items;
//    });
//  }
//
//  _buyProduct(String id) async{
//    FlutterInappPurchase.buyProduct(id).then((PurchasedItem item) {
//      if(item != null){
//        FlutterInappPurchase.consumePurchase(item.purchaseToken);
//      }
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: new AppBar(
//        title: Text('Test Purchase'),
//      ),
//      body: Center(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.spaceAround,
//          children: _items
//              .map((item) =>
//              FlatButton(
//                  color: Colors.grey,
//                  onPressed: () {
//                    _buyProduct(item.productId);
//                  },
//                  child: Text('Buy: ${item.productId}')))
//              .toList(),
//        ),
//      ),
//    );
//  }
//}
//
//class TestGoogleAPI extends StatefulWidget {
//  @override
//  _TestGoogleAPIState createState() => _TestGoogleAPIState();
//}
//
//class _TestGoogleAPIState extends State<TestGoogleAPI> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: new AppBar(
//        title: Text('Test Purchase'),
//      ),
//      body: Center(
//          child: FlatButton(onPressed: (){getToken();}, child: Text('get token'))),
//    );
//  }
//
//  Future getToken() async {
//    final accountCredentials = new ServiceAccountCredentials.fromJson({
//      "private_key_id": "1220c9928735e58a45ecf9d60cbf046e031a19f8",
//      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDICPUxUKOZa21z\n2K0MpnjQMswsoyY6Jn9kPPpMOXiXOTCOCWTAkkOwZA+FAMCt8464I2pPwFiJr0tT\nIOUMYsXcLkomRe92GgpNfTRrx1Gh7BnzUt5OGnWDFeJMzJT1goy9HllD5ZFqOEyP\n+SnE3mWcaASCYFYxh4ZHzwM63in9dqM1utbn8IP2yscFacmQJsSnihzG/s+GaOhj\nQz4lF1xwYJMvIoslD4EkzLz1z89d1k6McKfM/J4aFwKpRVk0cZOZ0et94jrQDyrY\nWLbTLZ+p0uL1oKJQLDOz3Yta1dL1VMq3P+5wKNjVAz8lRURABmkVidtbhUVeRqf5\nStZJsiqJAgMBAAECggEAL7ZzRaAGZcHKCafVHv9WMdLsAHmp1JT6Ld6dlTDgIrHx\ncu+qqIQ6wQgc64ySaOt/T0yjPwKSG8VEIj/mYl3s8+fWp+pmg7USYAlNR6fzQLwg\nNHm/rMGC5hGCOO9TWHwbNcDXaeqIFN345R55aAvkELp+2NpBtO6uiNJH4vK68Um+\nry5fYNou6y2sqO2YXHNndhA5x9RTouYueDWkAqcRO/Jcn1WD5erz6bUvt6r5FPUo\n+uKxcZJGkiJt+6cT0t2RZx4VWd+Uzugcs6rRKfvLTz5QZVZIJga3P3HthKsFGDLS\n0Vq5MduejB1fSFlGdcZjSFdqtmvzXS8YqhAaqnQ0QQKBgQD2DpaAr0eT9GVNjxbL\nctnXtp4h2EcfLVGDdbR1lkI5nowVB9e0namW/VF+sj2aGOt3dbaA5itPJWXN5n2/\n3sFHYga6clJD9FWhimX6FDVKLiSqzNBDxHtBIJdMrxlQROrWemw+gUXRVGHwfoPm\nXhUxSxnv+4zOYuxoBQLWoBMU8wKBgQDQHkf++qpAXR0G2TPKVKhPC8jfBpfLvhKn\nxWZ+RMJ37c7ZkrAwepPez42xWFuxu6TpsSG2bCDUx3nqo4QBMkrS0qjshqJT5wrW\nJbwoGSgytwDDf2917S8G6ZfI6bJkw++rU2bF/9b4LaJuQ06eW0/sWREECnDWNb6C\nnvqfloMRkwKBgQDkTVTHwdqgJTt5YzK7Qq1twTuoG4yiGOJxH115XRnFbJ59RPGX\n3FHmjtR2wdr2h/iytr3Hi8jTftee3CYBSSX8na+wfzJlauepI0jLaMSpN3c+Ixt6\nRWw3WY4I0M6j884RgzW8KSYmvCzDgB/SN6liO1StnrFfLdo8CapAifYqkQKBgFVY\nBZgnPMfWJ0AWs+lF3BtGLuJedsMjN8064vPmyISbrZaFU+EdcyQMowNVw4xX8aGv\ndK61GqWHA5TX5xsCf7KClqkf8NNNTKFSqh0ba+OYLiT9TjzivcUs54SJaRFvVApC\n0kNhzcrKE/D5gvTnZxf50kOA8JK3SV+RSB9HfoonAoGBAL23MVS+MLnkKCVfLZqB\nVwm4FHLl9T53Td4G6kvyGFq6G3cFJgdKNBLqDG1Kfckq1x+MjbZAg8CRHOMmqh3T\nDevohwzNXRAYavguMGjna1IuC+FPn8ZWArEMiOUlnid0K/N6BaT5cpYESzWyvyAS\nk8kWhOYDZVvFDj3sUEA5we3h\n-----END PRIVATE KEY-----\n",
//      "client_email": "slowfit-service@slowfit-214202.iam.gserviceaccount.com",
//      "client_id": "473550462528-spnes1jcrcn7j0e20id8gbneqv40548i.apps.googleusercontent.com",
//      "type": "service_account"
//    });
//    var scopes = ['https://www.googleapis.com/auth/androidpublisher'];
//
//    String USER_AGENT = 'dart-api-client oauth2/v2';
//    String rootUrl = "https://www.googleapis.com/androidpublisher/v3/applications/";
//
//    AccessCredentials credentials = await obtainAccessCredentialsViaServiceAccount(accountCredentials, scopes, new http.Client());
//    var client = new OauthClient(new Client(), credentials.accessToken.data);
//    InappproductsResourceApi api = new InappproductsResourceApi(new ApiRequester(client, rootUrl, "", USER_AGENT));
//    InappproductsListResponse response = await api.list("vudo.teaparty.slowfit");
//    print("");
//  }
//
//}

