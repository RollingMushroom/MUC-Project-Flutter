import 'package:flutter/material.dart';
import '../JsonModels/users.dart';
import '../services/restaurantpack.dart';

class ProfileEditPage extends StatefulWidget {
  final Users user;
  final String name;
  final String email;
  final String phone;
  final String username;
  final String password;

  const ProfileEditPage(
      {required this.user,
      super.key,
      required this.name,
      required this.email,
      required this.phone,
      required this.username,
      required this.password});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  final db = DatabaseHelper();
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  bool _isEditingPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(
        text: widget.user.phone != null ? widget.user.phone.toString() : '');
    _passwordController = TextEditingController(text: widget.user.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      Users updatedUser = Users(
        usrId: widget.user.usrId,
        name: _nameController.text,
        email: _emailController.text,
        phone: int.tryParse(_phoneController.text),
        username: widget.user.username,
        password: _passwordController.text,
      );
      await db.updateUser(updatedUser);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context, updatedUser);
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required Function() onEdit,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(255, 123, 70, 66).withOpacity(.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Enter your $label',
                            border: InputBorder.none,
                          ),
                          obscureText: obscureText,
                          keyboardType: keyboardType,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your $label';
                            }
                            if (label == 'Email' &&
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            if (label == 'Phone' &&
                                !RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            if (label == 'Password' && value.length < 3) {
                              return 'Password must be at least 3 characters';
                            }
                            return null;
                          },
                          style: const TextStyle(fontSize: 20),
                        )
                      : Text(
                          controller.text,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
                IconButton(
                  icon: Icon(isEditing ? Icons.check : Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/avatar.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  label: 'Name',
                  controller: _nameController,
                  isEditing: _isEditingName,
                  onEdit: () {
                    setState(() {
                      if (_isEditingName) {
                        if (_formKey.currentState!.validate()) {
                          _isEditingName = !_isEditingName;
                        }
                      } else {
                        _isEditingName = !_isEditingName;
                      }
                    });
                  },
                ),
                _buildEditableField(
                  label: 'Email',
                  controller: _emailController,
                  isEditing: _isEditingEmail,
                  onEdit: () {
                    setState(() {
                      if (_isEditingEmail) {
                        if (_formKey.currentState!.validate()) {
                          _isEditingEmail = !_isEditingEmail;
                        }
                      } else {
                        _isEditingEmail = !_isEditingEmail;
                      }
                    });
                  },
                ),
                _buildEditableField(
                  label: 'Phone',
                  controller: _phoneController,
                  isEditing: _isEditingPhone,
                  onEdit: () {
                    setState(() {
                      if (_isEditingPhone) {
                        if (_formKey.currentState!.validate()) {
                          _isEditingPhone = !_isEditingPhone;
                        }
                      } else {
                        _isEditingPhone = !_isEditingPhone;
                      }
                    });
                  },
                  keyboardType: TextInputType.number,
                ),
                _buildEditableField(
                  label: 'Password',
                  controller: _passwordController,
                  isEditing: _isEditingPassword,
                  onEdit: () {
                    setState(() {
                      if (_isEditingPassword) {
                        if (_formKey.currentState!.validate()) {
                          _isEditingPassword = !_isEditingPassword;
                        }
                      } else {
                        _isEditingPassword = !_isEditingPassword;
                      }
                    });
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 123, 70, 66)
                            .withOpacity(.5), // Background color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update Profile'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
