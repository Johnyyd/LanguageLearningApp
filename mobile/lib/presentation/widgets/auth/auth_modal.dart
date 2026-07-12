import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote_ai_datasource.dart';

class AuthModal extends StatefulWidget {
    final VoidCallback onAuthSuccess;

    const AuthModal({super.key, required this.onAuthSuccess});

    @override
    State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> with SingleTickerProviderStateMixin {
    late TabController _tabController;
    final _usernameCtrl = TextEditingController();
    final _emailCtrl = TextEditingController();
    final _passwordCtrl = TextEditingController();
    final _fullNameCtrl = TextEditingController();
    bool _isLoading = false;
    String? _errorMessage;

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 2, vsync: this);
    }

    @override
    void dispose() {
        _tabController.dispose();
        _usernameCtrl.dispose();
        _emailCtrl.dispose();
        _passwordCtrl.dispose();
        _fullNameCtrl.dispose();
        super.dispose();
    }

    Future<void> _submitLogin() async {
        if (_usernameCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
            setState(() => _errorMessage = "Vui lòng nhập tên đăng nhập và mật khẩu");
            return;
        }
        setState(() {
            _isLoading = true;
            _errorMessage = null;
        });
        try {
            final remote = context.read<RemoteAiDataSource>();
            await remote.loginUser(
                username: _usernameCtrl.text.trim(),
                password: _passwordCtrl.text,
            );
            if (mounted) {
                widget.onAuthSuccess();
                Navigator.pop(context);
            }
        } catch (e) {
            if (mounted) {
                setState(() {
                    _isLoading = false;
                    _errorMessage = "Đăng nhập thất bại. Kiểm tra thông tin tài khoản!";
                });
            }
        }
    }

    Future<void> _submitRegister() async {
        if (_usernameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
            setState(() => _errorMessage = "Vui lòng điền đủ tên đăng nhập, email và mật khẩu");
            return;
        }
        setState(() {
            _isLoading = true;
            _errorMessage = null;
        });
        try {
            final remote = context.read<RemoteAiDataSource>();
            await remote.registerUser(
                username: _usernameCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                password: _passwordCtrl.text,
                fullName: _fullNameCtrl.text.trim().isEmpty ? _usernameCtrl.text.trim() : _fullNameCtrl.text.trim(),
            );
            if (mounted) {
                widget.onAuthSuccess();
                Navigator.pop(context);
            }
        } catch (e) {
            if (mounted) {
                setState(() {
                    _isLoading = false;
                    _errorMessage = "Đăng ký thất bại. Tên đăng nhập hoặc email có thể đã tồn tại.";
                });
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                            color: AppColors.slateGray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                        ),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.sakuraPink,
                        labelColor: AppColors.sakuraPink,
                        unselectedLabelColor: AppColors.slateGray,
                        tabs: const [
                            Tab(text: "Đăng nhập"),
                            Tab(text: "Đăng ký"),
                        ],
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                        Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                                color: AppColors.crimsonRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.crimsonRed, fontSize: 13),
                                textAlign: TextAlign.center,
                            ),
                        ),
                    SizedBox(
                        height: 280,
                        child: TabBarView(
                            controller: _tabController,
                            children: [
                                _buildLoginForm(),
                                _buildRegisterForm(),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildLoginForm() {
        return SingleChildScrollView(
            child: Column(
                children: [
                    TextField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                            labelText: "Tên đăng nhập hoặc Email",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sakuraPink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildRegisterForm() {
        return SingleChildScrollView(
            child: Column(
                children: [
                    TextField(
                        controller: _fullNameCtrl,
                        decoration: InputDecoration(
                            labelText: "Họ và tên",
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                            labelText: "Tên đăng nhập",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitRegister,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sakuraPink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Tạo Tài Khoản & Bắt Đầu Học", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ),
                ],
            ),
        );
    }
}
