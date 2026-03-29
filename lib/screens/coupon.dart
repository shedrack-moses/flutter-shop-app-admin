// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eccomerce_app/components/custom_textfield.dart';
import 'package:flutter/material.dart';

import 'package:eccomerce_app/controllers/firestore_db.dart';
import 'package:eccomerce_app/models/cuopon_model.dart';

class Coupon extends StatefulWidget {
  const Coupon({super.key});

  @override
  State<Coupon> createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  //catched the stream to avoid reloading
  late final Stream<QuerySnapshot> _couponStreM;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _couponStreM = FirestoreDb().readCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coupons'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _couponStreM,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          // Check if snapshot has data
          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return Center(
              child: Text('No coupons available'),
            );
          }

          var couponList = CouponModel.jsonList(snapshot.data!.docs);
          return ListView.builder(
            itemCount: couponList.length,
            itemBuilder: (BuildContext context, int index) {
              var coupon = couponList[index];
              return ListTile(
                title: Text(
                  coupon.code.toUpperCase(),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  coupon.desc,
                  style: TextStyle(),
                ),
                trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ModifyCouponPage(
                                data: coupon,
                              );
                            },
                          ),
                        );
                      } else if (value == 'delete') {
                        // Fixed: removed extra spaces
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Delete Coupon?'),
                                content: Text(
                                    'Are you sure you want to delete coupon "${coupon.code.toUpperCase()}?"'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel')),
                                  TextButton(
                                    onPressed: () {
                                      FirestoreDb()
                                          .deleteCuopons(id: coupon.id ?? '');

                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Coupon deleted!!'),
                                        ),
                                      );
                                    },
                                    child: Text('Delete'),
                                  )
                                ],
                              );
                            });
                      }
                    },
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                              title: Text('Edit'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons
                                    .delete, // Fixed: changed from edit to delete icon
                                size: 20,
                              ),
                              title: Text('Delete'),
                            ),
                          ),
                        ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ModifyCouponPage(); // data is null for new coupon
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ModifyCouponPage extends StatefulWidget {
  final CouponModel? data;

  const ModifyCouponPage({
    super.key,
    this.data,
  });

  @override
  State<ModifyCouponPage> createState() => _ModifyCouponPageState();
}

class _ModifyCouponPageState extends State<ModifyCouponPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if editing
    if (widget.data != null) {
      _codeController.text = widget.data!.code;
      _descController.text = widget.data!.desc;
      _discountController.text = widget.data!.discount.toString();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(
        widget.data == null ? 'Add Coupon' : "Update Coupon",
      ),
      content: SingleChildScrollView(
        child: Form(
          // ✅ Added Form wrapper
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ Added to prevent overflow
            children: [
              Text("All will be converted to uppercase"),
              SizedBox(height: 10),

              // ✅ Fixed: Using correct controller
              CustomTextfield(
                controller: _codeController,
                hintText: 'Add code',
                label: 'Code',
                validator: (data) {
                  if (data == null || data.isEmpty) {
                    return "This cannot be empty!!";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // ✅ Fixed: Using description controller
              CustomTextfield(
                controller: _descController,
                hintText: 'Add description',
                label: 'Description',
                validator: (data) {
                  if (data == null || data.isEmpty) {
                    return "This cannot be empty!!";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // ✅ Fixed: Using discount controller
              CustomTextfield(
                keyboardType: TextInputType.number,
                controller: _discountController,
                hintText: 'Add discount',
                label: 'Discount',
                validator: (data) {
                  if (data == null || data.isEmpty) {
                    return "This cannot be empty!!";
                  }
                  if (int.tryParse(data) == null) {
                    return 'pls input valid numbers';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // ✅ Fixed: Proper null checking
            if (_formKey.currentState?.validate() ?? false) {
              try {
                var data = CouponModel(
                  code: _codeController.text.trim().toUpperCase(),
                  desc: _descController.text.trim(),
                  discount: int.parse(_discountController.text.trim()),
                );

                // ✅ Fixed: Safe null checking
                if (widget.data != null &&
                    widget.data!.id?.isNotEmpty == true) {
                  // Update existing coupon
                  FirestoreDb().updateCoupons(data: data, id: widget.data!.id!);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Coupon updated successfully!!'),
                      ),
                    );
                  }
                } else {
                  // Create new coupon
                  FirestoreDb().createCoupons(data: data);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Coupon added successfully!!'),
                      ),
                    );
                  }
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Error: ${e.toString()}'),
                    ),
                  );
                }
              }
            }
          },
          child: Text((widget.data?.id?.isNotEmpty == true) ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
