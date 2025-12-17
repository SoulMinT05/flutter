import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_demo/pages/todo_screen.dart';
import 'package:easy_localization/easy_localization.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Todo List Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         primaryColor: Colors.green,
//         textTheme: TextTheme(
//           bodyMedium: TextStyle(fontSize: 18, color: Colors.yellow),
//         ),
//       ),
//       home: TodoScreen(),
//       // home: Counter(),
//       // home: const TodoPage(),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('vi')],
      path: 'assets/translations', // folder chứa file en.json và vi.json
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );

  // runApp(MaterialApp(home: HomePage()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settingBox = Hive.box('settings');

    var savedLangCode = settingBox.get(
      'language',
      defaultValue: context.fallbackLocale?.languageCode,
    );

    Locale savedLocale = Locale(savedLangCode);

    return MaterialApp(
      title: 'Todo App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      // locale: context.locale,
      locale: savedLocale,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home_title'.tr()),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              var settingBox = Hive.box('settings');

              // Đổi locale giữa en <-> vi
              if (context.locale.languageCode == 'en') {
                context.setLocale(Locale('vi'));
                settingBox.put('language', 'vi');
              } else {
                context.setLocale(Locale('en'));
                settingBox.put('language', 'en');
              }
            },
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input mật khẩu
            TextField(
              controller: _passwordController,
              obscureText: true, // ẩn chữ khi nhập
              decoration: InputDecoration(
                labelText: 'enter_password'.tr(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Nút chuyển sang page 2 nếu mật khẩu đúng
            ElevatedButton.icon(
              onPressed: () {
                if (_passwordController.text == '1234') {
                  // mật khẩu đúng
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondHome()),
                  );
                } else {
                  // mật khẩu sai
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Wrong password!')));
                }
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('go_to_second'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('second_home_title'.tr())),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.arrow_back, size: 40),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
