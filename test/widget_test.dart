import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cbtech/main.dart';

void main() {
  testWidgets('CBTech app initial smoke test and login screen render', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CBTechApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica se os elementos da tela de login ou dashboard são renderizados com sucesso
    expect(find.text('CB Tech'), findsWidgets);
  });
}
