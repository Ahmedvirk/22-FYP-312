import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/chat/home_page.dart';
import 'package:veterinaryapp/client/screens/home_screen.dart';
import 'package:veterinaryapp/login/ui/recoverpage.dart';
import 'package:veterinaryapp/login/ui/signin.dart';
import 'package:veterinaryapp/login/ui/signup.dart';
import 'package:veterinaryapp/medical/record_page.dart';
import 'package:veterinaryapp/posts/news_feed.dart';
import 'package:veterinaryapp/posts/upload.dart';
import 'package:veterinaryapp/posts/user_posts.dart';
import 'package:veterinaryapp/profile/page/profile_page.dart';

import 'medical/record_page_list.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var user = FirebaseAuth.instance.currentUser;
    // final args = settings.arguments;
    String? name = settings.name;
    var args = (settings.arguments ?? {}) as Map;
    switch (name!.toLowerCase()) {
      // case '/map':
      //   {
      //     // return MaterialPageRoute(builder: (_) => InboxScreen());
      //     return MaterialPageRoute(builder: (_) => MapPage());
      //   }
      case '/chats':
        {
          // return MaterialPageRoute(builder: (_) => InboxScreen());
          return MaterialPageRoute(builder: (_) => const InboxPageChatty());
        }
      case '/loginpage':
        {
          return MaterialPageRoute(builder: (_) => SignInPage());
        }
      case '/signuppage':
        {
          return MaterialPageRoute(builder: (_) => const SignUpScreen());
        }
      case '/homepage':
        {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      case '/profile':
        {
          return MaterialPageRoute(builder: (_) => const ProfilePage());
        }
      case '/upload':
        {
          return MaterialPageRoute(builder: (_) => const Upload());
        }
      case '/feed':
        {
          return MaterialPageRoute(builder: (_) => User_Posts());
        }
      case '/newsfeed':
        {
          return MaterialPageRoute(
              builder: (_) => NewsFeed(currentUser: user!));
        }
      case '/record':
        {
          return MaterialPageRoute(builder: (_) => const MedicalRecords());
        }
      case '/medicines':
        {
          return MaterialPageRoute(builder: (_) => const MedicalRecordsList());
        }
      // case '/appointment':
      //   {
      //     return MaterialPageRoute(builder: (_) => const AppointmentPage());
      //   }
      case '/testingpage':
        {
          return _errorPage(args['title']);
        }
      case '/doctors':
        {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      case 'recover':
        {
          return MaterialPageRoute(builder: (_) => const RecoverPage());
        }
      default:
        return _errorPage(settings.name.toString());
    }
  }

  static Route<dynamic> _errorPage(String name) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Icon(Icons.error)),
        body: Center(
          child: Text(name.toUpperCase() + " page Coming Soon"),
        ),
        backgroundColor: Colors.red,
      );
    });
  }
}
