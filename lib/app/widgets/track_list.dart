import 'package:flutter/material.dart';
import '../../features/soundtracks/domain/entities/soundtrack.dart';

/// Lista de tracks de un soundtrack.
/// Muestra cada track con su número, nombre y duración.
class TrackList extends StatelessWidget {
  const TrackList({
    super.key,
    required this.tracks,
  });

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return TrackListItem(
          track: track,
        );
      },
    );
  }
}

/// Widget que muestra un track individual en la lista.
class TrackListItem extends StatefulWidget {
  const TrackListItem({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  State<TrackListItem> createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: widget.track.previewUrl != null
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Preview: ${widget.track.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          : null,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapCancel: () => setState(() => _isHovered = false),
      onTapUp: (_) => setState(() => _isHovered = false),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _isHovered
              ? colorScheme.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Número de track
            SizedBox(
              width: 28,
              child: Text(
                '${widget.track.trackNumber}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            // Nombre del track
            Expanded(
              child: Text(
                widget.track.name,
                style: textTheme.bodyMedium?.copyWith(
                  color: _isHovered
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Duración
            Text(
              widget.track.formattedDuration,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            // Icono de preview si está disponible
            if (widget.track.previewUrl != null) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.play_circle_outline,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

