import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth/model/user_model.dart';
import 'package:socialapp/search/widgets/empty_result.dart';
import 'package:socialapp/search/widgets/initial_display.dart';
import 'package:socialapp/search/widgets/search_results.dart';
import 'package:socialapp/widget/search_list_shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Search Logic
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .get();

      setState(() {
        _searchResults = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error searching: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true, // Keyboard pops up immediately
            onChanged: (val) {
              _performSearch(val);
            },
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Search users...",
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon:
                  Icon(Icons.search, color: Colors.grey.shade500, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SearchListShimmer();
    }
    //
    if (!_hasSearched) {
      return const InitialDisplay();
    }

    if (_searchResults.isEmpty) {
      return EmptyResult(searchController: _searchController);
    }
    //
    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.only(top: 10),
      itemBuilder: (context, index) {
        final user = UserModel.fromMap(_searchResults[index]);
        return SearchResults(user: user);
      },
    );
  }
}
