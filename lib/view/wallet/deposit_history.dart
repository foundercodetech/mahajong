import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mahajong/generated/assets.dart';
import 'package:mahajong/model/deposit_model.dart';
import 'package:mahajong/model/user_model.dart';
import 'package:mahajong/res/aap_colors.dart';
import 'package:mahajong/res/api_urls.dart';
import 'package:mahajong/res/components/app_bar.dart';
import 'package:mahajong/res/components/app_btn.dart';
import 'package:mahajong/res/components/text_widget.dart';
import 'package:mahajong/res/provider/user_view_provider.dart';

class DepositHistory extends StatefulWidget {
  const DepositHistory({Key? key}) : super(key: key);

  @override
  State<DepositHistory> createState() => _DepositHistoryState();
}

class _DepositHistoryState extends State<DepositHistory> with SingleTickerProviderStateMixin {
  int? responseStatusCode;
  bool errorOccured = false;

  @override
  void initState() {
    super.initState();
    depositHistory();
  }

  @override
  Widget build(BuildContext context) {
    final heights = MediaQuery.of(context).size.height;
    final widths = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GradientAppBar(
          leading: const AppBackBtn(),
          title: textWidget(
              text: 'Deposit History',
              fontSize: 25,
              color: AppColors.primaryTextColor),
          gradient: AppColors.primaryGradient),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: errorOccured
            ? buildErrorContainer(() => depositHistory())
            : ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            responseStatusCode == 400
                ? const Notfounddata()
                : depositItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: depositItems.length,
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
                                          color: depositItems[index].status == "0"
                                              ? Colors.orange
                                              : depositItems[index].status == "1"
                                              ? AppColors.DepositButton
                                              : Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: textWidget(
                                          text: depositItems[index].status == "0"
                                              ? "Pending"
                                              : depositItems[index].status == "1"
                                              ? "Complete"
                                              : "Failed",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryTextColor),
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
                                      text: depositItems[index].amount.toString(),
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
                                      text: "Type",
                                      fontSize: widths * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),
                                  Image.asset(
                                    depositItems[index].type == "2"
                                        ? Assets.imagesUsdtIcon
                                        : Assets.imagesFastpayImage,
                                    height: heights * 0.05,
                                  )
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
                                        DateTime.parse(
                                            depositItems[index].created_at.toString())),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                                      text: "Order number",
                                      fontSize: widths * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryTextColor),
                                  Row(
                                    children: [
                                      textWidget(
                                          text: depositItems[index].orderid.toString(),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondaryTextColor),
                                      SizedBox(
                                        width: widths * 0.01,
                                      ),
                                      Image.asset(
                                        Assets.iconsCopy,
                                        color: Colors.grey,
                                        height: heights * 0.03,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }

  List<DepositModel> depositItems = [];
  UserViewProvider userProvider = UserViewProvider();

  Future<void> depositHistory() async {
    try {
      UserModel user = await userProvider.getUser();
      String token = user.id.toString();
      final response = await http.get(Uri.parse(ApiUrl.depositHistory+token),);
      print(ApiUrl.depositHistory + token);
      print('depositHistory');

      setState(() {
        responseStatusCode = response.statusCode;
        errorOccured = false; // Reset error state
      });

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          depositItems = responseData.map((item) => DepositModel.fromJson(item)).toList();
        });
      } else if (response.statusCode == 400) {
        if (kDebugMode) {
          print('Data not found');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Set error state
      setState(() {
        depositItems = [];
        errorOccured = true;
      });
      print('Exception occurred: $e');
    }
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
}

class Notfounddata extends StatelessWidget {
  const Notfounddata({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        SizedBox(height: heights * 0.07),
        const Text(
          "Data not found",
        )
      ],
    );
  }
}


