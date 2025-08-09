import 'package:flutter/material.dart';
import '../JsonModels/admin.dart';
import '../JsonModels/signup.dart';
import '../JsonModels/users.dart';
import '../Menu/menudetailspage.dart';
import '../admin/user_list_view.dart';
import '../services/restaurantpack.dart';

import '../Menu/menudetailspageguest.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool isVisible = false;
  bool isLoginTrue = false;
  final db = DatabaseHelper();

  login() async {
    var user = await db.login(Users(
      username: username.text,
      password: password.text,
      name: '',
      email: '',
      phone: null,
    ));
    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuDetailsPage(
            user: user,
            name: user.name, // Pass user data to MenuDetailsPage
            email: user.email,
            phone: user.phone != null ? user.phone.toString() : '',
            username: user.username,
            password: user.password,
            usrId: user.usrId ??
                0, // Assuming 0 as the default value for null usrId
          ),
        ),
      );
    } else {
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  adminLogin() async {
    var response = await db.adminLogin(Admin(
      username: username.text,
      password: password.text,
    ));
    if (response == true) {
      isLoginTrue = true;
      if (!mounted) return;
      isLoginTrue = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserListView(),
        ),
      );
    } else {
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/login.jpg",
                    width: 210,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 123, 70, 66)
                          .withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: username,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Username",
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 123, 70, 66)
                          .withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 123, 70, 66),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          bool isAdmin =
                              await db.isAdmin(username.text, password.text);
                          if (isAdmin) {
                            adminLogin();
                          } else {
                            login();
                          }
                        }
                      },
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()),
                          );
                        },
                        child: const Text("SIGN UP"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("or continue as"),
                      TextButton(
                        onPressed: () {
                          // Define a placeholder user object
                          final Users guestUser = Users(
                            username: 'Guest',
                            password: '',
                            name: '',
                            email: '',
                            phone: null,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuDetailsPageguest(
                                user: guestUser,
                                name: guestUser.name,
                                email: guestUser.email,
                                phone: guestUser.phone != null
                                    ? guestUser.phone.toString()
                                    : '',
                                username: guestUser.username,
                                password: guestUser.password,
                              ),
                            ),
                          );
                        },
                        child: const Text("GUESTS"),
                      ),
                    ],
                  ),
                  isLoginTrue
                      ? const Text(
                          "Username or password is incorrect",
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
