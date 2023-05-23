#include "llvm/ADT/APInt.h"
#include "llvm/IR/Verifier.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/IR/IRBuilder.h"

#include <algorithm>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

using namespace llvm;

int main() {

    LLVMContext context;
    Module *module = new Module("gen-opt-lab2", context); 
    IRBuilder<> builder(context); 
    FunctionType *funcType = FunctionType::get(builder.getInt32Ty(), false); 
    
    Function *mainFunc = Function::Create(
        funcType, 
        Function::ExternalLinkage,
        "main",
        module); 

    BasicBlock *entry = BasicBlock::Create(
        context, 
        "entrypoint", 
        mainFunc);

    builder.SetInsertPoint(entry); 

    Value *a_const = ConstantInt::get(
        Type::getInt32Ty(context), 
        353);
    Value *b_const = ConstantInt::get(
        Type::getInt32Ty(context), 
        48); 
    Value *return_value = builder.CreateAdd(a_const, b_const, "retVal"); 
    builder.CreateRet(return_value);  

    module->dump();

    delete module;
    return 0;
}

// 
// clang++ lab2.cpp `llvm-config --cxxflags --ldflags --system-libs --libs engine interpreter` -lffi
// 
// int main() {
//      return 353 + 48;
// }
