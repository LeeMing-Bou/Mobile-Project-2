import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_project_ii/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project_ii/detail_screen.dart';
import 'package:flutter_project_ii/api_module/event_model.dart';

class EventCard extends StatefulWidget {
  final String date;
  final String title;
  final String imageUrl;
  final dynamic eventId;
  final bool isFavorited;
  final bool isPaticipant;
  final int favoritesCount;
  final int participantsCount;
  final String? toggleFavoriteUrl;
  final Function()? onFavoriteToggled;

  const EventCard({
    super.key,
    required this.date,
    required this.title,
    required this.imageUrl,
    required this.eventId,
    this.isFavorited = false,
    required this.isPaticipant,
    this.favoritesCount = 0,
    this.participantsCount = 0,
    this.toggleFavoriteUrl,
    this.onFavoriteToggled,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late bool _isFavorited;
  late int _favoritesCount;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
    _favoritesCount = widget.favoritesCount;
  }

  Future<void> _toggleFavorite() async {
    if (widget.toggleFavoriteUrl == null || _isToggling) return;

    setState(() {
      _isToggling = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        debugPrint(
            'DEBUG: No authentication token available for favorite toggle');
        return;
      }

      debugPrint(
          'DEBUG: Toggling favorite for event ${widget.eventId} at URL: ${widget.toggleFavoriteUrl}');

      final response = await http.post(
        Uri.parse(widget.toggleFavoriteUrl!),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isFavorited = !_isFavorited;
          _favoritesCount += _isFavorited ? 1 : -1;
        });

        // Clear the events cache to ensure fresh data on next fetch
        await _clearEventsCache();

        // Notify parent if callback is provided
        if (widget.onFavoriteToggled != null) {
          widget.onFavoriteToggled!();
        }

        debugPrint(
            'DEBUG: Successfully toggled favorite status to: $_isFavorited');
      } else {
        debugPrint(
            'DEBUG: Failed to toggle favorite. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('DEBUG: Error toggling favorite: $e');
    } finally {
      setState(() {
        _isToggling = false;
      });
    }
  }

  // Add a method to clear the events cache
  Future<void> _clearEventsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Get all keys from SharedPreferences
      final keys = prefs.getKeys();

      // Remove all keys that start with 'events-' (our cache key pattern)
      for (final key in keys) {
        if (key.startsWith('events')) {
          await prefs.remove(key);
          debugPrint('DEBUG: Cleared events cache for key: $key');
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Error clearing events cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to DetailScreen when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              Event(
                type: Type.EVENTS,
                id: widget.eventId.toString(),
                attributes: Attributes(
                  title: widget.title,
                  featureImage: widget.imageUrl,
                  startDate: DateTime.now(), // Placeholder
                  endDate: null,
                  favoritesCount: _favoritesCount,
                  participantsCount: widget.participantsCount,
                  isFavorited: _isFavorited,
                  isParticipant: widget.isPaticipant,
                  isFeatured: false,
                ),
                relationships: [],
                links: DatumLinks(
                  self: "",
                  toggleFavorite: widget.toggleFavoriteUrl ?? "",
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:
              const Color(0xFF242A38), // Slightly lighter than app background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51), // 0.2 * 255 = ~51
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF2D3748),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Event Image - Set to 90x90
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.imageUrl.startsWith('http')
                    ? Image.network(
                        widget.imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[800],
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.white54),
                          );
                        },
                      )
                    : Image.asset(
                        widget.imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.date,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_favoritesCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite,
                                color: Colors.red, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$_favoritesCount',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Favorite Button
              IconButton(
                icon: _isToggling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      )
                    : Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.red : Colors.white54,
                      ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
