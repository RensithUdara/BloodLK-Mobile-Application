import 'package:bloodlk/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows BloodLK splash branding', (tester) async {
    await tester.pumpWidget(const BloodLkApp());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'BloodLK',
      ),
      findsOneWidget,
    );
    expect(find.text('Donate Blood  .  Save Lives'), findsOneWidget);
  });
}
