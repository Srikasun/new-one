import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';

/// Widget to display a book cover image
class BookCoverWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const BookCoverWidget({
    super.key,
    this.imageUrl,
    this.width = 80,
    this.height = 120,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(radius),
        errorWidget: (context, url, error) => _buildPlaceholder(radius),
      ),
    );
  }

  Widget _buildPlaceholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: radius,
      ),
      child: const Center(
        child: Icon(
          Icons.book,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: radius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Widget to display reading progress
class ReadingProgressWidget extends StatelessWidget {
  final double progress;
  final int currentPage;
  final int totalPages;
  final bool showLabel;

  const ReadingProgressWidget({
    super.key,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentPage of $totalPages pages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.neutral200,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(progress),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.25) {
      return AppColors.toRead;
    } else if (progress < 0.5) {
      return AppColors.reading;
    } else if (progress < 0.75) {
      return AppColors.secondary;
    } else {
      return AppColors.completed;
    }
  }
}

/// Widget to display book status chip
class BookStatusChip extends StatelessWidget {
  final BookStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const BookStatusChip({
    super.key,
    required this.status,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(status.displayName),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      backgroundColor: _getBackgroundColor(),
      selectedColor: _getSelectedColor(),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : _getLabelColor(),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case BookStatus.toRead:
        return AppColors.toRead.withOpacity(0.1);
      case BookStatus.reading:
        return AppColors.reading.withOpacity(0.1);
      case BookStatus.completed:
        return AppColors.completed.withOpacity(0.1);
      case BookStatus.abandoned:
        return AppColors.abandoned.withOpacity(0.1);
    }
  }

  Color _getSelectedColor() {
    switch (status) {
      case BookStatus.toRead:
        return AppColors.toRead;
      case BookStatus.reading:
        return AppColors.reading;
      case BookStatus.completed:
        return AppColors.completed;
      case BookStatus.abandoned:
        return AppColors.abandoned;
    }
  }

  Color _getLabelColor() {
    switch (status) {
      case BookStatus.toRead:
        return AppColors.toRead;
      case BookStatus.reading:
        return AppColors.reading;
      case BookStatus.completed:
        return AppColors.completed;
      case BookStatus.abandoned:
        return AppColors.abandoned;
    }
  }
}

/// Rating widget with stars
class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 24,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(starValue.toDouble())
              : null,
          child: Icon(
            icon,
            size: size,
            color: AppColors.accent,
          ),
        );
      }),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
