import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ouspost/post.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(392, 759),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              // これを追加するだけ

              title: 'ホーム',
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Color.fromARGB(0, 253, 253, 246),
                fontFamily: 'NotoSansCJKJp',
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                colorSchemeSeed: Color.fromARGB(0, 253, 253, 246),
                fontFamily: 'NotoSansCJKJp',
              ),
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // スプラッシュ画面などに書き換えても良い
                  }
                  if (snapshot.hasData) {
                    // User が null でなない、つまりサインイン済みのホーム画面へ
                    return post();
                  }
                  // User が null である、つまり未サインインのサインイン画面へ
                  return Login();
                },
              ));
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'これはテストです。ボタンを押すと数字がふえるで。',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}



class NavBar extends StatefulWidget {
  const NavBar({
    Key? key,
  }) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
//firestoreキャッシュ
  Stream<DocumentSnapshot>? _stream;
  late DocumentSnapshot _data;

  @override
  void initState() {
    super.initState();

    _stream =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();


  }

//UIDをFirebaseAythから取得
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final uid = FirebaseAuth.instance.currentUser?.uid;






  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () {

            },
            child: StreamBuilder<DocumentSnapshot>(
              stream: _stream,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text('エラーが発生しました。');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('データが見つかりませんでした。');
                }

                _data = snapshot.data!;

                final displayName = _data['displayName'] as String?;
                final email = _data['email'] as String?;
                final image = _data['photoURL'] as String?;

                return UserAccountsDrawerHeader(
                  accountName: Text(displayName ?? 'ゲストユーザー'),
                  accountEmail:
                  Text(email ?? '', style: TextStyle(color: Colors.white)),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        image ??
                            'https://pbs.twimg.com/profile_images/1439164154502287361/1dyVrzQO_400x400.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://pbs.twimg.com/profile_banners/1394312681209749510/1634787753/1500x500'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('ログアウト'),
            onTap: () async{
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("ログアウトします。"),
                    content: Text("ログインページに戻るけどいい？"),
                    actions: <Widget>[
                      // ボタン領域
                      TextButton(
                        child: Text("ダメやで"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text("ええで"),
                        onPressed: () async {
                          // ログアウト処理
                          // 内部で保持しているログイン情報等が初期化される
                          await FirebaseAuth.instance.signOut();
                          // ログイン画面に遷移＋チャット画面を破棄
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return Login();
                            }),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
