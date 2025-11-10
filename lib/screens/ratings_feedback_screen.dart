import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/feedback_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/ratings/rating_summary.dart';
import '../widgets/ratings/feedback_card.dart';
import '../widgets/common/empty_state.dart';
import '../services/feedback_service.dart';

class RatingsFeedbackScreen extends StatefulWidget {
  const RatingsFeedbackScreen({super.key});

  @override
  State<RatingsFeedbackScreen> createState() => _RatingsFeedbackScreenState();
}

class _RatingsFeedbackScreenState extends State<RatingsFeedbackScreen> {
  String _selectedFilter = 'Latest';
  final FeedbackService _feedbackService = FeedbackService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: AppStrings.ratingsAndFeedback,
      ),
      body: StreamBuilder<List<FeedbackModel>>(
        stream: _feedbackService.streamFeedback(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading feedback: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Retry
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final feedbacks = snapshot.data ?? [];
          final filteredFeedbacks = _getFilteredFeedbacks(feedbacks);
          final averageRating = _getAverageRating(feedbacks);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Summary
                RatingSummary(
                  averageRating: averageRating,
                  totalRatings: feedbacks.length,
                ),
                const SizedBox(height: 24),
                // Feedback Section Header
                _buildFeedbackHeader(),
                const SizedBox(height: 16),
                // Feedback List
                if (filteredFeedbacks.isEmpty)
                  const EmptyState(
                    icon: Icons.feedback_outlined,
                    message: 'No feedback yet',
                    subtitle: 'Feedback will appear here once received',
                  )
                else
                  ...filteredFeedbacks.map((feedback) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FeedbackCard(feedback: feedback),
                      )),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          onSelected: (value) {
            setState(() {
              _selectedFilter = value;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Latest',
              child: Text('Latest'),
            ),
            const PopupMenuItem(
              value: 'Oldest',
              child: Text('Oldest'),
            ),
            const PopupMenuItem(
              value: 'Highest Rating',
              child: Text('Highest Rating'),
            ),
            const PopupMenuItem(
              value: 'Lowest Rating',
              child: Text('Lowest Rating'),
            ),
          ],
        ),
      ],
    );
  }

  List<FeedbackModel> _getFilteredFeedbacks(List<FeedbackModel> feedbacks) {
    final sorted = List<FeedbackModel>.from(feedbacks);
    if (_selectedFilter == 'Latest') {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    } else if (_selectedFilter == 'Oldest') {
      sorted.sort((a, b) => a.date.compareTo(b.date));
    } else if (_selectedFilter == 'Highest Rating') {
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedFilter == 'Lowest Rating') {
      sorted.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return sorted;
  }

  double _getAverageRating(List<FeedbackModel> feedbacks) {
    if (feedbacks.isEmpty) return 0.0;
    final sum = feedbacks.fold<double>(
      0.0,
      (prev, feedback) => prev + feedback.rating,
    );
    return sum / feedbacks.length;
  }
}
