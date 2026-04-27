enum MedicationStatus { taken, soon, missed }

class Medication {
  final String name;
  final String id;
  //final String dose;
  final String? dosage;
  final String time;
  MedicationStatus status;
Map<String, dynamic> toJson() => {
  "name": name,
  "dosage": dosage,
  "time": time,
  "status": status.toString().split('.').last,
};

static Medication fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json["name"],
      id:json["id"],
      dosage: json["dosage"],
      time: json["time"],
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => MedicationStatus.soon,
      ),
    );
  }

  Medication({
    required this.name,
    //required this.dose,
    required this.id,
    required this.dosage,
    required this.time,
    required this.status,
  });

  // static List<Medication> getMockMedications() {
  //   return [
  //     Medication(name: 'ليفيتيراسيتام', dosage: '500 ملغ', time: '08:00', status: MedicationStatus.soon),
  //     Medication(name: 'لاموتريجين', dosage: '100 ملغ', time: '14:00', status: MedicationStatus.taken),
  //     Medication(name: 'ليفيتيراسيتام', dosage: '500 ملغ', time: '20:00', status: MedicationStatus.soon),
  //   ];
  // }
}