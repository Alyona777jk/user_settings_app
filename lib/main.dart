import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/preferences_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PreferencesManager _prefs = PreferencesManager();

  ThemeMode _getThemeMode(String themeStr) {
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentTheme = _prefs.getTheme();
    return MaterialApp(
      title: 'Менеджер Налаштувань',
      debugShowCheckedModeBanner: false,
      themeMode: _getThemeMode(currentTheme),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: SettingsScreen(onSettingsChanged: () {
        setState(() {});
      }),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final VoidCallback onSettingsChanged;

  const SettingsScreen({super.key, required this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesManager _prefs = PreferencesManager();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _categoryController;

  late int _age;
  late String _regDate;
  late String _theme;
  late double _fontSize;
  late String _language;
  late bool _compactMode;

  late bool _push;
  late bool _emailNotif;
  late bool _sound;
  late int _frequency;

  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _categoryController = TextEditingController();
  }

  void _loadSettings() {
    _nameController = TextEditingController(text: _prefs.getName());
    _emailController = TextEditingController(text: _prefs.getEmail());
    _age = _prefs.getAge();
    _regDate = _prefs.getRegDate();

    _theme = _prefs.getTheme();
    _fontSize = _prefs.getFontSize();
    _language = _prefs.getLanguage();
    _compactMode = _prefs.getCompactMode();

    _push = _prefs.getPush();
    _emailNotif = _prefs.getEmailNotif();
    _sound = _prefs.getSound();
    _frequency = _prefs.getFrequency();

    _categories = List.from(_prefs.getCategories());
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _notifyAndSave() {
    widget.onSettingsChanged();
    _showSnackBar('Налаштування автозбережено');
  }

  void _resetToDefaults() async {
    await _prefs.clearAll();
    setState(() {
      _loadSettings();
    });
    widget.onSettingsChanged();
    _showSnackBar('Налаштування скинуто до типових');
  }

  void _exportJson() {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(_prefs.exportToJson());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Експорт налаштувань (JSON)'),
        content: SingleChildScrollView(
          child: SelectableText(jsonStr, style: const TextStyle(fontFamily: 'monospace')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування користувача'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Експорт JSON',
            onPressed: _exportJson,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Скинути',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(_compactMode ? 8.0 : 16.0),
        children: [
          _buildSectionHeader('Профіль'),
          TextField(
            controller: _nameController,
            style: TextStyle(fontSize: _fontSize),
            decoration: const InputDecoration(labelText: 'Ім\'я'),
            onChanged: (val) async {
              await _prefs.saveName(val);
              _notifyAndSave();
            },
          ),
          TextField(
            controller: _emailController,
            style: TextStyle(fontSize: _fontSize),
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (val) async {
              await _prefs.saveEmail(val);
              _notifyAndSave();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Вік: $_age', style: TextStyle(fontSize: _fontSize)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _age > 1
                        ? () async {
                            setState(() => _age--);
                            await _prefs.saveAge(_age);
                            _notifyAndSave();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      setState(() => _age++);
                      await _prefs.saveAge(_age);
                      _notifyAndSave();
                    },
                  ),
                ],
              )
            ],
          ),
          Text('Дата реєстрації: $_regDate', style: TextStyle(fontSize: _fontSize, color: Colors.grey)),
          const Divider(),

          _buildSectionHeader('Вигляд'),
          const Text('Тема:'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'light', label: Text('Світла'), icon: Icon(Icons.light_mode)),
              ButtonSegment(value: 'dark', label: Text('Темна'), icon: Icon(Icons.dark_mode)),
              ButtonSegment(value: 'system', label: Text('Система'), icon: Icon(Icons.settings_system_daydream)),
            ],
            selected: {_theme},
            onSelectionChanged: (Set<String> newSelection) async {
              setState(() => _theme = newSelection.first);
              await _prefs.saveTheme(_theme);
              _notifyAndSave();
            },
          ),
          const SizedBox(height: 12),
          Text('Розмір шрифту: ${_fontSize.round()}'),
          Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: _fontSize.round().toString(),
            onChanged: (val) async {
              setState(() => _fontSize = val);
              await _prefs.saveFontSize(val);
              _notifyAndSave();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Мова:'),
              DropdownButton<String>(
                value: _language,
                items: ['Українська', 'English', 'Español']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (val) async {
                  if (val != null) {
                    setState(() => _language = val);
                    await _prefs.saveLanguage(val);
                    _notifyAndSave();
                  }
                },
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Компактний режим'),
            value: _compactMode,
            onChanged: (val) async {
              setState(() => _compactMode = val);
              await _prefs.saveCompactMode(val);
              _notifyAndSave();
            },
          ),
          const Divider(),

          _buildSectionHeader('Сповіщення'),
          SwitchListTile(
            title: const Text('Push-сповіщення'),
            value: _push,
            onChanged: (val) async {
              setState(() => _push = val);
              await _prefs.savePush(val);
              _notifyAndSave();
            },
          ),
          SwitchListTile(
            title: const Text('Email-сповіщення'),
            value: _emailNotif,
            onChanged: (val) async {
              setState(() => _emailNotif = val);
              await _prefs.saveEmailNotif(val);
              _notifyAndSave();
            },
          ),
          SwitchListTile(
            title: const Text('Звукові ефекти'),
            value: _sound,
            onChanged: (val) async {
              setState(() => _sound = val);
              await _prefs.saveSound(val);
              _notifyAndSave();
            },
          ),
          ListTile(
            title: const Text('Частота нагадувань (дні)'),
            trailing: DropdownButton<int>(
              value: _frequency,
              items: [1, 3, 7, 30]
                  .map((f) => DropdownMenuItem(value: f, child: Text('$f дн.')))
                  .toList(),
              onChanged: (val) async {
                if (val != null) {
                  setState(() => _frequency = val);
                  await _prefs.saveFrequency(val);
                  _notifyAndSave();
                }
              },
            ),
          ),
          const Divider(),

          _buildSectionHeader('Улюблені категорії'),
          Wrap(
            spacing: 8.0,
            children: _categories
                .map((cat) => Chip(
                      label: Text(cat),
                      onDeleted: () async {
                        setState(() => _categories.remove(cat));
                        await _prefs.saveCategories(_categories);
                        _notifyAndSave();
                      },
                    ))
                .toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    hintText: 'Нова категорія',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () async {
                  if (_categoryController.text.trim().isNotEmpty) {
                    setState(() {
                      _categories.add(_categoryController.text.trim());
                      _categoryController.clear();
                    });
                    await _prefs.saveCategories(_categories);
                    _notifyAndSave();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: _fontSize + 4,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
