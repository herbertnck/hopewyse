import 'package:flutter/material.dart';
import 'package:hopewyse/pages/homepage1/book.dart';

class LibraryProvider extends ChangeNotifier {
  List<Book> _books = [];

  List<Book> get books => _books;

  void addToLibrary(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void removeFromLibrary(Book book) {
    _books.remove(book);
    notifyListeners();
  }
}
