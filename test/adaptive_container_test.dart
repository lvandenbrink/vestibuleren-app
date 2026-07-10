import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestibuleren/core/adaptive_container.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: AdaptiveContainer(child: child)));

  void setWidth(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // A child that greedily fills all available width, so its rendered size
  // reflects the constraint AdaptiveContainer actually imposes.
  Widget fillingChild(Key key) =>
      SizedBox(key: key, width: double.infinity, height: 10);

  testWidgets('renders full-bleed below the 600dp breakpoint', (tester) async {
    setWidth(tester, 599);
    const key = Key('child');
    await tester.pumpWidget(harness(fillingChild(key)));

    expect(tester.getSize(find.byKey(key)).width, 599);
  });

  testWidgets('constrains to a 480dp centered column at the 600dp breakpoint', (
    tester,
  ) async {
    setWidth(tester, 600);
    const key = Key('child');
    await tester.pumpWidget(harness(fillingChild(key)));

    expect(tester.getSize(find.byKey(key)).width, 480);
  });

  testWidgets(
    'gives an immediate, non-sliver margin the instant it activates',
    (tester) async {
      setWidth(tester, 601);
      const key = Key('child');
      await tester.pumpWidget(harness(fillingChild(key)));

      final margin = tester.getTopLeft(find.byKey(key)).dx;
      expect(margin, greaterThanOrEqualTo(60));
    },
  );

  testWidgets(
    'stays centered with a generous margin at typical phone-landscape widths',
    (tester) async {
      setWidth(tester, 926); // e.g. iPhone 14 Pro Max landscape
      const key = Key('child');
      await tester.pumpWidget(harness(fillingChild(key)));

      final rect = tester.getRect(find.byKey(key));
      expect(rect.width, 480);
      expect(rect.left, closeTo((926 - 480) / 2, 0.01));
    },
  );

  testWidgets('wraps the constrained column in a SafeArea', (tester) async {
    setWidth(tester, 700);
    await tester.pumpWidget(harness(const Text('content')));

    expect(
      find.ancestor(of: find.text('content'), matching: find.byType(SafeArea)),
      findsOneWidget,
    );
  });

  testWidgets('does not add a SafeArea when full-bleed', (tester) async {
    setWidth(tester, 400);
    await tester.pumpWidget(harness(const Text('content')));

    expect(find.byType(SafeArea), findsNothing);
  });

  testWidgets(
    'keeps the app bar full-bleed even when the body is constrained',
    (tester) async {
      setWidth(tester, 926);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Title')),
            body: AdaptiveContainer(child: const Text('content')),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AppBar)).width, 926);
    },
  );
}
