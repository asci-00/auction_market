class DevQuickAccount {
  const DevQuickAccount({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  static const buyer = DevQuickAccount(
    email: 'buyer1@test.local',
    password: 'buyer-pass-1234',
  );

  static const seller = DevQuickAccount(
    email: 'seller1@test.local',
    password: 'seller-pass-1234',
  );
}
