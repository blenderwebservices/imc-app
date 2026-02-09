import 'package:flutter_test/flutter_test.dart';
import 'package:imc_app/main.dart';

void main() {
  testWidgets('BMI Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BMICalculatorApp());

    // Verify that the title is present.
    expect(find.text('Calculadora de IMC'), findsAtLeast(1));

    // Verify that input fields are present.
    expect(find.text('Estatura (m)'), findsOneWidget);
    expect(find.text('Peso (kg)'), findsOneWidget);
    expect(find.text('Calcular'), findsOneWidget);
  });
}
