import '../../data/models/run_record.dart';
import '../../domain/lab_input.dart';

/// `/lab?...` prefilled with a run's conditions; missing values are left to Lab defaults.
String labLinkForRun(RunRecord r) {
  final q = <String, String>{
    'fuel': r.fuelClass,
    'mat': r.fuelName,
    'o2': LabInput.queryNumber(r.o2),
    'p': LabInput.queryNumber(r.pressureKpa),
    'g': LabInput.queryNumber(r.gravityG),
    if (r.thicknessMm != null) 'th': LabInput.queryNumber(r.thicknessMm!),
    if (r.densityKgM3 != null) 'rho': LabInput.queryNumber(r.densityKgM3!),
    if (r.flowMmS != null) 'flow': LabInput.queryNumber(r.flowMmS!),
    if (r.flowDirection != null) 'dir': r.flowDirection!,
  };
  return Uri(path: '/lab', queryParameters: q).toString();
}
