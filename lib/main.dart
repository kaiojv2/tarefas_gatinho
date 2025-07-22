import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import 'animated_background.dart';
import 'widgets/heart_particle.dart';
import 'dialog_utils.dart'; // Função mostrarFolhaDialog

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gatinho Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F4E3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        fontFamily: 'ComicNeue',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  final String title;
  final String description;
  bool isDone;

  Task({required this.title, required this.description, this.isDone = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'isDone': isDone,
  };

  static Task fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    description: json['description'],
    isDone: json['isDone'],
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [];
  final AudioPlayer player = AudioPlayer();
  final List<Widget> hearts = [];
  SharedPreferences? prefs;
  rive.Artboard? _riveArtboard;

  double progress = 0.0;
  int tarefasConcluidas = 0;

  @override
  void initState() {
    super.initState();
    _initRive();
    _loadTasks();
  }

  Future<void> _initRive() async {
    final data = await rootBundle.load('assets/cat_idle.riv');
    final file = rive.RiveFile.import(data);
    final artboard = file.mainArtboard;
    final controller = rive.StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) artboard.addController(controller);
    setState(() => _riveArtboard = artboard);
  }

  Future<void> _loadTasks() async {
    prefs = await SharedPreferences.getInstance();
    final saved = prefs!.getStringList('tasks') ?? [];
    setState(() {
      tasks.clear();
      tasks.addAll(saved.map((t) => Task.fromJson(jsonDecode(t))));
      _updateProgress();
    });
  }

  void _saveTasks() {
    final list = tasks.map((t) => jsonEncode(t.toJson())).toList();
    prefs?.setStringList('tasks', list);
    _updateProgress();
  }

  void _updateProgress() {
    final total = tasks.length;
    final done = tasks.where((t) => t.isDone).length;
    setState(() {
      tarefasConcluidas = done;
      progress = total == 0 ? 0.0 : done / total;
    });
    if (progress >= 1.0 && total > 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('🐱 Gatinho Satisfeito!'),
            content: const Text(
              'Parabéns! Você concluiu todas as tarefas e deixou o gatinho muito feliz! 💖',
            ),
            actions: [
              TextButton(
                child: const Text('Fechar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      });
    }
  }

  void _playSound() async {
    await player.play(AssetSource('audio/meow.mp3'));
  }

  void _addHeart() {
    final heart = HeartParticle(
      baseLeft: 150,
      baseBottom: 180,
      onComplete: () {
        setState(() {
          hearts.removeAt(0);
        });
      },
    );
    setState(() => hearts.add(heart));
  }

  void _addTask(String title, String description) {
    if (description.trim().isEmpty) return;
    setState(() {
      tasks.add(Task(title: title, description: description));
      _saveTasks();
    });
  }

  void _showAddTaskModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🐱 Adicionar nova tarefa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Título da tarefa (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.pinkAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.pinkAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Descrição da tarefa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.pinkAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.pinkAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Adicionar'),
                    onPressed: () {
                      Navigator.pop(context);
                      final titleText = titleController.text.trim().isEmpty
                          ? 'Tarefa'
                          : '🐱 ${titleController.text.trim()}';
                      _addTask(titleText, descController.text.trim());
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleTaskAndAnimate(int index, bool? value) {
    if (value == null) return;
    if (value) {
      // Play sound, add hearts etc
      _playSound();
      _addHeart();
    }
    setState(() {
      tasks[index].isDone = value;
      _saveTasks();
    });
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.favorite, size: 30),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: AnimatedBackground(height: availableHeight)),
            Column(
              children: [
                SizedBox(
                  height: 220,
                  child: _riveArtboard == null
                      ? const SizedBox.shrink()
                      : rive.Rive(artboard: _riveArtboard!),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.pinkAccent,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.pets, size: 64, color: Colors.black26),
                              SizedBox(height: 8),
                              Text(
                                'Nenhuma tarefa ainda!\nClique no coração para adicionar :)',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];

                            return AnimatedRemoveTaskCard(
                              key: ValueKey(task.title + task.description),
                              task: task,
                              onChanged: (value) {
                                if (value == true) {
                                  // Marcar e animar remoção
                                  _toggleTaskAndAnimate(index, value);
                                } else {
                                  // Só desmarcar
                                  setState(() {
                                    tasks[index].isDone = false;
                                    _saveTasks();
                                  });
                                }
                              },
                              onRemove: () {
                                _removeTask(index);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            ...hearts,
          ],
        ),
      ),
    );
  }
}

/// Widget animado que faz fade + scale antes de remover o card da lista
class AnimatedRemoveTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onRemove;
  final ValueChanged<bool?> onChanged;

  const AnimatedRemoveTaskCard({
    super.key,
    required this.task,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<AnimatedRemoveTaskCard> createState() => _AnimatedRemoveTaskCardState();
}

class _AnimatedRemoveTaskCardState extends State<AnimatedRemoveTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRemove();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCheckboxChanged(bool? value) {
    if (value == true && !_isRemoving) {
      _isRemoving = true;
      _controller.forward();
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: () {
            mostrarFolhaDialog(
              context,
              titulo: widget.task.title,
              texto: widget.task.description,
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  widget.task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: widget.task.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  widget.task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: widget.task.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    fontSize: 14,
                  ),
                ),
                leading: Checkbox(
                  value: widget.task.isDone,
                  onChanged: _handleCheckboxChanged,
                  activeColor: Colors.white,
                  checkColor: Colors.pinkAccent,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () => widget.onRemove(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
