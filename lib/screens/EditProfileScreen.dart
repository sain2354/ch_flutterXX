// screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  bool _isNameEditable = false;
  bool _isPhoneEditable = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firebaseUser = authProvider.user;
    _emailController = TextEditingController(text: firebaseUser?.email ?? '');
    _nameController =
        TextEditingController(text: firebaseUser?.displayName ?? '');
    // Si en FirebaseAuth no está el teléfono, podrías cargarlo desde otro lugar.
    _phoneController =
        TextEditingController(text: firebaseUser?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.syncProfileOnly(
        phone: _phoneController.text,
        displayName: _nameController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );

      // Regresa a modo lectura en ambos campos
      setState(() {
        _isNameEditable = false;
        _isPhoneEditable = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool readOnly,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onEditTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // Se muestra el ícono de lápiz si se puede editar
          suffixIcon: onEditTap != null
              ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: onEditTap,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campo de correo (siempre solo lectura)
                    _buildTextField(
                      label: 'Correo Electrónico',
                      controller: _emailController,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    // Campo de nombre con lápiz para habilitar edición
                    _buildTextField(
                      label: 'Nombre Completo',
                      controller: _nameController,
                      readOnly: !_isNameEditable,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese su nombre completo';
                        }
                        return null;
                      },
                      onEditTap: () {
                        setState(() {
                          _isNameEditable = true;
                        });
                      },
                    ),
                    // Campo de teléfono con lápiz para habilitar edición
                    _buildTextField(
                      label: 'Teléfono',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: !_isPhoneEditable,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese su teléfono';
                        }
                        return null;
                      },
                      onEditTap: () {
                        setState(() {
                          _isPhoneEditable = true;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Se muestra el botón Guardar si alguno de los campos está en edición
                    if (_isNameEditable || _isPhoneEditable)
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        label: const Text('Guardar cambios'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
