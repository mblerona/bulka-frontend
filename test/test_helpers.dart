import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests draw text in a placeholder font where every letter is a full
/// square, which makes everything look far too wide. Call once (in
/// `setUpAll`) to use the app's real font so text widths match the phone.
Future<void> loadAppFonts() async {
  final montserrat = FontLoader('Montserrat');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('fonts/Montserrat-$weight.ttf').readAsBytesSync();
    montserrat.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await montserrat.load();
}

/// Answers the app's API calls in tests (see `flutter_test_config.dart`).
/// Unknown paths get a 404.
class FakeBackendAdapter implements HttpClientAdapter {
  static const Map<String, Object> responses = {
    '/api/categories': {
      'success': true,
      'data': [
        {'id': 'c1', 'code': 'rural-stay', 'name': 'Сместување'},
        {'id': 'c2', 'code': 'gastronomy', 'name': 'Гастрономија'},
        {'id': 'c3', 'code': 'food-tasting', 'name': 'Понуда на храна'},
        {'id': 'c4', 'code': 'nature-activities', 'name': 'Активности'},
        {'id': 'c5', 'code': 'svc-0050', 'name': 'Продавница'},
        {'id': 'c6', 'parentCategoryId': 'c1', 'code': 'rooms', 'name': 'Соби'},
      ],
    },
    '/api/amenities': {
      'success': true,
      'data': [
        {'id': 'a1', 'code': 'parking', 'name': 'Паркинг'},
        {'id': 'a2', 'code': 'family-friendly', 'name': 'Погодно за семејства'},
        {
          'id': 'a3',
          'code': 'pets-allowed',
          'name': 'Домашни миленици дозволени',
        },
        {'id': 'a4', 'code': 'guide', 'name': 'Водич'},
        {'id': 'a5', 'code': 'meal-included', 'name': 'Оброк вклучен'},
        {
          'id': 'a6',
          'code': 'accessible',
          'name': 'Пристапно за лица со попреченост',
        },
        {'id': 'a7', 'code': 'wi-fi', 'name': 'Wi-Fi'},
        {'id': 'a8', 'code': 'toilet', 'name': 'Тоалет'},
      ],
    },
    '/api/regions': {
      'success': true,
      'data': [
        {'id': 'r1', 'name': 'Пелагониски Регион'},
        {'id': 'r2', 'name': 'Југоисточен Регион'},
      ],
    },
    '/api/listings': {
      'success': true,
      'data': {
        'items': [fakeFarmStay, fakeWorkshop],
        'page': 1,
        'pageSize': 20,
        'totalCount': 2,
        'totalPages': 1,
      },
    },
    '/api/listings/test-farm-stay': {
      'success': true,
      'data': {
        ...fakeFarmStay,
        'description': 'Рустикално сместување со домашна храна.',
        'mode': 'Itemized',
        'provider': {'businessName': 'Ранчо Тест'},
        'images': [],
      },
    },
    '/api/itemized-listings/test-farm-stay': {
      'success': true,
      'data': {
        'items': [
          {
            'id': 'i1',
            'kind': 'Accommodation',
            'title': 'Куќа за 6 гости',
            'accommodation': {
              'nightlyPriceAmount': 3000,
              'priceBasis': 'PerUnit',
              'guestCapacity': 6,
            },
          },
          {
            'id': 'i2',
            'kind': 'Experience',
            'title': 'Пешачење до водопадите',
            'experience': {
              'priceAmount': 1200,
              'pricingModel': 'FixedPrice',
              'capacity': 6,
            },
          },
        ],
      },
    },
    '/api/listings/test-cheese-workshop': {
      'success': true,
      'data': {
        ...fakeWorkshop,
        'description': 'Научете како се прави сирење.',
        'mode': 'Itemized',
        'images': [],
      },
    },
    '/api/itemized-listings/test-cheese-workshop': {
      'success': true,
      'data': {
        'items': [
          {
            'id': 'i3',
            'kind': 'Experience',
            'title': 'Работилница',
            'experience': {'priceAmount': 1300, 'capacity': 10},
          },
        ],
      },
    },
  };

  /// A listing with a bookable (nightly) item.
  static const Map<String, Object?> fakeFarmStay = {
    'id': 'l1',
    'slug': 'test-farm-stay',
    'title': 'Ранчо на Ката',
    'shortDescription': 'Рустикално сместување',
    'municipalityName': 'Чашка',
    'regionName': 'Вардарски Регион',
    'coverImageUrl': null,
    'priceAmount': null,
    'ratingSummary': {'averageRating': 4.6, 'reviewCount': 3},
    'categories': [
      {'id': 'c1', 'code': 'rural-stay', 'name': 'Сместување'},
    ],
    'amenities': [
      {'id': 'a7', 'code': 'wi-fi', 'name': 'Wi-Fi'},
    ],
  };

  /// A listing with only an experience (not bookable in the app yet).
  static const Map<String, Object?> fakeWorkshop = {
    'id': 'l2',
    'slug': 'test-cheese-workshop',
    'title': 'Работилница за сирење',
    'settlementName': 'Битола',
    'municipalityName': 'Битола',
    'coverImageUrl': null,
    'priceAmount': null,
    'ratingSummary': {'averageRating': null, 'reviewCount': 0},
    'categories': [],
    'amenities': [],
  };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = responses[options.path];
    return ResponseBody.fromString(
      jsonEncode(body ?? const {'success': false}),
      body == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A typical phone screen (360×740) instead of the 800×600 test default.
Future<void> usePhoneScreen(WidgetTester tester) async {
  const size = Size(360, 740);
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
