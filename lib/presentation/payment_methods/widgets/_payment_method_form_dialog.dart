part of '../payment_methods_page.dart';

class _CreateOrEditDialog extends StatefulWidget {
  final PaymentMethodItem? existing;
  const _CreateOrEditDialog({this.existing});

  @override
  State<_CreateOrEditDialog> createState() => _CreateOrEditDialogState();
}

class _CreateOrEditDialogState extends State<_CreateOrEditDialog> {
  static const List<IconData> _paymentIcons = [
    CustomIcons.credit_card,
    Icons.account_balance_wallet,
    Icons.account_balance,
    CustomIcons.local_atm,
    CustomIcons.cc_mastercard,
    CustomIcons.cc_visa,
    CustomIcons.cc_amex,
    CustomIcons.cc_discover,
    CustomIcons.cc_stripe,
    CustomIcons.cc_paypal,
    CustomIcons.gwallet,
    CustomIcons.dollar,
    CustomIcons.money,
    Icons.attach_money,
    CustomIcons.hand_holding_usd,
    CustomIcons.btc,
  ];

  static const List<Color> _presetColors = [
    Color(0xFF2196F3), // blue
    Color(0xFF4CAF50), // green
    Color(0xFFF44336), // red
    Color(0xFFFF9800), // orange
    Color(0xFF9C27B0), // purple
    Color(0xFF00BCD4), // cyan
    Color(0xFF795548), // brown
    Color(0xFF607D8B), // blue-grey
    Color(0xFFE91E63), // pink
    Color(0xFF009688), // teal
    Color(0xFF3F51B5), // indigo
    Color(0xFF212121), // dark
  ];

  static const IconData _defaultIcon = CustomIcons.credit_card;
  static const Color _defaultColor = Color(0xFF2196F3);

  late final TextEditingController _nameCtrl;
  late final TextEditingController _statementCtrl;
  late final TextEditingController _dueCtrl;
  late final TextEditingController _limitCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _statementCtrl = TextEditingController(text: e?.statementCloseDay?.toString() ?? '');
    _dueCtrl = TextEditingController(text: e?.paymentDueDay?.toString() ?? '');
    _limitCtrl = TextEditingController(text: e?.creditLimitMinor?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _statementCtrl.dispose();
    _dueCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Injection.paymentMethodFormBloc..add(PaymentMethodFormEvent.initialize(existing: widget.existing)),
      child: BlocConsumer<PaymentMethodFormBloc, PaymentMethodFormState>(
        listener: (context, state) {
          final s = state as PaymentMethodFormStateInitial;
          if (!s.submitted) return;
          final isCreditCard = s.type == PaymentMethodType.creditCard;
          final method = PaymentMethodItem(
            id: widget.existing?.id ?? 0,
            userId: widget.existing?.userId ?? 0,
            name: s.name.trim(),
            type: s.type,
            icon: s.icon ?? _defaultIcon,
            iconColor: s.iconColor ?? _defaultColor,
            statementCloseDay: isCreditCard ? int.tryParse(s.statementDayText) : widget.existing?.statementCloseDay,
            paymentDueDay: isCreditCard ? int.tryParse(s.dueDayText) : widget.existing?.paymentDueDay,
            creditLimitMinor: isCreditCard ? int.tryParse(s.creditLimitText) : widget.existing?.creditLimitMinor,
            isArchived: widget.existing?.isArchived ?? false,
            sortOrder: widget.existing?.sortOrder ?? 0,
          );
          context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.createOrUpdate(method: method));
          Navigator.pop(context);
        },
        builder: (context, state) {
          final s = state as PaymentMethodFormStateInitial;
          final i18n = S.of(context);
          final bloc = context.read<PaymentMethodFormBloc>();

          return AlertDialog(
            title: Text(widget.existing == null ? i18n.newPaymentMethod : i18n.editPaymentMethod),
            content: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon + color preview
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: s.iconColor ?? _defaultColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            s.icon ?? _defaultIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Icon picker row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final iconData in _paymentIcons) ...[
                            GestureDetector(
                              onTap: () => bloc.add(PaymentMethodFormEvent.iconChanged(icon: iconData)),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (s.icon ?? _defaultIcon) == iconData
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  color: (s.icon ?? _defaultIcon) == iconData
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                ),
                                child: Center(child: Icon(iconData, size: 18)),
                              ),
                            ),
                            if (iconData != _paymentIcons.last) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Color swatches row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final color in _presetColors) ...[
                            GestureDetector(
                              onTap: () => bloc.add(PaymentMethodFormEvent.iconColorChanged(iconColor: color)),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (s.iconColor ?? _defaultColor) == color
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: (s.iconColor ?? _defaultColor) == color
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                            if (color != _presetColors.last) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _nameCtrl,
                      maxLength: PaymentMethodFormBloc.maxNameLength,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(labelText: i18n.name),
                      autovalidateMode: s.isNameDirty ? AutovalidateMode.always : null,
                      onChanged: (v) => bloc.add(PaymentMethodFormEvent.nameChanged(value: v)),
                      validator: (_) {
                        if (s.isNameValid) return null;
                        return s.isDuplicate ? i18n.nameAlreadyExists : i18n.nameIsRequired;
                      },
                    ),
                    DropdownButtonFormField<PaymentMethodType>(
                      key: ValueKey(s.type),
                      decoration: InputDecoration(labelText: i18n.type),
                      initialValue: s.type,
                      items: PaymentMethodType.values
                          .map(
                            (val) => DropdownMenuItem(
                              value: val,
                              child: Text(i18n.translatePaymentMethodType(val)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) bloc.add(PaymentMethodFormEvent.typeChanged(value: v));
                      },
                    ),
                    if (s.type == PaymentMethodType.creditCard) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _statementCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: PaymentMethodFormBloc.maxDayLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(labelText: i18n.statementCloseDay),
                        autovalidateMode: s.isStatementDayDirty ? AutovalidateMode.always : null,
                        onChanged: (v) => bloc.add(PaymentMethodFormEvent.statementDayChanged(value: v)),
                        validator: (_) => s.isStatementDayValid ? null : i18n.invalidCreditCardFields,
                      ),
                      TextFormField(
                        controller: _dueCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: PaymentMethodFormBloc.maxDayLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(labelText: i18n.paymentDueDay),
                        autovalidateMode: s.isDueDayDirty ? AutovalidateMode.always : null,
                        onChanged: (v) => bloc.add(PaymentMethodFormEvent.dueDayChanged(value: v)),
                        validator: (_) => s.isDueDayValid ? null : i18n.invalidCreditCardFields,
                      ),
                      TextFormField(
                        controller: _limitCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: PaymentMethodFormBloc.maxCreditLimitLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(labelText: i18n.creditLimitMinor),
                        autovalidateMode: s.isCreditLimitDirty ? AutovalidateMode.always : null,
                        onChanged: (v) => bloc.add(PaymentMethodFormEvent.creditLimitChanged(value: v)),
                        validator: (_) => s.isCreditLimitValid ? null : i18n.invalidCreditCardFields,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(i18n.cancel)),
              FilledButton(
                onPressed: () {
                  final items = switch (context.read<PaymentMethodsBloc>().state) {
                    final PaymentMethodsStateLoadedState s => s.items,
                    _ => const <PaymentMethodItem>[],
                  };
                  bloc.add(
                    PaymentMethodFormEvent.submit(
                      existingItems: items,
                      editingId: widget.existing?.id,
                    ),
                  );
                },
                child: Text(i18n.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
