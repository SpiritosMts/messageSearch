import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:sms/sms.dart';
//import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test_app/constants.dart';
import 'package:flutter_test_app/flutter_sms_ctr.dart';
import 'package:flutter_test_app/main.dart';
import 'package:flutter_test_app/styles.dart';
import 'package:get/get.dart';

//import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:ui' as ui;

import 'package:substring_highlight/substring_highlight.dart';


class SMSscreen extends StatefulWidget {
  @override
  _SMSscreenState createState() => _SMSscreenState();
}

class _SMSscreenState extends State<SMSscreen> {
  final SMSCtr c = Get.put(SMSCtr());





  // message card widget
  Widget messageCard(SmsMessage message, int index) {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    String body = message.body!;
    String address = message.address!;
    DateTime dateTime = message.date!;
    String date = dateFormat.format(dateTime);
    double moneyD = c.detectAmount(message);

    // detect if this message is the head of the month
    double monthAmount = 0.00;
    bool isNewMonth = false;
    if (dateTime.month != c.lastMonth || dateTime.year != c.lastYear) {
      isNewMonth = true;
      c.lastMonth = dateTime.month;
      c.lastYear = dateTime.year;
      List<SmsMessage> monthMessages = [];
      for (SmsMessage msg in c.foundMessages) {
        if (msg.date!.month == c.lastMonth && msg.date!.year == c.lastYear) {
          monthMessages.add(msg);
        }
      }
      monthAmount = c.calculateTotal(monthMessages);
    }
    //

    return Container(
      child: Column(
        children: [
          if (isNewMonth)
            SizedBox(
              width: 100.w,
              child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, right: 10, left: 10),
                  child: Row(
                    children: <Widget>[

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${monthFromIndex[c.lastMonth]}  ${c.lastYear}',
                          maxLines: 1,
                          style: TextStyle(),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "AED ${monthAmount.toStringAsFixed(2)}",
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )),
            ),
          ExpansionTileCard(
            key: c.keyCap[index],
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(address),
                Text(date),
              ],
            ),
            subtitle: Text('AED ${moneyD.toStringAsFixed(2)}'),
            children: <Widget>[
              Divider(
                thickness: 1.0,
                height: 1.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: SubstringHighlight(
                      text: body,
                      term: c.searchValue,
                      textStyle: bodyStyle,
                      textStyleHighlight: highlightStyle
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  /// ###################################################################################
  /// ###################################################################################


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: EasySearchBar(
          actions: [
            IconButton(
              padding: EdgeInsets.only(left: 0.0),
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                c.filterDialog();
              },
            )
          ],
          searchHintText: 'search...',
          title: Text('Messages'),
          onSearch: (value) {
            setState(() {
              c.searchValue = value;
              c.runFilter(c.searchValue);
            });
          },
        ),
        body: GetBuilder<SMSCtr>(
          builder: (ctr){
            return Stack(
              children: [
                ///messages
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: c.foundMessages.isNotEmpty
                          ? Column(
                          children: c.foundMessages.map((msg) {
                            int idx = c.foundMessages.indexOf(msg);
                            return messageCard(msg, idx);
                          }).toList())
                          : c.searchValue == ''
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            'no messages found containing "${c.searchValue}"',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///total
                if (c.foundMessages.isNotEmpty)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.blue.shade100,
                      width: 100.w,
                      height: 45,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total'),
                            Text('AED ${c.total.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            );
          },

        ));
  }
}
