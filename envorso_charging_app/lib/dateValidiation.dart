import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// before starting, none of this logic is my own. Below is the link I followed for cardValidation
// https://medium.com/flutter-community/validating-and-formatting-payment-card-text-fields-in-flutter-bebe12bc9c60

class DateValidation {
  DateValidation();

  // function for checking if date is valid
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a valid date';
    }

    int year, month;

    // value contains forward slash if month and year have been entered
    if (value.contains(RegExp(r'(/)'))) {
      var split = value.split(RegExp(r'(/)'));
      // value before slash is month while value to right is year
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      // only month entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1;
    }

    if ((month < 1) || (month > 12)) {
      return 'Expiry month is invalid';
    }

    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // assuming year is between 1 and 2099
      // however, just because it is valid does not it is expired. will be checked below
      return 'Expiry year is invalid';
    }

    if (!hasDateExpired(month, year)) {
      return 'Card has expired';
    }
    return null;
  }

  // converts 2 digit year to four digits
  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String curYear = now.year.toString();
      String prefix = curYear.substring(0, curYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  // below functions check to see if card has already expired
  static bool hasDateExpired(int month, int year) {
    return isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    // not expired if both year and date have not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // month has passed if:
    // year is in the past
    // OR, card's month plus another month is more than current month
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // year has passed if year we are currently in is more than the card's year
    return fourDigitsYear < now.year;
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  // This input formatter is not working as intended currently
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();

    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
