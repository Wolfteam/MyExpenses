import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:photo_view/photo_view.dart';
import 'package:transparent_image/transparent_image.dart';

class FormImagePreview extends StatelessWidget {
  final String imagePath;

  const FormImagePreview({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: const Center(child: CircularProgressIndicator()),
          ),
          GestureDetector(
            onTap: () => _showImageDialog(context),
            child: FadeInImage(
              fit: BoxFit.fill,
              fadeInDuration: const Duration(seconds: 1),
              placeholder: MemoryImage(kTransparentImage),
              image: FileImage(File(imagePath)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionFormBloc>(),
        child: _ImageDialog(imagePath: imagePath),
      ),
    );
  }
}

class _ImageDialog extends StatelessWidget {
  final String imagePath;

  const _ImageDialog({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PhotoView(imageProvider: FileImage(File(imagePath))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteImageDialog(context).then(
                    (value) {
                      if (value == true) {
                        _deleteImage(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteImage(BuildContext context) {
    context.read<TransactionFormBloc>().add(const TransactionFormEvent.imageChanged(path: '', imageExists: false));
    Navigator.of(context).pop();
  }

  Future<bool?> _showDeleteImageDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionFormBloc>(),
        child: const _DeleteImageDialog(),
      ),
    );
  }
}

class _DeleteImageDialog extends StatelessWidget {
  const _DeleteImageDialog();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return AlertDialog(
      title: Text(i18n.removeImg),
      content: Text(i18n.areYouSure),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(i18n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(i18n.yes),
        ),
      ],
    );
  }
}
