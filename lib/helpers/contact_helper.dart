import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _intance = ContactHelper.internal();
  factory ContactHelper() => _intance;
  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    // inicializar os dados
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    // local do banco de dados
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsnew.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,$nameColumn TEXT,$emailColumn TEXT,$phoneColumn TEXT,$imgColumn TEXT)");
    });
  }

  // salvar o contacto
  Future<Contact> saveContact(Contact contact) async {
    // obter o banco de dados
    Database dbContact = await db;
    await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  // obter os dados de um contacto
  Future<Contact> getContac(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn=?",
        whereArgs: [id]);
    if (maps.length > 1) {
      return Contact.froMap(maps.first);
    } else {
      return null;
    }
  }

  // apagar o contacto
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn=?", whereArgs: [id]);
  }

  // função para actulizar um contacto
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn=?", whereArgs: [contact.id]);
  }

  // função para obter todos os nossos contactos
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.froMap(m));
    }
    return listContact;
  }

  // função para obter todos os numeros de contactos da nossa lista
  Future<int> getNamber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }
  // função para fechar a conexão

  Future closeDb() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;
  Contact();

  Contact.froMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id:$id,name:$name,email:$email,phone:$phone,img:$img)";
  }
}
