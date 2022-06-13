import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);
  static const String routeName = 'home-page';

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _nameNode = FocusNode();
  final _numNode = FocusNode();
  final _mailNode = FocusNode();
  final _messageNode = FocusNode();

  String? _name;
  String? _mNumber;
  String? _eMail;
  String? _message;

  final _form = GlobalKey<FormState>();

  void submit() {
    _form.currentState!.save();
    if (_form.currentState!.validate()) {
      print(_name);
      print(_mNumber);
      print(_eMail);
      print(_message);

      sendMail();
    }
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _numNode.dispose();
    _mailNode.dispose();
    _messageNode.dispose();
    super.dispose();
  }

  sendMail() async {
    final mailer = Mailer(dotenv.dotenv.env['API_KEY'].toString());
    final toAddress = Address(dotenv.dotenv.env['TO_EMAIL'].toString());
    final fromAddress = Address(dotenv.dotenv.env['FROM_EMAIL'].toString());
    final content = Content('text/html', _message!);
    final subject = '${dotenv.dotenv.env['SUBJECT']}$_name';
    final personalization = Personalization(
      [toAddress],
      dynamicTemplateData: {
        "subject": subject,
        "message": _message,
        "name": _name,
        "number": _mNumber,
        "email": _eMail,
      },
    );

    final email = Email([personalization], fromAddress, subject,
        content: [content], templateId: dotenv.dotenv.env['TEMPLATE_ID']);
    mailer.send(email).then(
      (result) {
        // ...
        if (!result.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Messsage has been sent'),
            ),
          );
          _form.currentState!.reset();
        }
        print(result.isError);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact-Us'),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              height: screenSize.height * 0.67,
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            labelText: 'Enter Name',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_numNode);
                          },
                          onSaved: (value) {
                            _name = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your Name';
                            }
                            return null;
                          },
                          focusNode: _nameNode,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Mobile Number',
                            labelText: 'Enter your Mobile Number',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_mailNode);
                          },
                          onSaved: (value) {
                            _mNumber = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your number';
                            }
                            if (value.length < 10 || value.length > 10) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                          focusNode: _numNode,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'you123@mail.com',
                            labelText: 'Enter your E-mail Address',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_messageNode);
                          },
                          onSaved: (value) {
                            _eMail = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your E-mail Id";
                            }
                            RegExp regex = RegExp(
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                            if (!regex.hasMatch(value)) {
                              return "Enter a valid email address";
                            }
                            return null;
                          },
                          focusNode: _mailNode,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            labelText: 'Enter your Message',
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            submit();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Entr your Messsage';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _message = value;
                          },
                          focusNode: _messageNode,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: screenSize.width * 0.5,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  submit();
                },
              ),
              margin: const EdgeInsets.only(top: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
