import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_master_cache/util/cache_file_utils.dart';
import 'package:http/http.dart' as http;

class CachedNetworkImage extends StatelessWidget {

  CachedNetworkImage({
    required this.url,
    this.name,
    this.fit,
    this.size,
    this.loadingWidget,
    this.errorBuilder,
    this.frameBuilder,
    this.scale = 1.0,
    super.key,
  });

  final String url;
  final String? name;
  final BoxFit? fit;
  final Size? size;
  final double scale;

  final Widget? loadingWidget;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageFrameBuilder? frameBuilder;

  static const String _dir = 'images/';

  File? _file;

  static Future<void> deleteCache(){
    return CacheFileUtils.deleteFile(_dir, recursive: true);
  }

  Future<File> _downloadImage(String filename) async {
    final res = await http.get(Uri.parse(url));

    return CacheFileUtils.writeFileBytes(
      filename,
      res.bodyBytes,
      recursive: true,
    );
  }

  Future<File> _load() async {
    final filename = name ?? url.hashCode.toString();

    if (await CacheFileUtils.existFile(_dir + filename)) {
      _file = await CacheFileUtils.getFile(_dir + filename);
    }else{
      _file = null;
    }

    if(_file != null ){
      return _file!;
    }

    _file ??= await _downloadImage(_dir + filename);

    return _file!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(),
      builder: (context, s) {
        if (s.hasData) {
          if(!s.requireData.existsSync()){
            return loadingWidget ?? Container();
          }
          return Image.memory(
            s.requireData.readAsBytesSync(),
            fit: fit,
            width: size?.width,
            height: size?.height,
            errorBuilder: errorBuilder,
            frameBuilder: frameBuilder,
            scale: scale,
          );
        } else if (s.hasError) {
          return errorBuilder?.call(
                context,
                s.error!,
                s.stackTrace,
              ) ??
              Container();
        }

        return loadingWidget ?? Container();
      },
    );
  }
}


