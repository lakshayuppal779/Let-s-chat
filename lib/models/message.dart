class Message {
  Message({
    required this.toID,
    required this.msg,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromID,
    required this.isVanishMode,
  });

  late final String toID;
  late final String msg;
  late final String read;
  late final Type type;
  late final String sent;
  late final String fromID;
  late final bool isVanishMode;

  Message.fromJson(Map<String, dynamic> json) {
    toID = json['toID'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = _parseType(json['type'].toString()); // Parse the type
    sent = json['sent'].toString(); // Remove extra space after 'sent'
    fromID = json['fromID'].toString();
    isVanishMode = json['isVanishMode'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toID'] = toID;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name; // Use type name instead of enum value
    data['sent'] = sent; // Remove extra space after 'sent'
    data['fromID'] = fromID;
    data['isVanishMode'] = isVanishMode;
    return data;
  }

  static Type _parseType(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return Type.text;
      case 'image':
        return Type.image;
      case 'pdf': // Add case for PDF
        return Type.pdf;
      default:
        throw ArgumentError('Invalid message type: $value');
    }
  }
}

enum Type { text, image, pdf } // Add pdf type to enum
