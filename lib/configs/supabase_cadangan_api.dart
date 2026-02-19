import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseCadanganApi {
  static get masterurl => dotenv.env['MASTER_URL'] ?? "";
  static get apipublic => dotenv.env['API_PUBLIC'] ?? "";
  static get apisecret => dotenv.env['API_SECRET'] ?? "";
}
