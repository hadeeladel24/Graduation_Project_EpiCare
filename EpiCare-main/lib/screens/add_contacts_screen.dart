import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'package:easy_localization/easy_localization.dart';
class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("add_new_contact".tr()),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "name".tr(),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "enter_name".tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationController,
                decoration:  InputDecoration(
                  labelText: "relationship".tr(),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "enter_relationship".tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "phone".tr(),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "enter_phone".tr() : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Color.fromARGB(255, 217, 219, 224),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newContact = Contact(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: _nameController.text,
                      relation: _relationController.text,
                      phone: _phoneController.text,
                    );
                    Navigator.pop(context, newContact);
                  }
                },
                icon: const Icon(Icons.save_rounded),
                label:  Text("save".tr(), style: TextStyle(fontWeight: FontWeight.bold,
                color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
