import 'dart:convert';

import 'package:mahajong/generated/assets.dart';
import 'package:mahajong/model/user_model.dart';
import 'package:mahajong/model/withdrawhistory_model.dart';
import 'package:mahajong/res/aap_colors.dart';
import 'package:mahajong/res/api_urls.dart';
import 'package:mahajong/res/components/app_bar.dart';
import 'package:mahajong/res/components/app_btn.dart';
import 'package:mahajong/res/components/text_widget.dart';
import 'package:mahajong/res/helper/api_helper.dart';
import 'package:mahajong/res/provider/user_view_provider.dart';
import 'package:mahajong/res/provider/withdrawhistory_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;



class WithdrawHistory extends StatefulWidget {
  const WithdrawHistory({super.key});

  @override
  State<WithdrawHistory> createState() => _WithdrawHistoryState();
}

class _WithdrawHistoryState extends State<WithdrawHistory> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    WithdrawHistoryyy();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    selectedCatIndex = 0;
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
  }


  late int selectedCatIndex;

  int ?responseStatuscode;
  bool errorOccured = false;


  BaseApiHelper baseApiHelper = BaseApiHelper();


  @override
  Widget build(BuildContext context) {
    final withdrawdeposit = Provider
        .of<WithdrawHistoryProvider>(context)
        .withdrawlist;

    final heights = MediaQuery
        .of(context)
        .size
        .height;
    final widths = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: GradientAppBar(
          leading: AppBackBtn(),
          title: textWidget(
              text: 'Withdraw History',
              fontSize: 25,
              color: AppColors.primaryTextColor),
          gradient: AppColors.primaryGradient),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false),
        child: errorOccured
            ? buildErrorContainer(() => WithdrawHistoryyy())
            : ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            responseStatuscode == 400
                ? const Notfounddata()
                : WithdrawItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                :Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: WithdrawItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 35,
                                      width: widths * 0.30,
                                      decoration: BoxDecoration(
                                          color: WithdrawItems[index].status ==
                                              "0"
                                              ? Colors.orange
                                              : WithdrawItems[index].status ==
                                              "1"
                                              ? AppColors.DepositButton
                                              : Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: textWidget(
                                          text: WithdrawItems[index].status ==
                                              "0"
                                              ? "Pending"
                                              : WithdrawItems[index].status ==
                                              "1" ? "Complete" : "Failed",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryTextColor
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  textWidget(
                                      text: "Balance",
                                      fontSize: widths * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),
                                  textWidget(
                                      text: WithdrawItems[index].amount
                                          .toString(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  textWidget(
                                      text: "Account No.",
                                      fontSize: widths * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),
                                  textWidget(
                                      text: WithdrawItems[index].accountno
                                          .toString(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  textWidget(
                                      text: "Time",
                                      fontSize: widths * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),

                                  Text(
                                    DateFormat("dd-MMM-yyyy, hh:mm a").format(
                                        DateTime.parse(WithdrawItems[index].date
                                            .toString())),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,),),
                                ],
                              ),
                            ),


                          ],
                        ),
                      );
                    })

            ),
          ],
        ),
      ),

    );
  }



  Widget buildErrorContainer(VoidCallback onRetry) {
    final heights = MediaQuery.of(context).size.height;
    final widths = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image(
            image: const AssetImage(Assets.imagesNoDataAvailable),
            height: heights / 3,
            width: widths / 2,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              textWidget(
                text: 'Failed to load data',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ],
    );
  }


  UserViewProvider userProvider = UserViewProvider();

  List<WithdrawModel> WithdrawItems = [];

  Future<void> WithdrawHistoryyy() async {
    try {
      UserModel user = await userProvider.getUser();
      String token = user.id.toString();

      final response = await http.get(
        Uri.parse(ApiUrl.withdrawHistory + token),);
      print(ApiUrl.withdrawHistory + token);
      print('withdrawHistory');

      setState(() {
        responseStatuscode = response.statusCode;
      });

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          WithdrawItems =
              responseData.map((item) => WithdrawModel.fromJson(item)).toList();
          // selectedIndex = items.isNotEmpty ? 0:-1; //
        });
      }
      else if (response.statusCode == 400) {
        if (kDebugMode) {
          print('Data not found');
        }
      }
      else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Set error state
      setState(() {
        WithdrawItems = [];
        errorOccured = true;
      });
      print('Exception occurred: $e');
    }
  }
}




class Notfounddata extends StatelessWidget {
  const Notfounddata({super.key});

  @override
  Widget build(BuildContext context){
    final heights = MediaQuery.of(context).size.height;
    final widths = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: const AssetImage(Assets.imagesNoDataAvailable),
          height: heights / 3,
          width: widths / 2,
        ),
        SizedBox(height: heights*0.07),
        const Text("Data not found",)
      ],
    );
  }

}
