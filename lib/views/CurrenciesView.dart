import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:live_currency_rate/live_currency_rate.dart';

import 'CurrencyConverterScreen.dart';
import 'FollowExchangeRatesScreen.dart';
import 'NotificationsView.dart';

class CurrenciesView extends StatefulWidget {
  const CurrenciesView({Key? key});

  @override
  State<CurrenciesView> createState() => _CurrenciesViewState();
}

class _CurrenciesViewState extends State<CurrenciesView> {
  List<String> savedConversions = [];
  late User? user;
  bool hasConversions = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  List<String> prepareCurrencyData(QuerySnapshot snapshot) {
    List<String> currencyDataList = [];

    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String from = data['from'] ?? 'Unknown';
      String to = data['to'] ?? 'Unknown';

      int existingIndex = currencyDataList.indexOf('$from - $to');

      if (existingIndex != -1) {
        currencyDataList[existingIndex] += ', $to';
      } else {
        currencyDataList.add('$from - $to');
      }
    });

    return currencyDataList;
  }

  Future<List<String>> _calculateRates(QuerySnapshot snapshot) async {
    List<String> currencyDataList = prepareCurrencyData(snapshot);
    List<String> rates = [];
    String userId = user?.uid ?? '';

    for (var currency in currencyDataList) {
      List<String> currencies = currency.split(' - ');
      String from = currencies[0];
      String to = currencies[1];

      for (var doc in snapshot.docs) {
        String docUserId = doc['userId'];
        String docFrom = doc['from'];
        String docTo = doc['to'];

        if (docUserId == userId && docFrom == from && docTo == to) {
          CurrencyRate rate =
              await LiveCurrencyRate.convertCurrency(docFrom, docTo, 1);
          rates.add(rate.result.toString());
          break;
        }
      }
    }
    return rates;
  }

  Future<void> _deleteCurrencyRate(
      String from, String to, String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('followedCurrencies')
          .where('from', isEqualTo: from)
          .where('to', isEqualTo: to)
          .where('userId', isEqualTo: userId)
          .get();

      List<DocumentSnapshot> documents = snapshot.docs;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (final doc in documents) {
          transaction.delete(doc.reference);
        }
      });

      print('Currency rate deleted successfully!');
    } catch (error) {
      print('Error deleting currency rate: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currencies'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationsView(),
              ));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FollowExchangeRatesScreen(),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Follow exchange rates',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CurrencyConvrterScreen(),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
                        child: Icon(
                          Icons.currency_exchange,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Currency converter',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('followedCurrencies')
                            .where('userId', isEqualTo: user!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('No followed currencies available.'),
                            );
                          }
                          return FutureBuilder<List<String>>(
                            future: _calculateRates(snapshot.data!),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<String>> ratesSnapshot) {
                              if (ratesSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (ratesSnapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${ratesSnapshot.error}'),
                                );
                              }
                              if (!ratesSnapshot.hasData ||
                                  ratesSnapshot.data!.isEmpty) {
                                return Center(
                                  child: Text('No rates available.'),
                                );
                              }
                              List<String> rates = ratesSnapshot.data!;
                              return ListView.builder(
                                itemCount: rates.length,
                                itemBuilder: (context, index) {
                                  var currency = snapshot.data!.docs[index];
                                  String from = currency['from'];
                                  String to = currency['to'];
                                  String userId = "";
                                  if (user != null) {
                                    userId = user!.uid;
                                  }
                                  double rate =
                                      double.tryParse(rates[index]) ?? 0.0;

                                  return Dismissible(
                                    key: Key('$from$to$rate'),
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(right: 16.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 36.0,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      if (direction ==
                                              DismissDirection.endToStart ||
                                          direction ==
                                              DismissDirection.startToEnd) {
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  Text('Delete Currency Rate?'),
                                              content: Text(
                                                  'Are you sure you want to delete this currency rate?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return confirmDelete;
                                      }
                                      return false;
                                    },
                                    onDismissed: (direction) {
                                      if (direction ==
                                              DismissDirection.endToStart ||
                                          direction ==
                                              DismissDirection.startToEnd) {
                                        _deleteCurrencyRate(from, to, userId);
                                      }
                                    },
                                    child: ListTile(
                                      title:
                                          Text('From: $from To: $to = $rate'),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
