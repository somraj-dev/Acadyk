import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remoteDataSource: ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncState<AuthUserEntity?>>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AsyncState<AuthUserEntity?>> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AsyncState()) {
    checkSavedAuth();
  }

  Future<void> checkSavedAuth() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        state = AsyncState(status: Status.success, data: user);
      } else {
        state = const AsyncState(status: Status.empty, data: null);
      }
    } catch (_) {
      state = const AsyncState(status: Status.empty, data: null);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: Status.loading);
    try {
      final user = await loginUseCase(LoginParams(email: email, password: password));
      state = AsyncState(status: Status.success, data: user);
      return true;
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: null);
      return false;
    }
  }

  Future<bool> register(String email, String password, String? fullName) async {
    state = state.copyWith(status: Status.loading);
    try {
      final user = await registerUseCase(RegisterParams(email: email, password: password, fullName: fullName));
      state = AsyncState(status: Status.success, data: user);
      return true;
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: null);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: Status.loading);
    try {
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        state = AsyncState(status: Status.success, data: user);
        return true;
      }
      state = const AsyncState(status: Status.empty, data: null);
      return false;
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: null);
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await authRepository.sendPasswordReset(email);
  }

  Future<void> logout() async {
    await logoutUseCase(const NoParams());
    state = const AsyncState(status: Status.empty, data: null);
  }

  Future<void> deleteAccount() async {
    await authRepository.deleteAccount();
    state = const AsyncState(status: Status.empty, data: null);
  }
}
