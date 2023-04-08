import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ouspost/post.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'authentication_error.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:ouspost/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'email_check.dart';

extension OnPrimary on Color {
  /// 輝度が高ければ黒, 低ければ白を返す
  Color get onPrimary {
    // 輝度により黒か白かを決定する
    if (computeLuminance() < 0.5) {
      return Colors.white;
    }
    return Colors.black;
  }
}

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  //利用規約に同意したかの確認
  bool _isChecked = false;

  // Firebase 認証
  final _auth = FirebaseAuth.instance;

  String _login_Email = ""; // 入力されたメールアドレス
  String _login_Password = ""; // 入力されたパスワード
  String _login_forgot_Email = ""; // 入力されたパスワード

  String _infoText = ""; // ログインに関する情報を表示
  // エラーメッセージを日本語化するためのクラス
  final auth_error = Authentication_error_to_ja();

  final DateTime now = DateTime.now();

  //ユーザー情報保存
  CollectionReference users = FirebaseFirestore.instance.collection('users');

//Appleサインイン






  @override
  Widget build(BuildContext context) {

    Future<bool> _willPopCallback() async {
      return true;
    }

    final Color primaryColor;

    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Scrollbar(
                isAlwaysShown: true,
                child:

                   Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: <Widget>[

                          Container(
                              padding:
                              EdgeInsets.only(top: 0, left: 20.0, right: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,

                                children: <Widget>[
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText: 'メールアドレス',
                                        labelStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightGreen))),
                                    onChanged: (String value) {
                                      setState(() {
                                        _login_Email = value;
                                      });
                                    },
                                    inputFormatters: [],
                                  ),
                                  SizedBox(height: 20.0.h),
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText: 'パスワード',
                                        labelStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightGreen))),
                                    obscureText: true,
                                    onChanged: (String value) {
                                      setState(() {
                                        _login_Password = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0.h,
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.transparent),
                                            ),
                                            child: Checkbox(
                                              value: _isChecked,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  _isChecked = value ?? false;
                                                });
                                              },
                                              materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                          InkWell(
                                              onTap: () {
                                                launch(
                                                    'https://tan-q-bot-unofficial.com/terms_of_service/');
                                              },
                                              child: Text(
                                                '利用規約に同意した？',
                                                style: TextStyle(
                                                    color: Colors.lightGreen,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                    TextDecoration.underline),
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 5.0.h),
                                      Container(
                                        alignment: Alignment(-1.0, 0.0),
                                        padding: EdgeInsets.only(
                                            top: 15.0, left: 10),
                                        child: InkWell(
                                            child: Text(
                                              'パスワードを忘れた方へ',
                                              style: TextStyle(
                                                  color: Colors.lightGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Montserrat',
                                                  decoration:
                                                  TextDecoration.underline),
                                            ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      "パスワードを忘れた人へ",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    content: Column(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: <Widget>[
                                                          Container(
                                                              width: 100,
                                                              height: 100,
                                                              child: Image(
                                                                image: AssetImage(
                                                                    'password.gif'),
                                                                fit: BoxFit.cover,
                                                              )),
                                                          Text(
                                                            '下のテキストボックスにメールアドレスを入力して、リセットボタンを押してください。',
                                                            textAlign:
                                                            TextAlign.center,
                                                          ),
                                                          TextField(
                                                            decoration: InputDecoration(
                                                                labelText: 'メールアドレス',
                                                                labelStyle: TextStyle(
                                                                    fontFamily:
                                                                    'Montserrat',
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    color:
                                                                    Colors.grey),
                                                                focusedBorder:
                                                                UnderlineInputBorder(
                                                                    borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                        Colors
                                                                            .lightGreen))),
                                                            onChanged:
                                                                (String value) {
                                                              setState(() {
                                                                _login_forgot_Email =
                                                                    value;
                                                              });
                                                            },
                                                          ),
                                                        ]),
                                                    actions: <Widget>[
                                                      // ボタン領域
                                                      TextButton(
                                                        child: Text("やっぱやめる"),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                      TextButton(
                                                          child: Text("リセットする"),
                                                          onPressed: () {
                                                            _auth
                                                                .sendPasswordResetEmail(
                                                                email:
                                                                _login_forgot_Email);

                                                            showDialog(
                                                                context: context,
                                                                builder: (_) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                      "パスワードリセット完了",
                                                                      textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                      ),
                                                                    ),
                                                                    content: Column(
                                                                      mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                      children: [
                                                                        Container(
                                                                            width:
                                                                            100,
                                                                            height:
                                                                            100,
                                                                            child:
                                                                            Image(
                                                                              image: AssetImage(
                                                                                  'assets/icon/rocket.gif'),
                                                                              fit: BoxFit
                                                                                  .cover,
                                                                            )),
                                                                        Text(
                                                                          "入力してくれたメールアドレス宛にパスワードリセットをするメールを送信しました。\nもし届いていない場合は迷惑メールフォルダーを確認してください。",
                                                                          textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        child: Text(
                                                                            "オッケー"),
                                                                        onPressed: () =>
                                                                            Navigator
                                                                                .pop(
                                                                                context),
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          }),
                                                    ],
                                                  );
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                  //エラー表示

                                  //エラー表示（ここまで）
                                  SizedBox(height: 10.0.h),

                                  //ログインボタン
                                  GestureDetector(
                                    onTap: _isChecked
                                        ? () async {
                                      Fluttertoast.showToast(
                                          msg: "ログイン中です\nちょっと待ってね。");
                                      try {
                                        // メール/パスワードでログイン
                                        UserCredential _result = await _auth
                                            .signInWithEmailAndPassword(
                                          email: _login_Email,
                                          password: _login_Password,
                                        );

                                        // ログイン成功
                                        User _user = _result
                                            .user!; // ログインユーザーのIDを取得

                                        // Email確認が済んでいる場合のみHome画面へ
                                        if (_user.emailVerified) {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                    return post();
                                                  }));
                                          Fluttertoast.showToast(
                                              msg: "ログインしました");

                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(_user.uid)
                                              .set({
                                            'email': _login_Email,
                                            'uid': _user.uid,
                                            'displayName': '名前未設定',
                                            'day': DateFormat(
                                                'yyyy/MM/dd(E) HH:mm:ss')
                                                .format(now)
                                          });
                                          print("Created");
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Emailcheck(
                                                        email:
                                                        _login_Email,
                                                        pswd:
                                                        _login_Password,
                                                        from: 2)),
                                          );
                                          Fluttertoast.showToast(
                                              msg: "ログインしました");
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        String errorMessage;
                                        if (e.code == 'weak-password') {
                                          errorMessage = 'パスワードが弱すぎます';
                                        } else
                                        if (e.code == 'email-already-in-use') {
                                          errorMessage = 'そのメールアドレスは既に登録されています';
                                        } else if (e.code == 'invalid-email') {
                                          errorMessage = '無効なメールアドレスです';
                                        } else if (e.code == 'user-not-found') {
                                          errorMessage = 'ユーザーが見つかりませんでした';
                                        } else if (e.code == 'wrong-password') {
                                          errorMessage = 'パスワードが間違っています';
                                        } else {
                                          errorMessage = 'エラーが発生しました';
                                        }
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('エラー'),
                                              content: Text(_infoText),
                                              actions: <Widget>[

                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    // OKボタンが押されたときの処理
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        print('FirebaseAuthのエラー: $errorMessage');
                                        setState(() {
                                          _infoText = errorMessage;
                                        });
                                      }
                                    }
                                        : () {
                                      Fluttertoast.showToast(
                                          msg:
                                          "利用規約に同意してね！"); // ボタンが無効なときの処理
                                    }, child: Container(
                                    height: 40.0.h,
                                    child: Material(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.lightGreen[200],
                                      child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Center(
                                                  child: Text(
                                                    'サインイン',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Montserrat'),
                                                  )

                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                  ),


                                  //ログインボタンここまで
                                  SizedBox(height: 20.0.h),
                                  //大学のアカウントでログイン
                                  GestureDetector(
                                    onTap: _isChecked
                                        ? () async {
                                      Fluttertoast.showToast(
                                          msg: "ログイン中です\nちょっと待ってね。");
                                      try {
                                        // メール/パスワードでログイン
                                        final userCredential =
                                        await signInWithGoogle();
                                        // ログインに成功した場合
                                        // チャット画面に遷移＋ログイン画面を破棄
                                        await Navigator.of(context)
                                            .pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) {
                                                  return post();
                                                }),
                                            result: Fluttertoast.showToast(
                                                msg:
                                                "大学のアカウントでログインしました"));
                                      } on PlatformException catch (e) {}
                                    }
                                        : () {
                                      Fluttertoast.showToast(
                                          msg:
                                          "利用規約に同意してね！"); // ボタンが無効なときの処理
                                    }, child: Container(
                                    height: 40.0.h,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.lightGreen,
                                              style: BorderStyle.solid,
                                              width: 1.0.w),
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                              20.0)),
                                      child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                '大学のアカウントでサインイン',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Montserrat'),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                  ),
                                  //大学のアカウントでログイン（ここまで）
                                  SizedBox(height: 20.0.h),
                                  //Appleでサインイン






                                  //Appleでサインイン（ここまで）
                                  SizedBox(height: 20.0.h),

                                  //サインアップ

                                  //サインアップ（ここまで）
                                  //ゲストモード


                                  SizedBox(height: 50.0.h),
                                ],
                              )),
                        ],
                      ),
                    ))));
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'ユーザーによって操作が中止されました',
      );
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth!.idToken,
      accessToken: googleAuth.accessToken,
    );

    // Sign in with the credential and return the UserCredential
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(GoogleAuthProvider.credential(
      idToken: credential.idToken,
      accessToken: credential.accessToken,
    ));

    // Firestoreにユーザー情報を書き込む
    final User? user = userCredential.user;
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.collection('users').doc(user!.uid).set({
      'displayName': user.displayName,
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoURL,
      'day': DateFormat('yyyy/MM/dd(E) HH:mm:ss').format(now)
    });

    return userCredential;
  }

}

// Firebase Authentication利用時の日本語エラーメッセージ
class Authentication_error_to_ja {
  // ログイン時の日本語エラーメッセージ
  login_error_msg(int error_code, String org_error_msg) {
    String error_msg;

    if (error_code == 360587416) {
      error_msg = '有効なメールアドレスを入力してください。';
    } else if (error_code == 505284406) {
      // 入力されたメールアドレスが登録されていない場合
      error_msg = 'メールアドレスかパスワードが間違っています。';
    } else if (error_code == 185768934) {
      // 入力されたパスワードが間違っている場合
      error_msg = 'メールアドレスかパスワードが間違っています。';
    } else if (error_code == 362765553) {
      // メールアドレスかパスワードがEmpty or Nullの場合
      error_msg = 'メールアドレスとパスワードを入力してください。';
    } else {
      error_msg = org_error_msg + '[' + error_code.toString() + ']';
    }

    return error_msg;
  }

  // アカウント登録時の日本語エラーメッセージ
  register_error_msg(int error_code, String org_error_msg) {
    String error_msg;

    if (error_code == 360587416) {
      error_msg = '有効なメールアドレスを入力してください。';
    } else if (error_code == 34618382) {
      // メールアドレスかパスワードがEmpty or Nullの場合
      error_msg = '既に登録済みのメールアドレスです。';
    } else if (error_code == 447031946) {
      // メールアドレスかパスワードがEmpty or Nullの場合
      error_msg = 'メールアドレスとパスワードを入力してください。';
    } else {
      error_msg = org_error_msg + '[' + error_code.toString() + ']';
    }

    return error_msg;
  }
}
