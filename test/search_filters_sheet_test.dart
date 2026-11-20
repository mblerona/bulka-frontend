import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/blocs/app_bloc_providers.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('lists the amenities from the backend and stores their codes', (
    tester,
  ) async {
    await usePhoneScreen(tester);
    ListingSearchFilter? applied;
    await tester.pumpWidget(
      AppBlocProviders(
        initialLocale: const Locale('mk'),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  applied = await showModalBottomSheet<ListingSearchFilter>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SearchFiltersSheet(
                      initialFilter: ListingSearchFilter(),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // From the fake backend (test_helpers.dart), not the app's own list.
    expect(find.text('Водич'), findsOneWidget);
    expect(find.text('Тоалет'), findsOneWidget);

    // Tick Wi-Fi's checkbox (the one in the same row as its name).
    final wifiRow = find.ancestor(
      of: find.text('Wi-Fi'),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Row && w.mainAxisAlignment == MainAxisAlignment.spaceBetween,
      ),
    );
    final wifiCheckbox = find.descendant(
      of: wifiRow,
      matching: find.byType(AppCheckbox),
    );
    await tester.ensureVisible(wifiCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(wifiCheckbox);
    await tester.pump();
    final applyButton = find.textContaining('Прикажи');
    await tester.tap(applyButton.last);
    await tester.pumpAndSettle();
    expect(applied?.amenityIds, {'a7'});
  });

  testWidgets('guests: a total, how many are children, adults left over', (
    tester,
  ) async {
    await usePhoneScreen(tester);
    ListingSearchFilter? applied;
    await tester.pumpWidget(
      AppBlocProviders(
        initialLocale: const Locale('mk'),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  applied = await showModalBottomSheet<ListingSearchFilter>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SearchFiltersSheet(
                      initialFilter: ListingSearchFilter(),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    Finder button(String row, String action) => find.descendant(
      of: find.ancestor(of: find.text(row), matching: find.byType(Row)),
      matching: find.bySemanticsLabel(action),
    );
    final addGuest = button('Вкупно гости', 'Зголеми');
    final removeGuest = button('Вкупно гости', 'Намали');
    final addChild = button('Од нив деца', 'Зголеми');

    await tester.ensureVisible(addGuest);
    await tester.pumpAndSettle();
    // Unset until the first tap.
    expect(find.text('—'), findsOneWidget);
    expect(find.textContaining('Возрасни'), findsNothing);

    for (var i = 0; i < 3; i++) {
      await tester.tap(addGuest);
      await tester.pump();
    }
    // Only up to 2 of 3 can be children: at least one adult.
    for (var i = 0; i < 3; i++) {
      await tester.tap(addChild);
      await tester.pump();
    }
    expect(find.text('Возрасни: 1'), findsOneWidget);

    // Lowering the total lowers the children with it.
    await tester.tap(removeGuest);
    await tester.pump();
    expect(find.text('Возрасни: 1'), findsOneWidget);

    await tester.tap(find.textContaining('Прикажи').last);
    await tester.pumpAndSettle();
    expect(applied?.minimumGuests, 2);
    expect(applied?.children, 1);
    expect(applied?.adults, 1);
  });
}
