import 'package:enhanced_view/enhanced_view.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      child: DazzlingBackground(
        blurRadius: 10,
        gradientColors: [
          CupertinoTheme.of(
            context,
          ).primaryColor.withAlpha((255.0 * 0.5).round()),
          CupertinoColors.systemPink
              .resolveFrom(context)
              .withAlpha((255.0 * 0.3).round()),
          CupertinoColors.systemBlue
              .resolveFrom(context)
              .withAlpha((255.0 * 0.4).round()),
        ],
        dotColor: CupertinoColors.systemPurple
            .resolveFrom(context)
            .withAlpha((255.0 * 0.4).round()),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        dotCount: 10,
        child: Center(
          child: SizedBox(
            width: 500,
            height: 500,
            child: CupertinoMaterialBackground(
              borderRadius: BorderRadius.circular(50),
              materialStyle: MaterialStyle.ultraThinMaterial,
              child: Center(
                child: Text("Hello world"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
