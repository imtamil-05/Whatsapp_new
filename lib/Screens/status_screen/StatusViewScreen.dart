import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatusViewScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> statuses;
  final String userName;

  const StatusViewScreen({
    Key? key,

    required this.statuses,
    required this.userName,
  }) : super(key: key);

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  late PageController _pageController;
  int currentIndex = 0;
  Timer? _timer;
  static const duration = Duration(seconds: 5);
  double progress = 0.0;
  bool isPaused = false;

  static const int statusDurationSeconds = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => startTimer());
  }

  void startTimer() {
    _timer?.cancel();

    progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isPaused) {
        setState(() {
          progress += 1 / (statusDurationSeconds * 10);
        });

        if (progress >= 1) {
          nextStatus();
        }
      }
    });
  }

  void nextStatus() {
    _timer?.cancel();

    if (currentIndex < widget.statuses.length - 1) {
      setState(() {
        currentIndex++;
      });
     if (_pageController.hasClients) {
  _pageController.animateToPage(
    currentIndex,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn,
  );
}
      startTimer();
    } else {
      Navigator.pop(context); // close after last
    }
  }

  void previousStatus() {
    if (currentIndex > 0) {
      _timer?.cancel();

      setState(() {
        currentIndex--;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
      startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildProgressBars() {
    return Row(
      children: List.generate(widget.statuses.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: LinearProgressIndicator(
              minHeight: 1,
              value: index < currentIndex
                  ? 1
                  : index == currentIndex
                  ? progress
                  : 0,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.userName, style: TextStyle(color: Colors.white)),
              Container(
                //padding: EdgeInsets.all(6),
                child: buildProgressBars(),
              ),
              //Text(widget.time,style: const TextStyle(color: Colors.white),),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onLongPressStart: (_) {
          setState(() {
            isPaused = true;
            _timer?.cancel();
          });
        },
        onLongPressCancel: () {
          setState(() {
            isPaused = false;
            startTimer();
          });
        },
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            previousStatus();
          } else {
            nextStatus();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.statuses.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                final data=widget.statuses[index].data() as Map<String, dynamic>;
                final imageUrl=data['imageUrl'];
                final caption=data.containsKey('caption')?data['caption']:"";
                return Stack(
                  children:[ Center(
                    child: Image.network(
                      imageUrl,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(color: Colors.teal);
                      },
                    ),
                  ),
                   if (caption != null && caption.toString().trim().isNotEmpty)
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
                  ],
                );
              },
            ),

            //           Positioned(
            //   top: 40,
            //   left: 10,
            //   right: 10,
            //   child: buildProgressBars(),
            // ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
            ),
          

            // Positioned(
            //     top: 10,
            //     left: 10,
            //     right: 10,
            //     child: LinearProgressIndicator(
            //       value: progress,
            //       backgroundColor: Colors.white24,
            //       valueColor:
            //           const AlwaysStoppedAnimation<Color>(Colors.teal),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//     .collection('status')
//     .where('userId', isEqualTo: widget.userId)
//     .where('expiresAt', isGreaterThan: Timestamp.now())
//     .orderBy('expiresAt')
//     .orderBy('createdAt')
//     .snapshots(),

//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final statuses = snapshot.data!.docs;

//           return Stack(
//             children:[ PageView.builder(
//               controller: _pageController,
//               itemCount: statuses.length,
//               onPageChanged: (index) {
//                 setState(() => currentIndex = index);
//               },
//               itemBuilder: (context, index) {
//                 final status = statuses[index];
            
//                 return Center(
//                   child: Image.network(
//                     status['imageUrl'],
//                     fit: BoxFit.contain,
//                   ),
//                 );
            
//               },
//             ),
//              Positioned(
//       top: 10,
//       left: 10,
//       right: 10,
//       child: Row(
//         children: List.generate(
//           statuses.length,
//           (index) => Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               height: 3,
//               decoration: BoxDecoration(
//                 color: index <= currentIndex
//                     ? Colors.white
//                     : Colors.white30,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//             ]
//           );
//         },
//       ),
//     );
//   }
// }
