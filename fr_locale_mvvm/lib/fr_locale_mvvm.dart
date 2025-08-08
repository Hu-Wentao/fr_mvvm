library fr_locale_mvvm;

import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';

extension LocaleX on Locale {
  /// [localeString]: zh | zh_CN

  /// [separator] '-' | '_'; en-US, zh_CN;
  String rawToString({required String separator, String? dftCountry}) {
    final out = StringBuffer(languageCode);
    if (scriptCode != null && scriptCode!.isNotEmpty) {
      out.write('$separator$scriptCode');
    }
    final country = countryCode;
    if (country != null && country.isNotEmpty) {
      out.write('$separator$country');
    } else if (dftCountry != null && dftCountry.isNotEmpty) {
      out.write('$separator$dftCountry');
    }
    return out.toString();
  }
}

abstract class ILocaleViewModel extends FrViewModel<Locale> {
  List<Locale> get allLocales;

  ValueStream<Locale> get stmLocale => stream;

  /// input: zh | zh_CN | en_US
  Locale fnLang2Locale(String localeString) {
    final lang = localeString.substring(0, 2);
    final country = switch (localeString.length) {
      2 => null,
      5 => localeString.substring(3, 5),
      _ => null,
    };
    Locale? candi;
    for (final l in allLocales) {
      if (l.languageCode == lang) {
        candi = l;
        if (country == null) break;
      }
      if (l.languageCode == lang && l.countryCode == country) {
        candi = l;
      }
    }
    return candi ?? allLocales.first;
  }

  updateLocale(Locale locale) => updateRaw((_) => locale);

  /// <country>_<script>_<lang>: zh-Hans-CN
  ///   en | zh_CN | km_KH
  String get lang => value.rawToString(separator: '_');

  String rawToString({String separator = '-', dftCountry = 'US'}) =>
      value.rawToString(separator: separator, dftCountry: 'US');

  late final ValueStream<String> stmLang = stream
      .distinctBy((e) => e)
      .mapValue((e) => e.rawToString(separator: '_'));

  /// 'zh-CN'; 'en-US';
  late final ValueStream<String> stmLocaleBackendFmt = stream
      .distinctBy((e) => e)
      .mapValue((value) => value.rawToString(separator: '-'));
}

class FrLocaleViewModel extends ILocaleViewModel {
  @override
  final List<Locale> allLocales;
  @override
  final Locale initValue;

  FrLocaleViewModel({
    required this.initValue,
    Stream<Locale>? upstream,
    this.allLocales = const [],
  }) {
    if (upstream != null) autoDispose(upstream.listen(updateLocale));
  }
}

class DevLocaleSwitchView extends StatelessWidget {
  const DevLocaleSwitchView({super.key});

  @override
  Widget build(BuildContext context) {
    return FrStreamBuilder<ILocaleViewModel, Locale>(builder: (context, s) {
      final vm = s.vm;
      final locale = s.data;
      final all = vm.allLocales;
      return MenuAnchor(
        menuChildren: [
          for (final l in all)
            RadioMenuButton<Locale>(
              value: l,
              groupValue: locale,
              onChanged: (v) {
                if (v != null) vm.updateLocale(v);
              },
              child: Text("$l"),
            ),
        ],
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return TextButton(
            // focusNode: _buttonFocusNode,
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Text('Locale: $locale'),
          );
        },
      );
    });
  }
}
