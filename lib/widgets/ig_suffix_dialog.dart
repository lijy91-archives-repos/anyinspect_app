import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IgSuffixDialog extends StatefulWidget {
  const IgSuffixDialog({Key? key}) : super(key: key);

  @override
  _IgSuffixDialogState createState() => _IgSuffixDialogState();


  static void show(context){
    showDialog(context: context, builder: (_){
      return const IgSuffixDialog();
    });
  }

}

class _IgSuffixDialogState extends State<IgSuffixDialog> {


  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  void _loadInitData() {
    Hive.openBox('setting').then((value) {
     final str = value.get('ig_suffix_str');
     _textEditingController.text = str;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ignore request suffix'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 400,
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  border:_borderStyle,
                  enabledBorder: _borderStyle,
                  focusedBorder: _borderStyle,
                  fillColor: Colors.grey.shade100,
                  filled: true,
                ),
                maxLines: 5,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child:const Text('Cancel')),
        TextButton(onPressed: ()async{
         final box = await Hive.openBox('setting');
         box.put('ig_suffix_str', _textEditingController.text);
         Navigator.pop(context);
        }, child:const Text('Confirm')),
      ],
    );
  }

  InputBorder get _borderStyle => const OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide.none
  );





}
