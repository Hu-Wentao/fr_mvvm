import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:fr_locale_mvvm/fr_locale_mvvm.dart';

void main() {
  test('LocaleViewModel', () {
    final vm = FrLocaleViewModel(initValue: const Locale('en'));
    expect(vm.value, const Locale('en'));
    vm.updateLocale(const Locale('zh'));
    expect(vm.value, const Locale('zh'));
  });
}
