import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:linkflutter/features/scan/models/scan_contact_draft.dart';

enum DeviceContactSaveResult { saved, permissionDenied, failed }

/// Enregistre un contact dans le carnet d'adresses natif (iOS / Android).
class DeviceContactsService {
  Future<DeviceContactSaveResult> saveDraft(ScanContactDraft draft) async {
    try {
      final status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
      final granted = status == PermissionStatus.granted ||
          status == PermissionStatus.limited;
      if (!granted) {
        return DeviceContactSaveResult.permissionDenied;
      }

      final phones = <Phone>[];
      final phone = draft.phone?.trim();
      if (phone != null && phone.isNotEmpty) {
        phones.add(Phone(number: phone));
      }

      final emails = <Email>[];
      final email = draft.email?.trim();
      if (email != null && email.isNotEmpty) {
        emails.add(Email(address: email));
      }

      final organizations = <Organization>[];
      final company = draft.company?.trim() ?? '';
      final jobTitle = draft.jobTitle?.trim() ?? '';
      if (company.isNotEmpty || jobTitle.isNotEmpty) {
        organizations.add(Organization(name: company, jobTitle: jobTitle));
      }

      final contact = Contact(
        name: Name(first: draft.firstName.trim(), last: draft.lastName.trim()),
        phones: phones,
        emails: emails,
        organizations: organizations,
      );

      await FlutterContacts.create(contact);
      return DeviceContactSaveResult.saved;
    } catch (_) {
      return DeviceContactSaveResult.failed;
    }
  }
}
