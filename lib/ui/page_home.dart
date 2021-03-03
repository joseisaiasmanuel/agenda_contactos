import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agenda_contactos/helpers/contact_helper.dart';
import 'package:agenda_contactos/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

// função para carregar todos os contactos
  @override
  void initState() {
    super.initState();
    _getAllContact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contactos"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<orderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<orderOptions>>[
              const PopupMenuItem<orderOptions>(
                child: Text("Ordenar de A-Z"),
                value: orderOptions.orderaz,
              ),
              const PopupMenuItem(
                child: Text("ordenar de Z-A"),
                value: orderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  // criação do nosso card
  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("imagens/person.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  // para alinhar para esquerda
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      // funcão para que o car abre a tela para editar
      onTap: () {
        _showOption(context, index);
      },
    );
  }

  _showOption(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "Ligar",
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    ),
                    onPressed: () {
                      launch("tel:${contacts[index].phone}");
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "Editar",
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: contacts[index]);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "Excluir",
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    ),
                    onPressed: () {
                      setState(() {
                        helper.deleteContact(contacts[index].id);
                        Navigator.pop(context);
                        contacts.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        helper.updateContact(recContact);
        _getAllContact();
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContact();
    }
  }

  void _getAllContact() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  // metodo para ordenar a lista
  void _orderList(orderOptions result) {
    switch (result) {
      case orderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        break;

      case orderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
