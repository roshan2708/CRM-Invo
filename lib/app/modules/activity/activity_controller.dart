import 'package:get/get.dart';
import '../../data/dummy_data.dart';
import '../../data/models/activity_model.dart';

class ActivityController extends GetxController {
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    activities.assignAll(DummyData.activities);
  }

  void addActivity(ActivityModel activity) {
    activities.insert(0, activity);
  }

  void toggleDone(String id) {
    final idx = activities.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final a = activities[idx];
      activities[idx] = a.copyWith(isDone: !a.isDone);
    }
  }

  void deleteActivity(String id) {
    activities.removeWhere((a) => a.id == id);
  }

  List<ActivityModel> activitiesForLead(String leadId) =>
      activities.where((a) => a.leadId == leadId).toList();

  List<ActivityModel> get pendingActivities =>
      activities.where((a) => !a.isDone).toList();

  int get pendingCount => pendingActivities.length;
}
