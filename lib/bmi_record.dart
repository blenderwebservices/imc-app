class BMIRecord {
  final int? id;
  final double weight;
  final double height;
  final double bmi;
  final String comment;
  final DateTime date;

  BMIRecord({
    this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory BMIRecord.fromMap(Map<String, dynamic> map) {
    return BMIRecord(
      id: map['id'],
      weight: map['weight'],
      height: map['height'],
      bmi: map['bmi'],
      comment: map['comment'],
      date: DateTime.parse(map['date']),
    );
  }
}
