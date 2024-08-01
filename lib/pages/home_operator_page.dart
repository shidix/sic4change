import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

class HomeOperatorPage extends StatefulWidget {
  final Profile? profile;
  const HomeOperatorPage({Key? key, this.profile}) : super(key: key);

  @override
  State<HomeOperatorPage> createState() => _HomeOperatorPageState();
}

class _HomeOperatorPageState extends State<HomeOperatorPage> {
  Profile? profile;
  @override
  void initState() {
    super.initState();
    if (widget.profile == null) {
      Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
          .then((value) {
        profile = value;
        setState(() {});
      });
    } else {
      profile = widget.profile;
    }
  }

  @override
  Widget build(BuildContext context) {
    // return to login_page if profile is null
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context,
                  url: "/home_operator", profile: profile),
              const CircularProgressIndicator(),
              const Text(
                'Loading profile...',
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context,
                  url: "/home_operator", profile: profile),
              Text(
                'Welcome to Home Operator Page, ${profile!.mainRole}!',
              ),
            ],
          ),
        ),
      );
    }
  }
}
