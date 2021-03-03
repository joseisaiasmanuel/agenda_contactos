import 'package:agenda_contactos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum orderOptions { orderaz, orderza }

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameContoller = TextEditingController();
  final _emailContoller = TextEditingController();
  final _phoneContoller = TextEditingController();
  final _nameFocus = FocusNode();
  bool userEdit = false;

  Contact _editContact;
  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.froMap(widget.contact.toMap());
      _nameContoller.text = _editContact.name;
      _emailContoller.text = _editContact.email;
      _phoneContoller.text = _editContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editContact.name ?? "Novo contacto"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.save,
            ),
            backgroundColor: Colors.red,
            onPressed: () {
              // validação de formulario
              if (_editContact.name != null && _editContact.name.isNotEmpty) {
                Navigator.pop(context, _editContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            }),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editContact.img != null
                              ? FileImage(File(_editContact.img))
                              : AssetImage("imagens/person.png"))),
                ),
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.gallery)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      _editContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameContoller,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: ("name")),
                onChanged: (text) {
                  userEdit = true;
                  setState(() {
                    _editContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailContoller,
                decoration: InputDecoration(labelText: ("email")),
                onChanged: (text) {
                  userEdit = true;
                  _editContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneContoller,
                decoration: InputDecoration(labelText: ("phone")),
                onChanged: (text) {
                  userEdit = true;
                  _editContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }

  // usuar a caixa de dialog se usuario editou o teste
  Future<bool> _requestPop() {
    if (userEdit) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text("se sair as alteraçãoes serão pertidas."),
              actions: <Widget>[
                FlatButton(
                    child: Text("cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                FlatButton(
                  child: Text("sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
