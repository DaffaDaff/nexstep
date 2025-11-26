import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? profileData;
  List<Map<String, dynamic>>? goalsData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    // _fetchGoalsData();
  }

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await Supabase.instance.client
        .from('details') // Replace with your actual table name
        .select()
        .eq('user_id', userId!) // Optional: to filter by user_id
        .single(); // Assuming only one record per user

    debugPrint(response.toString());

    // Ensure that the response is properly checked
    if (response['id'] != null) {
      setState(() {
        profileData = Supabase
            .instance
            .client
            .auth
            .currentUser; // This is the data returned by the query
        isLoading = false;
      });
    } else {
      // setState(() {
      //   errorMessage =
      //       response.error?.message ??
      //       "An error occurred while fetching profile data.";
      //   isLoading = false;
      // });
    }
  }

  // Future<void> _fetchGoalsData() async {
  //   final response = await Supabase.instance.client
  //       .from('goals') // Replace with your actual table name
  //       .select()
  //       .eq('user_id', 'your-user-id') // Optional: to filter by user_id
  //       .order(
  //         'created_at',
  //       ); // Assuming your goals table has a 'created_at' column

  //   // Ensure that the response is properly checked
  //   if (response.error == null) {
  //     setState(() {
  //       goalsData = List<Map<String, dynamic>>.from(
  //         response.data ?? [],
  //       ); // Converting to List<Map<String, dynamic>>
  //     });
  //   } else {
  //     setState(() {
  //       errorMessage =
  //           response.error?.message ??
  //           "An error occurred while fetching goals data.";
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F141A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade700,
                    child: Text(
                      profileData?.email?.substring(0, 1) ??
                          "U", // Default if no data
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileData?.userMetadata?['username'] ??
                            "User", // Default name if no data
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profileData?.email ?? "user@nexstep.com",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 16,
                      //     vertical: 6,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFF0EA5E9),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: const Text(
                      //     "Edit Profile",
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Body Composition Summary (e.g., weight, height)
              Text(
                "Body Composition Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blueGrey.shade700),
                ),
                child: Column(
                  children: [
                    // _bodyRow(
                    //   icon: Icons.monitor_weight,
                    //   label: "Weight",
                    //   value: profileData?['weight']?.toString() ?? "72 kg",
                    //   diff: "-0.2 kg",
                    //   diffColor: Colors.greenAccent,
                    // ),
                    // const Divider(color: Colors.grey),
                    // _bodyRow(
                    //   icon: Icons.height,
                    //   label: "Height",
                    //   value: profileData?['height']?.toString() ?? "175 cm",
                    //   diff: "+1 cm",
                    //   diffColor: Colors.greenAccent,
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // // Weekly Goals
              // Text(
              //   "Weekly Goals",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontWeight: FontWeight.w600,
              //     fontSize: 16,
              //   ),
              // ),
              // const SizedBox(height: 15),

              // // Display goals dynamically
              // if (goalsData != null && goalsData!.isNotEmpty)
              //   for (var goal in goalsData!)
              //     _goalCard(
              //       icon: Icons.check,
              //       label: goal['goal_name'] ?? 'Goal',
              //       progress:
              //           '${goal['completed_count'] ?? 0}/${goal['total_count'] ?? 0}',
              //     ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bodyRow({
    required IconData icon,
    required String label,
    required String value,
    required String diff,
    required Color diffColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.greenAccent),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          diff,
          style: TextStyle(
            color: diffColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _goalCard({
    required IconData icon,
    required String label,
    required String progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade700),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(progress, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
