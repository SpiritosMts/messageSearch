

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test_app/main.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SMSCtr extends GetxController {
  final SmsQuery query = SmsQuery();
  List<SmsMessage> foundMessages = [];
  List<SmsMessage> allMessages = [];
  List<GlobalKey<ExpansionTileCardState>> keyCap = [];
  String searchValue = '';

  double total = 0.00;
  int messagesLimit = 50;
  int lastMonth = 0;
  int lastYear = 0;
  String currency = 'AED';

  final TextEditingController numberLimitCtr = TextEditingController();


  @override
  void onInit() {
    super.onInit();

    getAllMessages(messagesLimit);
    numberLimitCtr.text = messagesLimit.toString();

  }

  // fetch all SMSs from device
  void getAllMessages(int limit) async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      Future.delayed(Duration.zero, () async {
        showDialog( // show loading window
            barrierDismissible: false,
            context: navigatorKey.currentContext!,
            builder: (_) {
              return Dialog(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      // Some text
                      Text('Loading...')
                    ],
                  ),
                ),
              );
            });
        /// Fetch SMSs
        List<SmsMessage> messages = await query.querySms(
          kinds: [SmsQueryKind.inbox], //filter Inbox messages
          count: limit, //number of sms to read
          sort: true,
        );
        ///
        Navigator.of(navigatorKey.currentContext!).pop();// hide loading window


          allMessages = messages;
          foundMessages = allMessages;
          total = calculateTotal(foundMessages);

          keyCap = List<GlobalKey<ExpansionTileCardState>>.generate(foundMessages.length, (index) => GlobalKey(debugLabel: 'key_$index'),
              growable: false); // create this to expand messages after search
          //print('## all messages number: ${allMessages.length}');
        update();

        // show snackBar
        SnackBar snackBar = SnackBar(
          content: Text('${allMessages.length} messages loaded successfully'),
        );
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
      });
    } else {
      await Permission.sms.request();
      getAllMessages(messagesLimit);

    }
  }

  // This function is called whenever the search text field changes
  void runFilter(String enteredKeyword) {
    List<SmsMessage> results = [];
    if (enteredKeyword.isEmpty) {
      /// all messages
      // if the search field is empty or only contains white-space, we'll display all users
      results = allMessages;
    } else {
      /// filtred messages
      results = allMessages.where((SmsMessage msg) {
        return (msg.body!.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
            msg.address!.toLowerCase().contains(enteredKeyword.toLowerCase()));
      }).toList();
    }

      foundMessages = results;
      total = calculateTotal(foundMessages);

      Future.delayed(Duration(milliseconds: 80), () async {
        if (searchValue != '' && foundMessages.isNotEmpty) {
          for (GlobalKey<ExpansionTileCardState> key in keyCap) {
            key.currentState?.expand();
          }
        } else {
          for (GlobalKey<ExpansionTileCardState> key in keyCap) {
            key.currentState?.collapse();
          }
        }
      });
      update();// Refresh the UI

  }

  // detect amount in "AED" of each msg
  double detectAmount(SmsMessage msg) {
    double moneyD = 0.00;
    if (msg.body!.contains(currency)) {
      //print('msg_$index contain money');

      String clearBody = msg.body!.replaceAll(RegExp('$currency\\S+'), currency);

      List<String> words = clearBody.split(" ");
      int i = words.indexOf(currency);

      if (i > 0) {
        String amount = words[i - 1]; // get word before "AED" which is the amount
        amount.replaceAll(RegExp('[:,]'), ''); // remove any comma if exists
        moneyD = double.tryParse(amount) ?? 0.00; // parse money string to double
      }
    }
    return moneyD;
  }

  // calculate total amount of many msg
  double calculateTotal(List<SmsMessage> messages) {
    double total = 0.00;

    for (SmsMessage msg in messages) {
      double amountOfMsg = detectAmount(msg); //get money amount from msg
      total += amountOfMsg; //add amount to total
    }

    return total;
  }

  // show filter window
  void filterDialog() {
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Limit messages number"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: numberLimitCtr,
                    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0), labelText: "Number"),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),

                  Text('NOTE: a large number of messages may take some time to load',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey
                  ),)
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Apply"),
                onPressed: () {
                  getAllMessages(int.tryParse(numberLimitCtr.text) ?? messagesLimit);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Show all"),
                onPressed: () {
                  getAllMessages(0);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


}