
import 'package:vertex_ui/src/services/client_stubs/api.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(Login login);

  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  var api = AuthApi();

  LoginScreenPresenter(this._view);

  doLogin(Login login) {
    api.login(login: login).then((login) {
      _view.onLoginSuccess(login);
    }).catchError((Object error) {
      _view.onLoginError(error.toString());
    });
  } //End doLogin function
} //End class
