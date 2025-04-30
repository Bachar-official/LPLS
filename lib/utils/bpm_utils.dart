abstract class BpmUtils {
  static int bpmToMillis(int bpm, int beats) => (60000 / (bpm * beats)).round();
  static int millisToBpm(int millis, int beats) => (60000 / (millis * beats)).round();
}