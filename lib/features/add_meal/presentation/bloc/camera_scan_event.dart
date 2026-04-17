part of 'camera_scan_bloc.dart';

abstract class CameraScanEvent extends Equatable {
  const CameraScanEvent();
}

class AnalyzeImageEvent extends CameraScanEvent {
  final Uint8List imageBytes;

  const AnalyzeImageEvent({required this.imageBytes});

  @override
  List<Object?> get props => [imageBytes];
}

class ResetCameraScanEvent extends CameraScanEvent {
  const ResetCameraScanEvent();

  @override
  List<Object?> get props => [];
}

