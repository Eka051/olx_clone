import 'package:flutter/material.dart';

enum ChatType { buying, selling }

enum QuickFilterType { semua, pertemuan, belumDibaca, penting }

class ChatFilterProvider with ChangeNotifier {
  int _selectedTabIndex = 0;
  String _selectedQuickFilter = 'Semua';
  String _searchQuery = '';

  int get selectedTabIndex => _selectedTabIndex;
  String get selectedQuickFilter => _selectedQuickFilter;
  String get searchQuery => _searchQuery;

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void setQuickFilter(String filter) {
    if (_selectedQuickFilter != filter) {
      _selectedQuickFilter = filter;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }

  // Get filtered chat rooms based on current filters
  List<T> getFilteredChats<T>(
    List<T> allChats, {
    required ChatType Function(T) getType,
    required bool Function(T) isImportant,
    required bool Function(T) hasUnread,
    required String Function(T) getParticipantName,
    required String Function(T) getProductTitle,
  }) {
    List<T> filtered = List.from(allChats);

    // Apply tab filter (buying/selling/all)
    if (_selectedTabIndex == 1) {
      // Buying tab
      filtered =
          filtered.where((chat) => getType(chat) == ChatType.buying).toList();
    } else if (_selectedTabIndex == 2) {
      // Selling tab
      filtered =
          filtered.where((chat) => getType(chat) == ChatType.selling).toList();
    }
    // Index 0 is "Semua" (all chats)

    // Apply quick filter
    switch (_selectedQuickFilter) {
      case 'Pertemuan':
        // You can implement meeting filter logic here
        break;
      case 'Belum Dibaca':
        filtered = filtered.where((chat) => hasUnread(chat)).toList();
        break;
      case 'Penting':
        filtered = filtered.where((chat) => isImportant(chat)).toList();
        break;
      default: // 'Semua'
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((chat) {
            return getParticipantName(chat).toLowerCase().contains(query) ||
                getProductTitle(chat).toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }
}
