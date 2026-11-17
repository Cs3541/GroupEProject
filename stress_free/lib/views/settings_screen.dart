import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../widgets/auth_service_scope.dart';
import '../views/homescreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 152, 175),
        title: const Text('Settings'),
        centerTitle: true,
        leadingWidth: 100, 
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Home', style: TextStyle(color: Colors.black),),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            iconColor: Colors.black
          ),
        ),
      ),
      body: const Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('Journal Settings'),
            ),
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('Notification Settings'),
            ),
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('Alarm Settings'),
            ),
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('... Settings'),
            ),
            SizedBox(height: 24),
            _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton();

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  AuthPresenter? _presenter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _presenter ??= AuthPresenter(AuthServiceScope.of(context));
  }

  @override
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presenter = _presenter!;
    return ListenableBuilder(
      listenable: presenter,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: presenter.busy ? null : () => presenter.logout(),
            icon: presenter.busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      semanticsLabel: 'Logging out',
                    ),
                  )
                : const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
          if (presenter.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  presenter.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
