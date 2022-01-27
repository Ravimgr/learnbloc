import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_login_bloc/login/models/models.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationRepository _repository;

  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _repository = authenticationRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onLoginUsernameChanged);
    on<LoginPasswordChanged>(_onLoginPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  void _onLoginUsernameChanged(
      LoginUsernameChanged event, Emitter<LoginState> emit) {
    final username = Username.dirty(event.username);
    emit(state.copyWith(
        username: username,
        status: Formz.validate([state.password, username])));
  }

  void _onLoginPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
        password: password,
        status: Formz.validate([password, state.username])));
  }

  void _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        await _repository.logIn(
          username: state.username.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (_) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }
}
