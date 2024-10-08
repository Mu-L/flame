import 'package:flame_devtools/providers/position_component_attributes_provider.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PositionComponentAttributesForm extends ConsumerWidget {
  const PositionComponentAttributesForm({
    required this.componentId,
    super.key,
  });

  final int componentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributesData = ref.watch(
      positionComponentAttributesProvider(
        componentId,
      ),
    );

    return attributesData.when(
      error: (e, s) => const Text(
        'Error loading component attributes',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (attributes) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Position',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Row(
              children: [
                IncrementalNumberFormField<double>(
                  key: Key('x_field_$componentId'),
                  label: 'X',
                  initialValue: attributes.x,
                  onChanged: (v) {
                    Repository.setPositionComponentAttribute(
                      id: componentId,
                      attribute: 'x',
                      value: v,
                    );
                  },
                ),
                const SizedBox(width: 8),
                IncrementalNumberFormField<double>(
                  key: Key('y_field_$componentId'),
                  label: 'Y',
                  initialValue: attributes.y,
                  onChanged: (v) {
                    Repository.setPositionComponentAttribute(
                      id: componentId,
                      attribute: 'y',
                      value: v,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Size',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Row(
              children: [
                IncrementalNumberFormField<double>(
                  key: Key('width_field_$componentId'),
                  label: 'Width',
                  initialValue: attributes.width,
                  onChanged: (v) {
                    Repository.setPositionComponentAttribute(
                      id: componentId,
                      attribute: 'width',
                      value: v,
                    );
                  },
                ),
                const SizedBox(width: 8),
                IncrementalNumberFormField<double>(
                  key: Key('height_field_$componentId'),
                  label: 'Height',
                  initialValue: attributes.height,
                  onChanged: (v) {
                    Repository.setPositionComponentAttribute(
                      id: componentId,
                      attribute: 'height',
                      value: v,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Angle',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            IncrementalNumberFormField<double>(
              key: Key('angle_field_$componentId'),
              label: 'Radian',
              initialValue: attributes.angle,
              onChanged: (v) {
                Repository.setPositionComponentAttribute(
                  id: componentId,
                  attribute: 'angle',
                  value: v,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Scale',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Row(
              children: [
                IncrementalNumberFormField<double>(
                  key: Key('scale_x_field_$componentId'),
                  label: 'X',
                  initialValue: attributes.scaleX,
                  onChanged: (v) {
                    Repository.setPositionComponentAttribute(
                      id: componentId,
                      attribute: 'scaleX',
                      value: v,
                    );
                  },
                ),
                const SizedBox(width: 8),
                IncrementalNumberFormField<double>(
                  key: Key('scale_y_field_$componentId'),
                  label: 'Y',
                  initialValue: attributes.scaleY,
                  onChanged: (v) {
                    Repository.setPositionComponentAttribute(
                      id: componentId,
                      attribute: 'scaleY',
                      value: v,
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
