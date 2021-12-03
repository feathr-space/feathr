import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:feathr/data/status.dart';
import 'package:feathr/services/api.dart';
import 'package:feathr/widgets/status_card.dart';

/// The [Timeline] widget represents a specific timeline view, able to
/// endlessly scroll and request posts from Mastodon's API using the
/// requested timeline type.
class Timeline extends StatefulWidget {
  /// Main instance of the API service to use in the widget.
  final ApiService apiService;

  /// Type of timeline posts to be fetched from the API
  final TimelineType timelineType;

  /// Icon to be displayed for this timeline within a tabbed timeline view
  final Tab tabIcon;

  const Timeline({
    Key? key,
    required this.apiService,
    required this.timelineType,
    required this.tabIcon,
  }) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

/// The [_TimelineState] class wraps up logic and state for the [Timeline] screen.
class _TimelineState extends State<Timeline> {
  /// Amount of statuses to be requested from the API on each call.
  static const _pageSize = 25;

  /// Controller for the paged list of posts.
  final PagingController<String?, Status> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  /// If called, requests a new page of statuses from the Mastodon API.
  Future<void> _fetchPage(String? lastStatusId) async {
    try {
      final List<Status> newStatuses = await widget.apiService.getStatusList(
        widget.timelineType,
        lastStatusId,
        _pageSize,
      );

      final isLastPage = newStatuses.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newStatuses);
      } else {
        final nextPageKey = newStatuses.last.id;
        _pagingController.appendPage(newStatuses, nextPageKey);
      }
    } catch (error) {
      // TODO: improve error handling (show a message)
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RefreshIndicator(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagedListView<String?, Status>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Status>(
            itemBuilder: (context, item, index) => StatusCard(
              item,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
