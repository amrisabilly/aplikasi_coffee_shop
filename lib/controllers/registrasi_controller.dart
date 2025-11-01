import '../fetch_data/user/registrasi.dart';
import '../models/user/registrasi-model.dart';

class RegistrasiController {
  Future<bool> registerUser(Registrasi registrasi) async {
    return await createUser(registrasi);
  }
}
