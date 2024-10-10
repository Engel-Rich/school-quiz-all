import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/widgets/empty_display.dart';
import 'package:quizeapp/models/subscription_model.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Abonnement List',
          style: primaryTextStyle(size: 20),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Abonnement List',
                style: primaryTextStyle(size: 20),
              ),
              16.height,
              StreamBuilder<List<SubscriptionModel>>(
                stream: null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator().center();
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Something went wrong ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.length == 0 ||
                      snapshot.data == null) {
                    return Center(child: EmptyDisplay());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      return Column(
                        children: [
                          Text(data.id!),
                          Text(data.userId),
                          Text(data.abonnementId),
                          Text(data.datefin.toString()),
                          Text(data.createdAt.toString()),
                          Text(data.updatedAt.toString()),
                          Text(data.isActive.toString()),
                          16.height,
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
