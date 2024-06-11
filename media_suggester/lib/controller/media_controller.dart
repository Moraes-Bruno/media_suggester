import 'package:flutter/material.dart';
import 'package:media_suggester/models/Media.dart';

class MediaController extends PageController{
  final Media _media = Media();

  dynamic searchMedia(String pesquisa){
    return _media.searchMedia(pesquisa);
  }
}