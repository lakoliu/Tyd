import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String getTranslatedSanitaryItem(BuildContext context, String item) {
  switch (item) {
    case 'Tampon':
      return AppLocalizations.of(context)!.tampon;
    case 'Pad':
      return AppLocalizations.of(context)!.pad;
    case 'Cup':
      return AppLocalizations.of(context)!.cup;
    case 'Underwear':
      return AppLocalizations.of(context)!.underwear;
    default:
      return AppLocalizations.of(context)!.tampon;
  }
}

String getTranslatedSymptom(BuildContext context, String symptom) {
  switch (symptom) {
    case 'Anger':
      return AppLocalizations.of(context)!.anger;
    case 'Anxious':
      return AppLocalizations.of(context)!.anxious;
    case 'Back pain':
      return AppLocalizations.of(context)!.backPain;
    case 'Bloating':
      return AppLocalizations.of(context)!.bloating;
    case 'Breast tenderness':
      return AppLocalizations.of(context)!.breastTenderness;
    case 'Changed appetite':
      return AppLocalizations.of(context)!.changedAppetite;
    case 'Changed sex drive':
      return AppLocalizations.of(context)!.changedSexDrive;
    case 'Constipation':
      return AppLocalizations.of(context)!.constipation;
    case 'Cramps':
      return AppLocalizations.of(context)!.cramps;
    case 'Diarrhea':
      return AppLocalizations.of(context)!.diarrhea;
    case 'Dizziness':
      return AppLocalizations.of(context)!.dizziness;
    case 'Fatigue':
      return AppLocalizations.of(context)!.fatigue;
    case 'Headache':
      return AppLocalizations.of(context)!.headache;
    case 'Insomnia':
      return AppLocalizations.of(context)!.insomnia;
    case 'Irritable':
      return AppLocalizations.of(context)!.irritable;
    case 'Joint pain':
      return AppLocalizations.of(context)!.jointPain;
    case 'Muscle aches':
      return AppLocalizations.of(context)!.muscleAches;
    case 'Nausea':
      return AppLocalizations.of(context)!.nausea;
    case 'Painful defecation':
      return AppLocalizations.of(context)!.painfulDefecation;
    case 'Pimples':
      return AppLocalizations.of(context)!.pimples;
    case 'Sadness':
      return AppLocalizations.of(context)!.sadness;
    default:
      return symptom;
  }
}
