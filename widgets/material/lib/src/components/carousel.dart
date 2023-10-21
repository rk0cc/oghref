import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;

base class ImageCarousel extends StatefulWidget {
  final List<oghref.ImageInfo> images;
  final bool preferHTTPS;
  final double controlIconSize;
  final Duration pageChangeDuration;
  final Curve pageChangeCurve;
  final Color? iconColour;

  ImageCarousel(this.images,
      {this.preferHTTPS = true,
      this.controlIconSize = 18,
      this.pageChangeDuration = const Duration(milliseconds: 500),
      this.pageChangeCurve = Curves.easeInOut,
      this.iconColour,
      super.key});

  @override
  State<ImageCarousel> createState() {
    return _ImageCarouselState();
  }
}

final class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController controller;

  @override
  void initState() {
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void movePrevious() {
    controller.previousPage(
        duration: widget.pageChangeDuration, curve: widget.pageChangeCurve);
  }

  void moveNext() {
    controller.nextPage(
        duration: widget.pageChangeDuration, curve: widget.pageChangeCurve);
  }

  Widget _buildSingleImage(BuildContext context, oghref.ImageInfo imgInfo) {
    Uri? destination = imgInfo.url;

    if (widget.preferHTTPS && imgInfo.secureUrl != null) {
      destination = imgInfo.secureUrl;
    }

    return CachedNetworkImage(
        imageUrl: destination!.toString(),
        fit: BoxFit.contain,
        httpHeaders: {"user-agent": MetaFetch.userAgentString},
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined)),
        placeholder: (context, url) => const Center(
            child: SizedBox.square(
                dimension: 16, child: CircularProgressIndicator())));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        PageView.builder(
            controller: controller,
            itemBuilder: (context, index) =>
                _buildSingleImage(context, widget.images[index]),
            itemCount: widget.images.length),
        Positioned(
            left: 0,
            child: IconButton(
                onPressed: movePrevious,
                color: widget.iconColour,
                icon: Icon(Icons.arrow_back_outlined,
                    size: widget.controlIconSize))),
        Positioned(
            right: 0,
            child: IconButton(
                onPressed: moveNext,
                color: widget.iconColour,
                icon: Icon(Icons.arrow_forward_outlined,
                    size: widget.controlIconSize)))
      ],
    );
  }
}
