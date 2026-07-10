import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Which engine is standard for 2D gaming in Flutter?',
      'answers': ['Flame', 'Unity', 'Unreal', 'Godot'],
      'correctIdx': 0,
    },
    {
      'question': 'Which of these is NOT an incentivized ad farming behavior?',
      'answers': [
        'Autoplay loops',
        'Optional rewarded videos',
        'Fake currency generators',
        'Deceptive exit buttons'
      ],
      'correctIdx': 1,
    },
    {
      'question': 'What is the absolute visual reaction limit for humans?',
      'answers': ['10ms', '120ms', '50ms', '0ms'],
      'correctIdx': 1,
    },
    {
      'question': 'Which widget is used to render blur effects in glassmorphism?',
      'answers': ['BackdropFilter', 'Opacity', 'ColorFiltered', 'ClipRect'],
      'correctIdx': 0,
    },
    {
      'question': 'What is the primary theme color of Playrium?',
      'answers': ['#00D1FF', '#FFD166', '#6C5CE7', '#0F1117'],
      'correctIdx': 2,
    },
  ];

  int _currentQuestionIdx = 0;
  int? _selectedAnswerIdx;
  int _correctAnswers = 0;
  bool _quizFinished = false;
  bool _isClaiming = false;

  void _submitAnswer(int idx) {
    if (_selectedAnswerIdx != null) return; // Answer already selected

    setState(() {
      _selectedAnswerIdx = idx;
      if (idx == _questions[_currentQuestionIdx]['correctIdx']) {
        _correctAnswers++;
      }
    });

    // Advance to next question after 1.2 seconds delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        if (_currentQuestionIdx < _questions.length - 1) {
          _currentQuestionIdx++;
          _selectedAnswerIdx = null;
        } else {
          _quizFinished = true;
          _claimQuizRewards();
        }
      });
    });
  }

  void _claimQuizRewards() async {
    setState(() {
      _isClaiming = true;
    });

    final percentage = (_correctAnswers / _questions.length) * 100;
    final notifier = ref.read(userProvider.notifier);

    // Call Vercel API endpoint tasks claiming
    bool success = await notifier.claimTaskReward('take_quiz');
    
    if (percentage >= 80) {
      await notifier.claimTaskReward('quiz_80_percent', {
        'scorePercentage': percentage,
      });
    }

    if (mounted) {
      setState(() {
        _isClaiming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? "🎉 Quiz completed! Score: ${percentage.toStringAsFixed(0)}%. Reward credited." 
              : "Completed! Balance updated."),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trivia Quest"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.darkBgColor, const Color(0xFF13141F)]
                : [AppTheme.lightBgColor, const Color(0xFFE4E7ED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GlassCard(
              blur: 16,
              opacity: 0.08,
              child: _quizFinished
                  ? _buildFinishedWidget()
                  : _buildQuestionWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget() {
    final q = _questions[_currentQuestionIdx];
    final progress = (_currentQuestionIdx + 1) / _questions.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress indicators
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "QUESTION ${_currentQuestionIdx + 1}/${_questions.length}",
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            Text(
              "Score: $_correctAnswers",
              style: const TextStyle(color: AppTheme.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
            )
          ],
        ),
        const SizedBox(height: 24),
        
        // Question Text
        Text(
          q['question'],
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Answers list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: q['answers'].length,
          itemBuilder: (context, idx) {
            Color btnColor = AppTheme.darkSurfaceColor;
            BorderSide border = BorderSide(color: Colors.white.withValues(alpha: 0.08));

            if (_selectedAnswerIdx != null) {
              if (idx == q['correctIdx']) {
                btnColor = Colors.green.shade800;
                border = const BorderSide(color: Colors.greenAccent, width: 2);
              } else if (idx == _selectedAnswerIdx) {
                btnColor = Colors.red.shade800;
                border = const BorderSide(color: Colors.redAccent, width: 2);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: border,
                  ),
                  elevation: 0,
                ),
                onPressed: () => _submitAnswer(idx),
                child: Text(
                  q['answers'][idx],
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinishedWidget() {
    final percentage = (_correctAnswers / _questions.length) * 100;
    final isHighScorer = percentage >= 80;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.stars, size: 68, color: AppTheme.accentColor),
        const SizedBox(height: 16),
        const Text(
          "MISSION COMPLETED!",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        Text(
          "You answered $_correctAnswers out of ${_questions.length} questions correctly.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Text(
          "SCORE: ${percentage.toStringAsFixed(0)}%",
          style: TextStyle(color: isHighScorer ? AppTheme.secondaryColor : Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        if (_isClaiming)
          const CircularProgressIndicator()
        else ...[
          GlassCard(
            blur: 5,
            color: Colors.white10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _rewardStat("+15 Coins", "Participation"),
                if (isHighScorer) _rewardStat("+25 Coins", "80% Bonus"),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("RETURN TO TASKS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }

  Widget _rewardStat(String coins, String label) {
    return Column(
      children: [
        Text(coins, style: const TextStyle(color: AppTheme.accentColor, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
