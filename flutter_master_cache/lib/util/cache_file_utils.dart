import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CacheFileUtils {
  static Future<File> getFile(String filename) async {
    final dir = (await getApplicationCacheDirectory()).path;
    return File('$dir/$filename');
  }

  static Future<File> createFile(
    String filename, {
    bool recursive = false,
  }) async {
    final file = await getFile(filename);
    return file.create(recursive: recursive);
  }

  static Future<bool> existFile(String filename) async {
    final file = await getFile(filename);
    return file.existsSync();
  }

  static Future<File> writeFileBytes(
    String filename,
    List<int> content, {
    bool recursive = false,
  }) async {
    final file = await getFile(filename);
    await file.create(recursive: recursive);
    final raf = file.openSync(mode: FileMode.write);
    await raf.writeFrom(content);
    await raf.close();

    return file;
  }

  static Future<File> writeFileString(
    String filename,
    String content, {
    bool recursive = false,
  }) async {
    final file = await getFile(filename);
    await file.create(recursive: recursive);
    final raf = file.openSync(mode: FileMode.write)..writeStringSync(content);
    await raf.close();

    return file;
  }

  static Future<List<int>> readFileBytes(String filename) async {
    final content = <int>[];
    final file = await getFile(filename);
    final raf = file.openSync()..readIntoSync(content);
    await raf.close();

    return content;
  }

  static Future<String> readFileString(String filename) async {
    final content = await readFileBytes(filename);

    return String.fromCharCodes(content);
  }

  static Future<void> deleteFile(String filename) async {
    final file = await getFile(filename);
    await file.delete();
  }

  static Future<void> deleteCache() async {
    final dir = await getApplicationCacheDirectory();
    await dir.delete();
  }
}
