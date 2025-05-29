import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:color_switch_game/game_colors.dart';
import 'package:color_switch_game/road_widget.dart';
import 'package:color_switch_game/player_ball_widget.dart';
import 'package:color_switch_game/collectible_ball_widget.dart';
import 'package:color_switch_game/ball_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<CollectibleBallModel> _collectibleBalls = [];
  Timer? _ballSpawnTimer;
  final Random _random = Random();
  final double _playerBallSize = 50.0;
  final double _collectibleBallSize = 30.0;
  final double _playerBallBottomOffset = 50.0;
  double _previousAnimationValue = 0.0; // For calculating delta

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower, more controllable scroll
    )..addListener(_updateGame);
    _animationController.repeat();
    _previousAnimationValue = _animationController.value;

    _startGameMechanics();
  }

  void _startGameMechanics() {
    _collectibleBalls = []; // Ensure list is clear on restart
    _ballSpawnTimer?.cancel(); // Cancel any existing timer
    _ballSpawnTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) { // Check if widget is still in the tree
        _spawnCollectibleBall();
      }
    });
  }

  void _updateGame() {
    if (!mounted) return;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate scroll delta based on animation controller's progress
    double currentAnimationValue = _animationController.value;
    double deltaValue = currentAnimationValue - _previousAnimationValue;
    if (deltaValue < 0) { // Loop detected
      deltaValue += 1.0;
    }
    _previousAnimationValue = currentAnimationValue;

    // Define scroll speed factor (pixels per animation cycle)
    // This factor determines how many pixels the road scrolls for one full animation cycle (0.0 to 1.0)
    // Let's say we want the content to scroll by `screenHeight` over the duration of the animation controller.
    // However, ListView items have fixed height (50), so maxScrollExtent is based on that.
    // We want a speed that feels natural for the balls to traverse the screen.
    // Let's aim for balls to take roughly the animation duration to cross the screen.
    final double scrollPixelsPerFrame = deltaValue * screenHeight * 0.5; // Adjust 0.5 to control speed relative to screen height

    setState(() {
      // Update road scroll offsets
      // Ensure controllers are ready and have calculated dimensions
      if (_road1Controller.hasClients && _road1Controller.position.hasContentDimensions) {
        _road1Controller.jumpTo((_road1Controller.offset + scrollPixelsPerFrame) % _road1Controller.position.maxScrollExtent.clamp(1.0, double.infinity));
      }
      if (_road2Controller.hasClients && _road2Controller.position.hasContentDimensions) {
        _road2Controller.jumpTo((_road2Controller.offset + scrollPixelsPerFrame) % _road2Controller.position.maxScrollExtent.clamp(1.0, double.infinity));
      }
      if (_road3Controller.hasClients && _road3Controller.position.hasContentDimensions) {
        _road3Controller.jumpTo((_road3Controller.offset + scrollPixelsPerFrame) % _road3Controller.position.maxScrollExtent.clamp(1.0, double.infinity));
      }
      if (_road4Controller.hasClients && _road4Controller.position.hasContentDimensions) {
        _road4Controller.jumpTo((_road4Controller.offset + scrollPixelsPerFrame) % _road4Controller.position.maxScrollExtent.clamp(1.0, double.infinity));
      }
      
      List<CollectibleBallModel> ballsToRemove = [];
      for (var ball in _collectibleBalls) {
        // Move ball down: verticalPosition is a ratio (0.0 top, 1.0 bottom of screen)
        ball.verticalPosition += scrollPixelsPerFrame / screenHeight;

        // Remove if off-screen
        if (ball.verticalPosition > 1.0) {
          ballsToRemove.add(ball);
          continue;
        }

        // Collision detection
        if (ball.lane == _currentLane) {
          // Player ball's vertical range (fixed at the bottom)
          double playerBallTopY = screenHeight - _playerBallBottomOffset - _playerBallSize;
          double playerBallBottomY = screenHeight - _playerBallBottomOffset;
          
          // Collectible ball's vertical range (scrolling)
          double collectibleBallTopY = ball.verticalPosition * screenHeight;
          double collectibleBallBottomY = collectibleBallTopY + _collectibleBallSize;

          // Check for overlap
          if (playerBallTopY < collectibleBallBottomY && playerBallBottomY > collectibleBallTopY) {
            _playerColor = ball.color; // Change player ball color
            ballsToRemove.add(ball);    // Mark for removal
            // TODO: Add scoring or game over logic here if needed
          }
        }
      }
      _collectibleBalls.removeWhere((ball) => ballsToRemove.map((b) => b.id).contains(ball.id));
    });
  }

  void _spawnCollectibleBall() {
    if (!mounted) return;
    final int lane = _random.nextInt(4);
    final List<Color> availableColors = [collectibleRed, collectibleGreen, collectibleBlue];
    final Color color = availableColors[_random.nextInt(availableColors.length)];

    setState(() {
      _collectibleBalls.add(CollectibleBallModel(
        color: color,
        lane: lane,
        verticalPosition: 0.0, // Start at the top of the screen
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Switch Game'),
      ),
      body: Stack(
        children: <Widget>[
          // Roads
          Row(
            children: <Widget>[
              _buildLane(0, road1Color1, road1Color2, _road1Controller),
              _buildLane(1, road2Color1, road2Color2, _road2Controller),
              _buildLane(2, road3Color1, road3Color2, _road3Controller),
              _buildLane(3, road4Color1, road4Color2, _road4Controller),
            ],
          ),
          // Player Ball
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100), // Faster animation for lane switch
            left: _currentLane * (MediaQuery.of(context).size.width / 4) +
                (MediaQuery.of(context).size.width / 8) - // Center of the lane
                (_playerBallSize / 2), // Adjust for ball's radius
            bottom: _playerBallBottomOffset,
            child: PlayerBallWidget(color: _playerColor, size: _playerBallSize),
          ),
          // Display Collectible Balls
          ..._collectibleBalls.map((ball) {
            return Positioned(
              left: ball.lane * (MediaQuery.of(context).size.width / 4) +
                  (MediaQuery.of(context).size.width / 8) -
                  (_collectibleBallSize / 2),
              top: ball.verticalPosition * MediaQuery.of(context).size.height,
              child: CollectibleBallWidget(color: ball.color, size: _collectibleBallSize),
            );
          }).toList(),
        ],
      ),
      // floatingActionButton: Row( // Removed FABs
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () => _movePlayer(-1),
      //       child: const Icon(Icons.arrow_left),
      //     ),
      //     FloatingActionButton(
      //       onPressed: () => _movePlayer(1),
      //       child: const Icon(Icons.arrow_right),
      //     ),
      //   ],
      // )
    );
  }

  Widget _buildLane(int laneIndex, Color color1, Color color2, ScrollController controller) {
    return Expanded( // Use Expanded to make each lane take equal width and be tappable
      child: GestureDetector(
        onTap: () => _switchToLane(laneIndex),
        child: RoadWidget(
          colors: [color1, color2],
          controller: controller,
        ),
      ),
    );
  }

  void _switchToLane(int laneIndex) {
    setState(() {
      _currentLane = laneIndex.clamp(0, 3);
    });
  }

  // Controllers for road animations
  final ScrollController _road1Controller = ScrollController();
  final ScrollController _road2Controller = ScrollController();
  final ScrollController _road3Controller = ScrollController();
  final ScrollController _road4Controller = ScrollController();

  int _currentLane = 0; // 0 to 3
  Color _playerColor = playerBallColor;

  // void _movePlayer(int direction) { // Replaced by _switchToLane
  //   setState(() {
  //     _currentLane = (_currentLane + direction).clamp(0, 3);
  //   });
  // }

  // initState is modified above

  // _startRoadAnimation is removed

  @override
  void dispose() {
    _animationController.removeListener(_updateGame);
    _animationController.dispose();
    _ballSpawnTimer?.cancel();
    _road1Controller.dispose();
    _road2Controller.dispose();
    _road3Controller.dispose();
    _road4Controller.dispose();
    super.dispose();
  }
}
