import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/automation_controller.dart';
import 'widgets/glass_container.dart';
import 'login_webview.dart';
import 'package:animate_do/animate_do.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _codeController = TextEditingController(text: """//@version=5
indicator("My Script", overlay=true)
plot(close)
""");

  @override
  void initState() {
    super.initState();
    // Initialize automation on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AutomationController>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AutomationController>(context);
    final status = controller.status;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Pine Validator", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              backgroundColor: controller.isLoggedIn ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              label: Text(
                controller.isLoggedIn ? "Connected" : "Not Logged In",
                style: TextStyle(color: controller.isLoggedIn ? Colors.green : Colors.red),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginWebView())),
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FadeInUp(
                      duration: Duration(milliseconds: 500),
                      child: GlassContainer(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Code Editor", style: TextStyle(color: Colors.white70)),
                                  IconButton(
                                    icon: Icon(Icons.copy, color: Colors.white70, size: 20),
                                    onPressed: () {},
                                  )
                                ],
                              ),
                            ),
                            Divider(height: 1, color: Colors.white10),
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                maxLines: null,
                                style: GoogleFonts.firaCode(
                                  color: Colors.lightGreenAccent, 
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                  hintText: "Paste your Pine Script here...",
                                  hintStyle: TextStyle(color: Colors.white24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Status / Console Area
                if (status != AutomationStatus.idle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FadeInUp(
                      child: GlassContainer(
                        opacity: 0.2,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: status == AutomationStatus.error ? Colors.redAccent : Colors.cyanAccent,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              if (controller.resultMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    controller.resultMessage,
                                    style: TextStyle(color: Colors.white70),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2962FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      onPressed: status == AutomationStatus.idle || status == AutomationStatus.error || status == AutomationStatus.success
                          ? () {
                              if (!controller.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please login first!")));
                                return;
                              }
                              controller.validateScript(_codeController.text);
                            }
                          : null,
                      child: status == AutomationStatus.idle || status == AutomationStatus.error || status == AutomationStatus.success
                        ? Text("VALIDATE ON TRADINGVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2))
                        : SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(AutomationStatus status) {
    switch (status) {
      case AutomationStatus.initializing: return "Initializing Engine...";
      case AutomationStatus.checkingLogin: return "Checking Session...";
      case AutomationStatus.openingEditor: return "Opening Pine Editor...";
      case AutomationStatus.injectingCode: return "Injecting Code...";
      case AutomationStatus.compiling: return "Compiling...";
      case AutomationStatus.success: return "COMPILATION SUCCESSFUL";
      case AutomationStatus.error: return "COMPILATION FAILED";
      default: return "";
    }
  }
}
