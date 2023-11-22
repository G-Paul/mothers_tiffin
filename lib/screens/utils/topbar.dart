import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final Map<String, dynamic> userData;
  const TopBar({
    required this.userData,
    Key? key,
  }) : super(key: key);

  greet() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          ListTile(
            title: Text("Hi! ${userData["username"]}",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    )),
            subtitle: Text(
              greet(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.8),
                  ),
            ),
            contentPadding:
                const EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 15),
            trailing: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/details', arguments: userData);
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 24,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  radius: 22,
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(userData["profile_image"] ??
                        "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4"),
                    radius: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
