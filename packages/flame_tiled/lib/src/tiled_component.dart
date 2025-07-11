import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/src/renderable_layers/tile_layers/tile_layer.dart';
import 'package:flame_tiled/src/renderable_tile_map.dart';
import 'package:flame_tiled/src/tile_atlas.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

/// {@template _tiled_component}
/// A Flame [Component] to render a Tiled TiledMap.
///
/// It uses a preloaded [RenderableTiledMap] to batch rendering calls into
/// Sprite Batches.
/// {@endtemplate}
class TiledComponent<T extends FlameGame> extends PositionComponent
    with HasGameReference<T> {
  /// Map instance of this component.
  RenderableTiledMap tileMap;

  /// This property **cannot** be reassigned at runtime. To make the
  /// [PositionComponent] larger or smaller, change its [scale].
  @override
  set size(Vector2 size) {
    // Intentionally left empty.
  }

  /// This property **cannot** be reassigned at runtime. To make the
  /// [PositionComponent] larger or smaller, change its [scale].
  @override
  set width(double w) {
    // Intentionally left empty.
  }

  /// This property **cannot** be reassigned at runtime. To make the
  /// [PositionComponent] larger or smaller, change its [scale].
  @override
  set height(double h) {
    // Intentionally left empty.
  }

  /// {@macro _tiled_component}
  TiledComponent(
    this.tileMap, {
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : super(
          size: computeSize(
            tileMap.map.orientation,
            tileMap.destTileSize,
            tileMap.map.tileWidth,
            tileMap.map.tileHeight,
            tileMap.map.width,
            tileMap.map.height,
            tileMap.map.staggerAxis,
          ),
        );

  @override
  Future<void>? onLoad() async {
    super.onLoad();
    // Automatically use the first attached CameraComponent camera if it's not
    // already set..
    tileMap.camera ??= game.children.query<CameraComponent>().firstOrNull;
  }

  @override
  void update(double dt) {
    tileMap.update(dt);
  }

  @override
  void render(Canvas canvas) {
    tileMap.render(canvas);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    tileMap.handleResize(size);
  }

  /// Loads a [TiledComponent] from a file.
  ///
  /// {@macro renderable_tile_prefix_path}
  ///
  /// By default, [RenderableTiledMap] renders flipped tiles if they exist.
  /// You can disable it by passing [ignoreFlip] as `true`.
  ///
  /// A custom [atlasMaxX] and [atlasMaxY] can be provided in case you want to
  /// change the max size of [TiledAtlas] that [TiledComponent] creates
  /// internally.
  ///
  /// TiledComponent uses Flame's `SpriteBatch` to render the map. Which under
  /// the hood uses `Canvas.drawAtlas` calls to render the tiles. This behavior
  /// can be changed by setting `useAtlas` to `false`. This will make the map
  /// be rendered with `Canvas.drawImageRect` calls instead.
  static Future<TiledComponent> load(
    String fileName,
    Vector2 destTileSize, {
    double? atlasMaxX,
    double? atlasMaxY,
    String prefix = 'assets/tiles/',
    int? priority,
    bool? ignoreFlip,
    AssetBundle? bundle,
    Images? images,
    bool Function(Tileset)? tsxPackingFilter,
    bool useAtlas = true,
    Paint Function(double opacity)? layerPaintFactory,
    double atlasPackingSpacingX = 0,
    double atlasPackingSpacingY = 0,
    ComponentKey? key,
  }) async {
    return TiledComponent(
      await RenderableTiledMap.fromFile(
        fileName,
        destTileSize,
        atlasMaxX: atlasMaxX,
        atlasMaxY: atlasMaxY,
        ignoreFlip: ignoreFlip,
        prefix: prefix,
        bundle: bundle,
        images: images,
        tsxPackingFilter: tsxPackingFilter,
        useAtlas: useAtlas,
        layerPaintFactory: layerPaintFactory,
        atlasPackingSpacingX: atlasPackingSpacingX,
        atlasPackingSpacingY: atlasPackingSpacingY,
      ),
      priority: priority,
      key: key,
    );
  }

  @visibleForTesting
  static Vector2 computeSize(
    MapOrientation? orientation,
    Vector2 destTileSize,
    int tileWidth,
    int tileHeight,
    int mapWidth,
    int mapHeight,
    StaggerAxis? staggerAxis,
  ) {
    if (orientation == null) {
      return NotifyingVector2.zero();
    }
    final xScale = destTileSize.x / tileWidth;
    final yScale = destTileSize.y / tileHeight;

    final tileScaled = Vector2(
      tileWidth * xScale,
      tileHeight * yScale,
    );

    switch (orientation) {
      case MapOrientation.staggered:
        return staggerAxis == StaggerAxis.y
            ? Vector2(
                tileScaled.x * mapWidth + tileScaled.x / 2,
                (mapHeight + 1) * (tileScaled.y / 2),
              )
            : Vector2(
                (mapWidth + 1) * (tileScaled.x / 2),
                tileScaled.y * mapHeight + tileScaled.y / 2,
              );

      case MapOrientation.hexagonal:
        return staggerAxis == StaggerAxis.y
            ? Vector2(
                mapWidth * tileScaled.x + tileScaled.x / 2,
                tileScaled.y + ((mapHeight - 1) * tileScaled.y * 0.75),
              )
            : Vector2(
                tileScaled.x + ((mapWidth - 1) * tileScaled.x * 0.75),
                (mapHeight * tileScaled.y) + tileScaled.y / 2,
              );

      case MapOrientation.isometric:
        final halfTile = tileScaled / 2;
        final dimensions = mapWidth + mapHeight;
        return halfTile..scale(dimensions.toDouble());

      case MapOrientation.orthogonal:
        return Vector2(
          mapWidth * tileScaled.x,
          mapHeight * tileScaled.y,
        );
    }
  }

  /// Returns a list of all the Atlases that were created for this component.
  ///
  /// This method is useful for debugging purposes as it allows developers to
  /// check how the tilesets were packed into the atlas.
  ///
  /// It returns a record with the Atlas key and its image.
  List<(String, Image)> atlases() {
    return tileMap.renderableLayers
        .whereType<FlameTileLayer>()
        .where((layer) => layer.tiledAtlas.atlas != null)
        .map((layer) {
          final image = layer.tiledAtlas.atlas;
          final key = layer.tiledAtlas.key;
          return (key, image!);
        })
        .fold<Map<String, (String, Image)>>(
          {},
          (previousValue, element) {
            previousValue.putIfAbsent(element.$1, () => element);
            return previousValue;
          },
        )
        .values
        .toList();
  }
}
