import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';

// Form to create or edit an organization
// Fields:   String id = ""; String uuid = ""; String code = ""; String name; String country = ""; bool financier = false; bool partner = false; bool public = false; String domain = "";
class OrganizationForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Organization selectedOrganization;
  final List<Country> countries;
  final List<Organization> otherOrganizations;

  const OrganizationForm(
      {super.key,
      required this.onSubmit,
      required this.selectedOrganization,
      required this.countries,
      required this.otherOrganizations});

  @override
  OrganizationFormState createState() => OrganizationFormState();
}

class OrganizationFormState extends State<OrganizationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If editing an existing organization, pre-fill the form fields
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedOrganization.country.isEmpty &&
        widget.countries.isNotEmpty) {
      widget.selectedOrganization.country = widget.countries.first.uuid;
    }
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: widget.selectedOrganization.name,
            decoration: const InputDecoration(labelText: 'Nombre'),
            onSaved: (newValue) {
              widget.selectedOrganization.name = newValue ?? '';
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre de la organización';
              }
              return null;
            },
          ),
          Row(children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextFormField(
                      initialValue: widget.selectedOrganization.code,
                      decoration: const InputDecoration(labelText: 'Código'),
                      onSaved: (newValue) {
                        widget.selectedOrganization.code = newValue ?? '';
                      },
                    ))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: DropdownButtonFormField<String>(
                      value: widget.selectedOrganization.country.isNotEmpty
                          ? widget.selectedOrganization.country
                          : null,
                      decoration: const InputDecoration(labelText: 'País'),
                      items: widget.countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country.uuid,
                          child: Text(country.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          widget.selectedOrganization.country = newValue ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione un país';
                        }
                        return null;
                      },
                    ))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextFormField(
                      initialValue: widget.selectedOrganization.domain,
                      decoration: const InputDecoration(labelText: 'Dominio'),
                      onChanged: (value) {
                        // Check if the domain is unique among other organizations, then show a warining if not
                        for (var org in widget.otherOrganizations) {
                          if (org.domain == value &&
                              org.uuid != widget.selectedOrganization.uuid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'El dominio ya está en uso por otra organización'),
                              ),
                            );
                            return;
                          }
                        }
                      },
                      validator: (value) {
                        // Check if the domain is unique among other organizations, then show a warining if not
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        for (var org in widget.otherOrganizations) {
                          if (org.domain == value &&
                              org.uuid != widget.selectedOrganization.uuid) {
                            return 'El dominio ya está en uso por otra organización';
                          }
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        widget.selectedOrganization.domain = newValue ?? '';
                      },
                    )))
          ]),
          TextFormField(
            initialValue: widget.selectedOrganization.billingName,
            decoration:
                const InputDecoration(labelText: 'Nombre de Facturación'),
            onSaved: (newValue) {
              widget.selectedOrganization.billingName = newValue ?? '';
            },
          ),
          // Row for cif, account
          Row(children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextFormField(
                      initialValue: widget.selectedOrganization.cif,
                      decoration: const InputDecoration(labelText: 'CIF'),
                      onChanged: (value) {
                        // Check if the CIF is unique among other organizations, then show a warining if not

                        for (var org in widget.otherOrganizations) {
                          if (org.cif == value &&
                              org.uuid != widget.selectedOrganization.uuid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'El CIF ya está en uso por otra organización'),
                              ),
                            );
                            return;
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el CIF';
                        }
                        // Check for uniqueness
                        for (var org in widget.otherOrganizations) {
                          if (org.cif == value &&
                              org.uuid != widget.selectedOrganization.uuid) {
                            return 'El CIF ya está en uso por otra organización';
                          }
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        widget.selectedOrganization.cif = newValue ?? '';
                      },
                    ))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextFormField(
                      initialValue: widget.selectedOrganization.account,
                      decoration: const InputDecoration(labelText: 'Cuenta'),
                      onSaved: (newValue) {
                        widget.selectedOrganization.account = newValue ?? '';
                      },
                    )))
          ]),
          // Field for address
          TextFormField(
            initialValue: widget.selectedOrganization.address,
            decoration: const InputDecoration(labelText: 'Dirección'),
            onSaved: (newValue) {
              widget.selectedOrganization.address = newValue ?? '';
            },
          ),
          Row(children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Financiador'),
                value: widget.selectedOrganization.financier,
                onChanged: (bool value) {
                  setState(() {
                    widget.selectedOrganization.financier = value;
                  });
                },
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Socio'),
                value: widget.selectedOrganization.partner,
                onChanged: (bool value) {
                  setState(() {
                    widget.selectedOrganization.partner = value;
                  });
                },
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Público'),
                value: widget.selectedOrganization.public,
                onChanged: (bool value) {
                  setState(() {
                    widget.selectedOrganization.public = value;
                  });
                },
              ),
            )
          ]),
          space(height: 30),
          Row(children: [
            Expanded(
              child: saveBtnForm(context, () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.selectedOrganization.save();
                  widget.onSubmit({
                    'organization': widget.selectedOrganization,
                  });
                  Navigator.of(context).pop();
                }
              }),
            ),
          ])
        ],
      ),
    );
  }
}
