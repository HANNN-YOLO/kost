import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseCadanganApi {
  static get masterurl => dotenv.env['MASTER_URL2'] ?? "";
  static get apipublic => dotenv.env['API_PUBLIC2'] ?? "";
  static get apisecret => dotenv.env['API_SECRET2'] ?? "";
}
