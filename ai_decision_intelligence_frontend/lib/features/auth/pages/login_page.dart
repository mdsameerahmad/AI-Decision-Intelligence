import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {

final emailController = TextEditingController();
final passwordController = TextEditingController();

LoginPage({super.key});

@override
Widget build(BuildContext context) {

```
return Scaffold(
  appBar: AppBar(
    title: const Text("AI Decision Intelligence Login"),
  ),

  body: BlocConsumer<AuthBloc, AuthState>(

    listener: (context, state) {

      if (state is AuthSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );
      }

      if (state is AuthFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }

    },

    builder: (context, state) {

      if (state is AuthLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {

                context.read<AuthBloc>().add(
                  LoginEvent(
                    emailController.text,
                    passwordController.text,
                  ),
                );

              },
              child: const Text("Login"),
            ),

          ],
        ),
      );
    },
  ),
);
```

}
}
