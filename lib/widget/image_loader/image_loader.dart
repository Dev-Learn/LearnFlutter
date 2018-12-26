import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:manga4dog/widget/image_loader/FuturePool.dart';
import 'package:manga4dog/widget/image_loader/image_pool.dart';
import 'package:manga4dog/widget/image_loader/image_utils.dart';
import 'package:path/path.dart' as stringUtils;
import 'package:path_provider/path_provider.dart';

const int MAX_IMAGE_SIZE = 1500;

class ImageLoader extends StatefulWidget {
  static List<Object> _registeredErrors = <Object>[];

  /// Creates a widget that displays a [placeholder] while an [imageUrl] is loading
  /// then cross-fades to display the [imageUrl].
  /// Optional [httpHeaders] can be used for example for authentication on the server.
  ///
  /// The [imageUrl], [fadeOutDuration], [fadeOutCurve],
  /// [fadeInDuration], [fadeInCurve], [alignment], [repeat], and
  /// [matchTextDirection] arguments must not be null. Arguments [width],
  /// [height], [fit], [alignment], [repeat] and [matchTextDirection]
  /// are only used for the image and not for the placeholder.
  const ImageLoader({
    Key key,
    this.placeholder,
    @required this.imageUrl,
    this.errorWidget,
    this.fadeOutDuration: const Duration(milliseconds: 300),
    this.fadeOutCurve: Curves.easeOut,
    this.fadeInDuration: const Duration(milliseconds: 700),
    this.fadeInCurve: Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment: Alignment.center,
    this.repeat: ImageRepeat.noRepeat,
    this.matchTextDirection: false,
    this.httpHeaders,
  })  : assert(imageUrl != null),
        assert(fadeOutDuration != null),
        assert(fadeOutCurve != null),
        assert(fadeInDuration != null),
        assert(fadeInCurve != null),
        assert(alignment != null),
        assert(repeat != null),
        assert(matchTextDirection != null),
        super(key: key);

  /// Widget displayed while the target [imageUrl] is loading.
  final Widget placeholder;

  /// The target image that is displayed.
  final String imageUrl;

  /// Widget displayed while the target [imageUrl] failed loading.
  final Widget errorWidget;

  /// The duration of the fade-out animation for the [placeholder].
  final Duration fadeOutDuration;

  /// The curve of the fade-out animation for the [placeholder].
  final Curve fadeOutCurve;

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration;

  /// The curve of the fade-in animation for the [imageUrl].
  final Curve fadeInCurve;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double height;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, a [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  // Optional headers for the http request of the image url
  final Map<String, String> httpHeaders;

  @override
  State<StatefulWidget> createState() => new _ImageLoaderState();
}

/// The phases a [ImageLoader] goes through.
@visibleForTesting
enum ImagePhase {
  /// The initial state.
  ///
  /// We do not yet know whether the target image is ready and therefore no
  /// animation is necessary, or whether we need to use the placeholder and
  /// wait for the image to load.
  start,

  /// Waiting for the target image to load.
  waiting,

  /// Fading out previous image.
  fadeOut,

  /// Fading in new image.
  fadeIn,

  /// Fade-in complete.
  completed,
}

typedef void _ImageProviderResolverListener();

class _ImageProviderResolver {
  _ImageProviderResolver({
    @required this.state,
    @required this.listener,
  });

  final _ImageLoaderState state;
  final _ImageProviderResolverListener listener;

  ImageLoader get widget => state.widget;

  ImageStream _imageStream;
  ImageInfo _imageInfo;

  void resolve(ImageLoaderProvider provider) {
    final ImageStream oldImageStream = _imageStream;
    _imageStream = provider.resolve(createLocalImageConfiguration(state.context,
        size: widget.width != null && widget.height != null ? new Size(widget.width, widget.height) : null));

    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_handleImageChanged);
      _imageStream.addListener(_handleImageChanged);
    }
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
    listener();
  }

  void stopListening() {
    _imageStream?.removeListener(_handleImageChanged);
  }
}

class _ImageLoaderState extends State<ImageLoader> with TickerProviderStateMixin {
  _ImageProviderResolver _imageResolver;
  ImageLoaderProvider _imageProvider;

  AnimationController _controller;
  Animation<double> _animation;

  ImagePhase _phase = ImagePhase.start;

  ImagePhase get phase => _phase;

  bool _hasError;

  @override
  void initState() {
    _hasError = false;
    _imageProvider = new ImageLoaderProvider(widget.imageUrl, headers: widget.httpHeaders);
    _imageResolver = new _ImageProviderResolver(state: this, listener: _updatePhase);

    _controller = new AnimationController(
      value: 1.0,
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {
        // Trigger rebuild to update opacity value.
      });
    });
    _controller.addStatusListener((AnimationStatus status) {
      _updatePhase();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _imageProvider.obtainKey(createLocalImageConfiguration(context)).then<void>((ImageLoaderProvider key) {
      if (ImageLoader._registeredErrors.contains(key)) {
        setState(() => _hasError = true);
      }
    });

    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl || widget.placeholder != widget.placeholder) {
      _imageProvider = new ImageLoaderProvider(widget.imageUrl, headers: widget.httpHeaders);

      _resolveImage();
    }
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    _imageResolver.resolve(_imageProvider);

    if (_phase == ImagePhase.start) _updatePhase();
  }

  void _updatePhase() {
    setState(() {
      switch (_phase) {
        case ImagePhase.start:
          if (_imageResolver._imageInfo != null || _hasError)
            _phase = ImagePhase.completed;
          else
            _phase = ImagePhase.waiting;
          break;
        case ImagePhase.waiting:
          if (_hasError && widget.errorWidget == null) {
            _phase = ImagePhase.completed;
            return;
          }

          if (_imageResolver._imageInfo != null || _hasError) {
            if (widget.placeholder == null) {
              _startFadeIn();
            } else {
              _startFadeOut();
            }
          }
          break;
        case ImagePhase.fadeOut:
          if (_controller.status == AnimationStatus.dismissed) {
            _startFadeIn();
          }
          break;
        case ImagePhase.fadeIn:
          if (_controller.status == AnimationStatus.completed) {
            // Done finding in new image.
            _phase = ImagePhase.completed;
          }
          break;
        case ImagePhase.completed:
          // Nothing to do.
          break;
      }
    });
  }

  // Received image data. Begin placeholder fade-out.
  void _startFadeOut() {
    _controller.duration = widget.fadeOutDuration;
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: widget.fadeOutCurve,
    );
    _phase = ImagePhase.fadeOut;
    _controller.reverse(from: 1.0);
  }

  // Done fading out placeholder. Begin target image fade-in.
  void _startFadeIn() {
    _controller.duration = widget.fadeInDuration;
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: widget.fadeInCurve,
    );
    _phase = ImagePhase.fadeIn;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _imageResolver.stopListening();
    _controller.dispose();
    super.dispose();
  }

  bool get _isShowingPlaceholder {
    assert(_phase != null);
    switch (_phase) {
      case ImagePhase.start:
      case ImagePhase.waiting:
      case ImagePhase.fadeOut:
        return true;
      case ImagePhase.fadeIn:
      case ImagePhase.completed:
        return _hasError && widget.errorWidget == null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(_phase != ImagePhase.start);
    if (_isShowingPlaceholder && widget.placeholder != null) {
      return _fadedWidget(widget.placeholder);
    }

    if (_hasError && widget.errorWidget != null) {
      return _fadedWidget(widget.errorWidget);
    }

    final ImageInfo imageInfo = _imageResolver._imageInfo;
    return new RawImage(
      image: imageInfo?.image,
      width: widget.width,
      height: widget.height,
      scale: imageInfo?.scale ?? 1.0,
      color: new Color.fromRGBO(255, 255, 255, _animation?.value ?? 1.0),
      colorBlendMode: BlendMode.modulate,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      matchTextDirection: widget.matchTextDirection,
    );
  }

  Widget _fadedWidget(Widget w) {
    return new Opacity(
      opacity: _animation?.value ?? 1.0,
      child: w,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new EnumProperty<ImagePhase>('phase', _phase));
    description.add(new DiagnosticsProperty<ImageInfo>('pixels', _imageResolver._imageInfo));
    description.add(new DiagnosticsProperty<ImageStream>('image stream', _imageResolver._imageStream));
  }
}

class ImageLoaderProvider extends ImageProvider<ImageLoaderProvider> {
  const ImageLoaderProvider(this.url, {this.scale: 1.0, this.headers})
      : assert(url != null),
        assert(scale != null);

  /// Web url of the image to load
  final String url;

  /// Scale of the image
  final double scale;

  final Map<String, String> headers;

  @override
  ImageStreamCompleter load(ImageLoaderProvider key) {
    return new OneFrameImageStreamCompleter(_loadAsync(key), informationCollector: (StringBuffer information) {
      information.writeln('Image provider: $this');
      information.write('Image key: $key');
    });
  }

  @override
  Future<ImageLoaderProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ImageLoaderProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final ImageLoaderProvider typedOther = other;
    return url == typedOther.url;
  }

  @override
  int get hashCode => hashValues(url, scale);

  Future<ImageInfo> _loadAsync(ImageLoaderProvider key) async {
    Directory _cacheImagesDirectory = Directory(stringUtils.join((await getTemporaryDirectory()).path, 'imagecache'));

    //    Lock _lock = Lock();
//    await _lock.synchronized(() async{
//      _cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, 'imagecache'));
//      if (!_cacheImagesDirectory.existsSync()) {
//        await _cacheImagesDirectory.create();
//      }
//    });

    String uId = uid(url);
    Uint8List _diskCache = await loadFromDiskCache(uId, key.url, _cacheImagesDirectory.path);

    final ui.Image image = await decodeImageFromList(_diskCache);
    if (image == null) return null;

    return new ImageInfo(
      image: image,
      scale: key.scale,
    );
  }

  Future<Uint8List> loadFromDiskCache(String uId, String url, String path) async {
    File _cacheImageFile = File(stringUtils.join(path, uId));
    File _tempImageFile = File(stringUtils.join(path, 'temp$uId'));

    if (_cacheImageFile.existsSync()) {
      return await _cacheImageFile.readAsBytes();
    } else {
      var success = await loadFromRemote(url, _tempImageFile, retryLimit: 2, retryDuration: Duration(milliseconds: 500));
      if (success != null && success) {
        Completer<File> completer = Completer();

        FuturePool().addToPool<File, Map<String, String>>(
          StreamSubscriptionHandler(
              uid: uId,
              loadAsync: compressImage,
              message: {'path': '${_tempImageFile.path}', 'target':'${_cacheImageFile.path}'},
              onSuccess: (data) {
                if(data != null)
                  completer.complete(data);
                else completer.complete(null);
              },
              onError: () =>
                completer.complete(null)),
        );

        var file = await completer.future;

        if(_tempImageFile.existsSync())
          _tempImageFile.deleteSync();

        if (file != null){
          return await _cacheImageFile.readAsBytes();
        }
      }
    }

    return emptyImage;
  }

  Future<File> compressImage(Map<String, String> paths) async {
      File file = await FlutterImageCompress.compressAndGetFile(
        paths['path'],
        paths['target'],
        minHeight: MAX_IMAGE_SIZE,
        minWidth: MAX_IMAGE_SIZE,
        quality: 85,
      );

      return file;
  }

  Future<bool> loadFromRemote(String url, File file, {Map<String, String> header, int retryLimit, Duration retryDuration}) async {
    Completer<bool> completer = Completer();

    ImageMessage message = ImageMessage(url, file, header: header, retryLimit: retryLimit, retryDuration: retryDuration);
    await ImagePool().addToPool<ImageMessage, bool>(
      ImageHandler(
        message: message,
        entryPoint: download,
        uid: url,
        callBack: (success) {
          completer.complete(success);
        },
      ),
    );

    return completer.future;
  }

  String uid(String str) => stringUtils.hash(str).toString();
}

Future<bool> download(ImageMessage message) async {
  if (message.retryLimit < 0) message.retryLimit = 0;

  /// Retry mechanism

  http.Response _response;
//  _response = await run(() async {
//    if (message.header != null)
//      return await http.get(message.url, headers: message.header).timeout(Duration(seconds: 5));
//    else
//      return await http.get(message.url).timeout(Duration(seconds: 5));
//  }, message.retryLimit, message.retryDuration);
  http.Client client = http.Client();
  if (message.header == null) message.header = Map();
//  print("DEQUEUE: ${message.url}");
  _response = await client.get(message.url, headers: message.header).whenComplete(client.close);
//  print("REQUEST END: ${message.url}");

  if (_response != null) {
//    ImageInfo imageInfo = findImageInfo(_response.bodyBytes);
//    if(imageInfo == null || imageInfo.info == null)
//      return false;
//
//    print('width: ${imageInfo.info.width} - height: ${imageInfo.info.height} - ${message.url}');
//
//    if (imageInfo.info.width > MAX_IMAGE_SIZE || imageInfo.info.height > MAX_IMAGE_SIZE) {
//      ImageLib.Image image = imageInfo.decoder.decodeImage(_response.bodyBytes);
//      image = ImageLib.copyResize(image, MAX_IMAGE_SIZE);
//      var encodeImage = ImageLib.encodeJpg(image, quality: 70);
//      await message.file.writeAsBytes(encodeImage);
//      return true;
//    }

    await message.file.writeAsBytes(_response.bodyBytes);
    return true;
  }

  return false;
}

//class ImageInfo{
//  final ImageLib.Decoder decoder;
//  final ImageLib.DecodeInfo info;
//
//  ImageInfo(this.decoder, this.info);
//}
//
//ImageInfo findImageInfo(List<int> data) {
//  // The various decoders will be creating a Uint8List for their InputStream
//  // if the data isn't already that type, so do it once here to avoid having to
//  // do it multiple times.
//  Uint8List bytes = new Uint8List.fromList(data);
//
//  ImageLib.JpegDecoder jpg = new ImageLib.JpegDecoder();
//  if (jpg.isValidFile(bytes)) {
//    return ImageInfo(jpg, jpg.startDecode(data));
//  }
//
//  ImageLib.PngDecoder png = new ImageLib.PngDecoder();
//  if (png.isValidFile(bytes)) {
//    return ImageInfo(png, png.startDecode(data));
//  }
//
//  ImageLib.GifDecoder gif = new ImageLib.GifDecoder();
//  if (gif.isValidFile(bytes)) {
//    return ImageInfo(gif, gif.startDecode(data));
//  }
//
//  ImageLib.WebPDecoder webp = new ImageLib.WebPDecoder();
//  if (webp.isValidFile(bytes)) {
//    return ImageInfo(webp, webp.startDecode(data));
//  }
//
//  ImageLib.TiffDecoder tiff = new ImageLib.TiffDecoder();
//  if (tiff.isValidFile(bytes)) {
//    return ImageInfo(tiff, tiff.startDecode(data));
//  }
//
//  ImageLib.PsdDecoder psd = new ImageLib.PsdDecoder();
//  if (psd.isValidFile(bytes)) {
//    return ImageInfo(psd, psd.startDecode(data));
//  }
//
//  ImageLib.ExrDecoder exr = new ImageLib.ExrDecoder();
//  if (exr.isValidFile(bytes)) {
//    return ImageInfo(exr, exr.startDecode(data));
//  }
//
//  return null;
//}

//Future<http.Response> run<T>(Future f(), int retryLimit, Duration retryDuration) async {
//  for (int t = 0; t < retryLimit + 1; t++) {
//    http.Response res = await f();
//    if (res != null) {
//      if (res.statusCode == 200)
//        return res;
//      else
//        debugPrint('Load error, response status code: ' + res.statusCode.toString());
//    }
//    await Future.delayed(retryDuration);
//  }
//
//  if (retryLimit > 0) debugPrint('Retry failed!');
//  return null;
//}
//
//class ImageMessage {
//  String url;
//  Map<String, String> header;
//  File file;
//  int retryLimit;
//  Duration retryDuration;
//
//  ImageMessage(this.url, this.file, {this.header, this.retryLimit, this.retryDuration});
//}
