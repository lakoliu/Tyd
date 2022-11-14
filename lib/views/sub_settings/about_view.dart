import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutView extends StatefulWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.about,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/tyd.png'),
                width: 200.0,
              ),
              const SizedBox(
                height: 15.0,
              ),
              const AutoSizeText(
                'Tyd',
                style: TextStyle(
                  fontSize: 40.0,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                '${AppLocalizations.of(context)!.version} 1.0.0',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                AppLocalizations.of(context)!.lakoLiuApp,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                AppLocalizations.of(context)!.issuesSuggestions,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 8.0,
              ),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.email,
                  style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  children: const <TextSpan>[
                    TextSpan(
                      text: 'tyd@lakoliu.com',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
