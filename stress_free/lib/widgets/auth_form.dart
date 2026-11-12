import 'package:flutter/material.dart';

import '../models/auth_service.dart';
import '../presenters/auth_presenter.dart';

/// Shared form rendering; all validation and authentication belong to the presenter.
class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.authService,
    required this.signingUp,
    required this.onSwitch,
  });

  final AuthService authService;
  final bool signingUp;
  final VoidCallback onSwitch;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late final AuthPresenter _presenter;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void initState() {
    super.initState();
    _presenter = AuthPresenter(widget.authService);
  }

  @override
  void dispose() {
    _presenter.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_presenter.busy || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (widget.signingUp) {
      await _presenter.signup(
        email: _email.text,
        password: _password.text,
        confirmation: _confirmation.text,
      );
    } else {
      await _presenter.login(email: _email.text, password: _password.text);
    }
    // The authentication stream, rather than this form, controls access to HomePage.
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _presenter,
    builder: (context, _) {
      final busy = _presenter.busy;
      return PopScope(
        canPop: !busy,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.signingUp ? 'Sign up' : 'Log in')),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.signingUp
                                ? 'Create your account'
                                : 'Welcome to Stress Free',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            key: const Key('auth-email'),
                            controller: _email,
                            enabled: !busy,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: _presenter.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('auth-password'),
                            controller: _password,
                            enabled: !busy,
                            obscureText: _hidePassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: [
                              widget.signingUp
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            textInputAction: widget.signingUp
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onFieldSubmitted: widget.signingUp
                                ? null
                                : (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              helperText: widget.signingUp
                                  ? 'At least 6 characters'
                                  : null,
                              suffixIcon: IconButton(
                                tooltip: _hidePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: busy
                                    ? null
                                    : () => setState(
                                        () => _hidePassword = !_hidePassword,
                                      ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (value) => _presenter.validatePassword(
                              value,
                              signingUp: widget.signingUp,
                            ),
                          ),
                          if (widget.signingUp) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('auth-confirmation'),
                              controller: _confirmation,
                              enabled: !busy,
                              obscureText: _hideConfirmation,
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: const [AutofillHints.newPassword],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
                                suffixIcon: IconButton(
                                  tooltip: _hideConfirmation
                                      ? 'Show password confirmation'
                                      : 'Hide password confirmation',
                                  onPressed: busy
                                      ? null
                                      : () => setState(
                                          () => _hideConfirmation =
                                              !_hideConfirmation,
                                        ),
                                  icon: Icon(
                                    _hideConfirmation
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              validator: (value) => _presenter
                                  .validateConfirmation(value, _password.text),
                            ),
                          ],
                          if (_presenter.error != null) ...[
                            const SizedBox(height: 16),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                _presenter.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (busy) ...[
                            const Center(
                              child: CircularProgressIndicator(
                                semanticsLabel: 'Authenticating',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton(
                            key: const Key('auth-submit'),
                            onPressed: busy ? null : _submit,
                            child: Text(
                              widget.signingUp ? 'Create account' : 'Log in',
                            ),
                          ),
                          TextButton(
                            key: const Key('auth-switch'),
                            onPressed: busy ? null : widget.onSwitch,
                            child: Text(
                              widget.signingUp
                                  ? 'Already have an account? Log in'
                                  : 'Create an account',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
