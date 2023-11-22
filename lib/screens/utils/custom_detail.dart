import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDetailTile extends StatefulWidget {
  final String text;
  final String title;
  final IconData leadingIcon;
  final Function onEdited;
  final Function validator;
  const CustomDetailTile({
    super.key,
    required this.text,
    required this.title,
    required this.leadingIcon,
    required this.onEdited,
    required this.validator,
  });

  @override
  State<CustomDetailTile> createState() => _CustomDetailTileState();
}

class _CustomDetailTileState extends State<CustomDetailTile> {
  final TextEditingController _controller = TextEditingController(text: "");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Center(
                child: FaIcon(
                  widget.leadingIcon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 10,
                            top: 20,
                            left: 20,
                            right: 20),
                        height: MediaQuery.of(context).size.height * 0.3 +
                            MediaQuery.of(context).viewInsets.bottom +
                            10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter Your ${widget.title}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: TextFormField(
                                  validator: ((value) =>
                                      widget.validator(value)),
                                  onChanged: (_) {
                                    _formKey.currentState!.validate();
                                  },
                                  controller: _controller,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontSize: 20),
                                  decoration: InputDecoration(
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      )),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              horizontal: 20)),
                                      textStyle: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 18,
                                                // fontFamily: "Roboto",
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        widget.onEdited(_controller.value.text);
                                      }
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              horizontal: 20)),
                                      textStyle: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 18,
                                                // fontFamily: "Roboto",
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    child: const Text("Save"),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: FaIcon(
                FontAwesomeIcons.pencil,
                color: Theme.of(context).focusColor,
                size: 17,
              ),
            ),
          ],
        ));
  }
}

String? validateEmail(String? value) {
  if ((value == null || value.isEmpty)) {
    return 'Email is required';
  }
  const String regexPattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(regexPattern);
  if (!regex.hasMatch(value)) {
    return 'Invalid Email';
  }
  return null;
}

String? validateName(String? value) {
  if ((value == null) || (value.isEmpty)) {
    return "Name cannot be empty";
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return 'Please enter mobile number';
  } else if (!regExp.hasMatch(value)) {
    return 'Please enter valid mobile number';
  }
  return null;
}
