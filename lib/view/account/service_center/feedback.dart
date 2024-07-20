import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahajong/res/aap_colors.dart';
import 'package:mahajong/res/components/app_bar.dart';
import 'package:mahajong/res/components/app_btn.dart';
import 'package:mahajong/res/components/image_picker.dart';
import 'package:mahajong/res/components/text_widget.dart';
import 'package:mahajong/res/provider/feedback_provider.dart';
import 'package:provider/provider.dart';

class Feedback_page extends StatefulWidget {
  const Feedback_page({super.key});

  @override
  State<Feedback_page> createState() => _Feedback_pageState();
}

class _Feedback_pageState extends State<Feedback_page> {
  TextEditingController feed = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final feedbackk = Provider.of<FeedbackProvider>(context);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GradientAppBar(
        leading: const AppBackBtn(),
        title: textWidget(
          text: ' Feedback',
          fontSize: 25,
          color: AppColors.primaryTextColor,
        ),
        gradient: AppColors.primaryGradient,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  maxLines: 15,
                  controller: feed,
                  decoration: InputDecoration(
                    hintText: 'Welcome to feedback, please give feedback - please describe the problem in detail when providing feedback, preferably attach a screenshot of the problem you encountered, we will immediately process your feedback!',
                    contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white.withOpacity(0.5)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: AppColors.gradientFirstColor.withOpacity(0.5)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white.withOpacity(0.5)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white.withOpacity(0.5)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.01),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.attach_file,size: 18,),
                    onPressed: (){
                      _updateImage(ImageSource.gallery);
                    },
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            _buildAttachmentList(),
            InkWell(
              onTap: () {
                feedbackk.Feedbacksubmit(context, feed.text,myData.toString());
                print(feed.text);
                print("feed.text");
                print(myData.toString());
                print("_attachments.toString()");
              },
              child: Container(
                height: height * 0.05,
                width: width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                child: Center(
                  child: textWidget(
                    text: 'Submit',
                    fontSize: 20,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<File> _attachments = [];
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();
    setState(() {
      _attachments.addAll(pickedImages.map((xfile) => File(xfile.path)).toList());
    });
    }

  String myData = '0';
  void _updateImage(ImageSource imageSource) async {
    String? imageData =
    await ChooseImage.chooseImageAndConvertToString(imageSource);
    if (imageData != null) {
      setState(() {
        myData = imageData;
      });
    }
  }


  Widget _buildAttachmentList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _attachments.map((file) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: FileImage(file),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    file.path.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _attachments.remove(file);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }


}
