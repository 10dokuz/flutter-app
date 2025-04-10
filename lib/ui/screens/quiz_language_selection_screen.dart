import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/localization/quiz_language_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/language_selection_helper.dart';

class QuizLanguageSelectionScreen extends StatefulWidget {
  const QuizLanguageSelectionScreen({super.key});

  @override
  State<QuizLanguageSelectionScreen> createState() =>
      _QuizLanguageSelectionScreenState();

  static Route<dynamic> route() => CupertinoPageRoute(
        builder: (_) => const QuizLanguageSelectionScreen(),
      );
}

class _QuizLanguageSelectionScreenState extends State<QuizLanguageSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final supportedLanguages =
        context.read<SystemConfigCubit>().supportedQuizLanguages;

    return Scaffold(
      appBar: QAppBar(
        automaticallyImplyLeading: false,
        title: Text(context.tr('quizLanguage')!),
        usePrimaryColor: true,
      ),
      body: BlocConsumer<QuizLanguageCubit, QuizLanguageState>(
        listener: (context, state) {},
        builder: (context, state) {
          var currLangId = state.languageId;

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.height * UiUtils.vtMarginPct,
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            child: ListView.separated(
              itemBuilder: (_, i) {
                final supportedLanguage = supportedLanguages[i];
                final languageId = supportedLanguage.id;

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: .7),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RadioListTile<String>(
                    toggleable: true,
                    activeColor: currLangId == languageId
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    title: Text(
                      supportedLanguage.language,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    value: languageId,
                    groupValue: currLangId,
                    onChanged: (value) async {
                      currLangId = value!;

                            if (state.languageId != languageId) {
                              context.read<QuizLanguageCubit>().languageId =
                                  languageId;
                            }
                    },
                  ),
                );
              },
              separatorBuilder: (_, i) =>
                  const SizedBox(height: UiUtils.listTileGap),
              itemCount: supportedLanguages.length,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (context.read<QuizLanguageCubit>().state.languageId.isNotEmpty) {
            await LanguageSelectionHelper.markQuizLanguageAsSelected();
            Navigator.of(context).pushReplacementNamed(
              Routes.home,
              arguments: true,
            );
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.check),
      ),
    );
  }
}