# Dashboard Enhancements - Interactive Cards

## New Features Added

### 1. **Interactive Reclaimable Card**

- **Action**: Tap on "Reclaimable" card
- **Behavior**: Navigates to `/results` screen to view all reclaimable categories
- **Visual Feedback**: Subtitle changed from "estimated" to "tap to view"

### 2. **Interactive Files Card with Breakdown Modal**

- **Action**: Tap on "Files" card
- **Behavior**: Opens a draggable bottom sheet showing files breakdown
- **Visual Feedback**: Subtitle changed from "scanned" to "tap to view"

### Files Breakdown Modal Features

#### **Draggable Bottom Sheet**

- Initial height: 60% of screen
- Minimum height: 40% of screen
- Maximum height: 90% of screen
- User can drag to resize

#### **Breakdown Categories Displayed**

1. **Duplicates**

   - Shows number of duplicate file groups
   - Displays total reclaimable space from duplicates
   - Orange colored icon
   - Tappable to close modal (ready for navigation enhancement)

2. **Junk Files**

   - Shows count of junk files
   - Displays total space occupied by junk
   - Red colored icon
   - Tappable to close modal

3. **Rarely Used Files**

   - Shows count of rarely used files (90+ days)
   - Displays total space of rarely used files
   - Blue colored icon
   - Tappable to close modal

4. **Total Files**
   - Shows total discovered files count
   - Displays total bytes scanned
   - Grey colored icon
   - Not tappable (summary only)

#### **Visual Design**

- Material Design 3 cards with rounded corners
- Color-coded icons with background tinting
- File count and size displayed for each category
- Chevron indicator for tappable items
- Clean header with title and close button
- Scrollable content for smaller screens

## User Flow

### Viewing Reclaimable Space

```
Dashboard → Tap "Reclaimable" Card → Results Screen (with tabs)
```

### Viewing Files Breakdown

```
Dashboard → Tap "Files" Card → Bottom Sheet Opens
↓
View breakdown by category:
- Duplicates: X files · Y GB
- Junk: X files · Y GB
- Rarely Used: X files · Y GB
- Total: X files · Y GB
↓
Optional: Tap category to close and return
```

## Code Structure

### Main Changes in `dashboard_screen.dart`

1. **Added Method**: `_showFilesBreakdown()`

   - Creates and displays modal bottom sheet
   - Calculates breakdown from scan results
   - Builds draggable sheet UI

2. **Added Method**: `_buildBreakdownCard()`

   - Reusable card widget for each category
   - Takes title, count, bytes, icon, color, and tap callback
   - Returns styled Card with InkWell for tap effects

3. **Updated Widgets**: Wrapped StatCards in GestureDetector
   - Reclaimable card navigates to results
   - Files card shows breakdown modal

### Data Flow

```dart
// Reclaimable Card
GestureDetector(onTap: () => context.go('/results'))
  ↓ StatCard(subtitle: 'tap to view')

// Files Card
GestureDetector(onTap: () => _showFilesBreakdown(context, result))
  ↓ StatCard(subtitle: 'tap to view')

// Breakdown Modal
showModalBottomSheet(
  DraggableScrollableSheet(
    ListView(
      _buildBreakdownCard × 4 categories
    )
  )
)
```

## Future Enhancements (Optional)

### 1. Navigate from Breakdown Cards

Currently tapping categories closes the modal. Can be enhanced to:

- Tap Duplicates → Navigate to `/duplicates`
- Tap Junk → Navigate to `/junk`
- Tap Rarely Used → Navigate to `/recents`

### 2. Add More Details

- Show percentage of total space
- Add progress bars for each category
- Display largest file in each category

### 3. Storage Breakdown by Type

Add another modal for storage stats card showing:

- Images: X GB
- Videos: Y GB
- Audio: Z GB
- Documents: A GB
- etc.

### 4. Quick Actions

Add action buttons in breakdown:

- "Clean Now" for each category
- "View All" to navigate to detail screen
- "Ignore" to exclude from reclaimable

## Testing Checklist

- [x] Reclaimable card navigates to results
- [x] Files card opens bottom sheet
- [x] Bottom sheet is draggable
- [x] All categories display correct counts
- [x] File sizes are properly formatted
- [x] Cards are tappable with visual feedback
- [x] Close button works
- [x] Tapping outside modal closes it
- [ ] Test with large file counts (1000+)
- [ ] Test with zero files in categories
- [ ] Test on different screen sizes

## Screenshots

[Add screenshots here showing:]

1. Dashboard with updated card labels
2. Files breakdown modal opened
3. Dragged modal at different heights
4. Tapping a category

## Accessibility

- ✅ Semantic labels for screen readers
- ✅ Sufficient touch targets (48x48 minimum)
- ✅ Color contrast meets WCAG AA standards
- ✅ Icons paired with text labels
- ✅ Keyboard navigation ready (web)

## Performance

- Minimal overhead: Modal builds only when tapped
- No additional API calls: Uses existing scan results
- Efficient calculations: Fold operations on existing lists
- Lazy loading: Modal content builds on demand
