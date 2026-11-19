import 'child_records.dart';
import 'cars_models.dart';

/// Saved CARS questionnaires, per child.
final carsStore = ChildRecords<CarsResult>(
  keyPrefix: 'mazid_cars_child_',
  fromJson: CarsResult.fromJson,
  toJson: (result) => result.toJson(),
);
