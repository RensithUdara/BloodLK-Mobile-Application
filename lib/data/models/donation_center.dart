class DonationCenter {
  const DonationCenter({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.district,
  });

  final String id;
  final String name;
  final String contactNumber;
  final String address;
  final String district;

  factory DonationCenter.fromMap(String id, Map<String, dynamic> data) {
    return DonationCenter(
      id: id,
      name: _firstText(data, ['centerName', 'name', 'title']),
      contactNumber: _firstText(data, ['contactNumber', 'phone', 'mobile']),
      address: _firstText(data, ['address', 'centerAddress', 'location']),
      district: _firstText(data, ['district', 'city']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'centerName': name.trim(),
      'contactNumber': contactNumber.trim(),
      'address': address.trim(),
      'district': district.trim(),
    };
  }

  bool matchesSearch(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return name.toLowerCase().contains(normalizedQuery) ||
        contactNumber.toLowerCase().contains(normalizedQuery) ||
        address.toLowerCase().contains(normalizedQuery) ||
        district.toLowerCase().contains(normalizedQuery);
  }

  bool matchesDistrict(String selectedDistrict) {
    if (selectedDistrict == DonationDistricts.all) return true;
    return district.trim().toLowerCase() == selectedDistrict.toLowerCase();
  }

  static String _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }
}

class DonationDistricts {
  static const all = 'All Districts';

  static const values = [
    all,
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];
}
