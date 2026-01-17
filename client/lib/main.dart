import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String ipAddress = '10.0.2.2'; 
const String folderName = 'UAS_INVENTORY/server'; 
const String baseUrl = 'http://$ipAddress/$folderName';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apotek Vecctum',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class Item {
  final String id;
  final String name;
  final String qty;
  final String description;

  Item({required this.id, required this.name, required this.qty, required this.description});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString() ?? '0', 
      name: json['name']?.toString() ?? 'Tanpa Nama',
      qty: json['qty']?.toString() ?? '0',
      description: json['description']?.toString() ?? '-',
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      print("Login ke: $baseUrl/login.php");
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: jsonEncode({
          "username": _usernameCtrl.text,
          "password": _passwordCtrl.text,
        }),
      );

      print("Respon Login: ${response.body}"); 

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        String roleUser = data['user_data']['role']?.toString() ?? 'user';
        String namaLengkap = data['user_data']['full_name']?.toString() ?? 'User'; 
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(role: roleUser, fullName: namaLengkap),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      }
    } catch (e) {
      print("Error Login: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_pharmacy, size: 80, color: Colors.teal),
              const SizedBox(height: 10),
              const Text("APOTEK VECCTUM", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 30),
              TextField(controller: _usernameCtrl, decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 15),
              TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LOGIN"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                child: const Text("Daftar Akun Baru"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullnameCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: jsonEncode({
          "username": _usernameCtrl.text,
          "password": _passwordCtrl.text,
          "full_name": _fullnameCtrl.text,
        }),
      );
      final data = jsonDecode(response.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        if (data['success'] == true) Navigator.pop(context);
      }
    } catch (e) {
      print("Error Register: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _fullnameCtrl, decoration: const InputDecoration(labelText: "Nama Lengkap (Contoh: Radit A.F)")),
            TextField(controller: _usernameCtrl, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _register, child: const Text("DAFTAR")),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String role;
  final String fullName;

  const HomePage({super.key, required this.role, required this.fullName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> listItems = [];
  bool isLoading = true;
  String errorMessage = "";

  Future<void> _getData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/read.php'));

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) throw Exception("Data kosong");
        if (response.body.contains("<html>")) throw Exception("Error URL 404");

        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          listItems = data.map((e) => Item.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Gagal memuat data. Cek koneksi.";
      });
    }
  }

  Future<void> _deleteData(String id) async {
    try {
      await http.post(Uri.parse('$baseUrl/delete.php'), body: jsonEncode({"id": id}));
      _getData();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    bool isDokter = widget.role.toLowerCase() == 'dokter';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apotek Vecctum", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            
            Row(
              children: [
                const Icon(Icons.person, size: 14),
                const SizedBox(width: 5),
                Text("Halo, ${widget.fullName}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _getData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      
      floatingActionButton: isDokter 
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const FormPage()));
                _getData();
              },
            )
          : null,

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : listItems.isEmpty
                  ? const Center(child: Text("Data Kosong / Belum ada Obat"))
                  : ListView.builder(
                      itemCount: listItems.length,
                      itemBuilder: (context, index) {
                        final item = listItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Text(item.qty, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(item.description),
                            trailing: isDokter 
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () async {
                                            await Navigator.push(context, MaterialPageRoute(builder: (context) => FormPage(item: item)));
                                            _getData();
                                          }),
                                      IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteData(item.id)),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
}

class FormPage extends StatefulWidget {
  final Item? item;
  const FormPage({super.key, this.item});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameCtrl.text = widget.item!.name;
      _qtyCtrl.text = widget.item!.qty;
      _descCtrl.text = widget.item!.description;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final isEdit = widget.item != null;
    final url = isEdit ? '$baseUrl/update.php' : '$baseUrl/create.php';
    
    try {
      Map<String, dynamic> data = {
        "name": _nameCtrl.text,
        "qty": _qtyCtrl.text,
        "description": _descCtrl.text,
      };
      if (isEdit) data['id'] = widget.item!.id;

      final response = await http.post(Uri.parse(url), body: jsonEncode(data));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal Simpan: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? "Tambah Obat" : "Edit Obat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Nama Obat"), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Keterangan / Dosis")),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN OBAT")
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}