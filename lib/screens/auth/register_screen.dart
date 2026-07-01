import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final auth = context.read<AuthProvider>();
    final success = await auth.register(_email, _password);
    
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
                onSaved: (val) => _email = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Password is required';
                  if (val.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
                onSaved: (val) => _password = val!,
              ),
              const SizedBox(height: 24),
              if (auth.isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
