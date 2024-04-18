import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_master_cache/util/cache_file_utils.dart';
import 'package:http/http.dart' as http;

class CachedNetworkImage extends StatefulWidget {

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

  static Future<void> deleteCache(){
    return CacheFileUtils.deleteFile(_dir, recursive: true);
  }

  @override
  State<StatefulWidget> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {


  Uint8List? _memory;
  static const String _dir = 'images/';

  Future<File> _downloadImage(String filename) async {
    final res = await http.get(Uri.parse(widget.url));

    return CacheFileUtils.writeFileBytes(
      filename,
      res.bodyBytes,
      recursive: true,
    );
  }

  Future<void> _load() async {
    final filename = widget.name ?? widget.url.hashCode.toString();

    File? file;

    if (await CacheFileUtils.existFile(_dir + filename)) {
      if(_memory == null){
        file = await CacheFileUtils.getFile(_dir + filename);
      }
    }else{
      setState(() {
        _memory = null;
      });

    }

    if(_memory == null){
      file ??= await _downloadImage(_dir + filename);
    }

    if(file != null){
      setState(() {
        _memory = file!.readAsBytesSync();
      });
    }
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CachedNetworkImage oldWidget) {
    _load();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if(_memory == null){
      return widget.loadingWidget ?? Container();
    }

    return _buildImage();
  }

  Widget _buildImage(){
    return Image.memory(
      _memory!,
      fit: widget.fit,
      width: widget.size?.width,
      height: widget.size?.height,
      errorBuilder: widget.errorBuilder,
      frameBuilder: widget.frameBuilder,
      scale: widget.scale,
      gaplessPlayback: true,
    );
  }
}
