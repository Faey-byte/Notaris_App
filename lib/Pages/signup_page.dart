import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/signup_controller.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final controller =
      Get.put(SignupController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),

            child: Form(
              key: controller.formKey,

              child: Column(
                children: [

                  const SizedBox(height: 50),

                  Container(
                    width: 80,
                    height: 80,

                    decoration: const BoxDecoration(
                      color: Color(0xFFFCEEEE),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Color(0xFFB23B35),
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Silahkan daftar akun terlebih dahulu",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller:
                        controller.usernameC,

                    decoration: InputDecoration(
                      hintText: "Username",

                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    validator:
                        controller.validateUsername,
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller:
                        controller.emailC,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration: InputDecoration(
                      hintText: "Email",

                      prefixIcon: const Icon(
                        Icons.mail_outline,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    validator:
                        controller.validateEmail,
                  ),

                  const SizedBox(height: 18),

                  Obx(
                    () => TextFormField(
                      controller:
                          controller.passC,

                      obscureText:
                          controller.obscure.value,

                      decoration: InputDecoration(
                        hintText: "Password",

                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon: IconButton(
                          onPressed: controller
                              .togglePassword,

                          icon: Icon(
                            controller.obscure
                                    .value
                                ? Icons
                                    .visibility_off
                                : Icons
                                    .visibility,
                          ),
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),

                      validator:
                          controller.validatePassword,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller:
                        controller.companyC,

                    decoration: InputDecoration(
                      hintText: "Company Name",

                      prefixIcon: const Icon(
                        Icons.business_outlined,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    validator:
                        controller.validateCompany,
                  ),

                  const SizedBox(height: 30),

                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed:
                            controller
                                    .isLoading
                                    .value
                                ? null
                                : controller.signup,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFB23B35,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                          ),
                        ),

                        child:
                            controller
                                    .isLoading
                                    .value
                                ? const CircularProgressIndicator(
                                    color:
                                        Colors
                                            .white,
                                  )
                                : const Text(
                                    "Sign Up",
                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,
                                      color:
                                          Colors
                                              .white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Text(
                        "Sudah punya akun?",
                      ),

                      TextButton(
                        onPressed: () {
                          Get.back();
                        },

                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color:
                                Color(0xFFB23B35),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}