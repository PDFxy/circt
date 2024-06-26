//===- Types.td - Common type predicates and definitions ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file collects type predicates and definitions commonly used in the CIRCT
// dialects.
//
//===----------------------------------------------------------------------===//

#ifndef CIRCT_TYPES
#define CIRCT_TYPES

//===----------------------------------------------------------------------===//
// Attributes
//===----------------------------------------------------------------------===//

def APSIntAttr : Attr<CPred<"llvm::isa<::mlir::IntegerAttr>($_self)">,
                      "arbitrary integer attribute with sign"> {
  let storageType = [{ ::mlir::IntegerAttr }];
  let returnType = [{ ::llvm::APSInt }];
  let constBuilderCall = "IntegerAttr::get($_builder.getContext(), $0)";
  let convertFromStorage = "$_self.getAPSInt()";
}

// Compared to the standard ArrayAttr, the accessor to an ArrayRefAttr will
// convert the attribute to an ArrayRef, while an ArrayAttr accessor just
// returns itself.
def ArrayRefAttr :
  ArrayAttrBase<
    CPred<"::llvm::isa<::mlir::ArrayAttr>($_self)">, "array attribute"> {
  let returnType = [{ ::llvm::ArrayRef<Attribute> }];
  let convertFromStorage = [{ $_self.getValue() }];
}

// Similar to ArrayRefAttr, but requiring all elements are the same type.
class TypedArrayRefAttrBase<Attr element, string summary>: ArrayAttrBase<
    And<[
      CPred<"::llvm::isa<::mlir::ArrayAttr>($_self)">,
      Concat<"::llvm::all_of(::llvm::cast<::mlir::ArrayAttr>($_self), "
                            "[&](::mlir::Attribute attr) { return attr && (",
                               SubstLeaves<"$_self", "attr", element.predicate>,
                            "); })">]>,
    summary> {

  Attr elementAttr = element;

  let returnType = [{ ::llvm::ArrayRef<Attribute> }];
  let convertFromStorage = [{ $_self.getValue() }];
}

def DistinctAttr : Attr<CPred<"llvm::isa<::mlir::DistinctAttr>($_self)">,
                      "distinct attribute"> {
  let storageType = [{ ::mlir::DistinctAttr }];
  let returnType = [{ ::mlir::DistinctAttr }];
  let convertFromStorage = "$_self";
}

def FloatAttr : Attr<CPred<"llvm::isa<::mlir::FloatAttr>($_self)">,
                      "float attribute"> {
  let storageType = [{ ::mlir::FloatAttr }];
  let returnType = [{ ::mlir::FloatAttr }];
  let convertFromStorage = "$_self";
}

def DoubleAttr : Attr<And<[CPred<"llvm::isa<::mlir::FloatAttr>($_self)">,
                           CPred<"cast<::mlir::FloatAttr>($_self).getType().isF64()">]>,
                      "double-precision float"> {
  let storageType = [{ ::mlir::FloatAttr }];
  let returnType = [{ ::mlir::FloatAttr }];
  let convertFromStorage = "$_self";
}

#endif // CIRCT_TYPES
