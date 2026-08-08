/// Fired whenever an example item's "liked" flag changes anywhere in the app,
/// so every open screen showing that item can update itself.
///
/// This mirrors the cross-feature sync pattern: fire the event optimistically
/// before the request, and fire it again with the old value if the request
/// fails (see ExampleFeatureBloc).
class ExampleItemChangedEvent {
  final int itemId;
  final bool isLiked;

  ExampleItemChangedEvent({required this.itemId, required this.isLiked});
}
